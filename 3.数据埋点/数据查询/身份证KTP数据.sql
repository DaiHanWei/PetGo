-- ============================================================
-- 宠物身份证数据 SQL / Pet ID Card (KTP) Metrics
-- 创建日期 / Created: 2026-08-14
-- 数据库 / Database: PostgreSQL（正式库 petgo / staging 库 petgo_stag 均可跑）
--
-- 对应需求 / Scope:
--   V1.1.0 FR-49 / FR-49D 宠物身份证生成与 HD 付费下载（单卡模型，legacy）
--   V1.1.2 Story 6-7 / 6-8 多卡快照模型（migration V91–V96，已在 main 分支 = 线上生效）
--
-- ⚠️ 本 SQL 的表结构以 petgo-platform 迁移脚本为准，不以 db-schema-reference.md 为准
--    —— 后者快照于 2026-07-20，尚未包含 id_cards 表，其中「一账号至多一条购买记录」
--    的描述已被 V92 迁移作废。
--
-- ============================================================
-- 【口径说明 / Definitions】取数前请先确认
-- ============================================================
--
-- 1. 「创建」= id_cards 一行 = 一次建卡（IdCardService.createCard）。
--    ✅ 一个用户可以建多张卡：createCard 无任何数量限制、也不要求有宠物档案，
--       id_cards 只对 serial_id 唯一，对 user_id 无计数约束（V91）。
--       三种卡面（KTP / PASSPORT / STUDENT）各建一张即 3 次，实际可无限建。
--    ⇒ 所以「创建人数」与「创建次数」是两个真会不同的数。
--
-- 2. 卡面类型可拆：id_cards.card_type ∈ KTP | PASSPORT | STUDENT（V93）。
--    ⚠️ V93 之前建的存量卡由迁移统一 DEFAULT 'KTP' 回填，所以 KTP 的数会偏高，
--       无法把「真的是 KTP 卡面」和「V93 前的老卡」区分开。
--
-- 3. 「付费」的权威口径是 id_cards.hd_unlocked = true，不是 id_card_hd_purchases 的行数。
--    V92 起 HD 解锁改为按卡（一卡一解锁），并去掉了 UNIQUE(user_id)；
--    id_card_hd_purchases 降级成「支付尝试 / 收据」表：
--      - PAWCOIN 行：同步扣费成功时才建 → 行即成功
--      - QRIS   行：下单即建（存 card_id + payment_intent_id 供回调反查），
--                   此时钱还没到账；超窗重开会新建 intent → 再建一行 attempt
--    ⇒ 直接 COUNT(*) 这张表会把「没付成功」和「同一张卡重试多次」都算进去。
--       真正的付费笔数看 hd_unlocked 的卡数；想看漏斗看查询 4。
--
-- 4. 新旧两套模型并存（legacy 端点 v1.0.x 客户端仍在用）：
--      - 新（多卡）：POST /me/id-cards/{cardId}/hd-download → attempt 行 card_id 非空
--      - 旧（单卡）：POST /me/id-card/hd-download          → attempt 行 card_id 为 NULL，
--                    账号级永久解锁，且只在到账后才建行（即 card_id IS NULL 的行都是成功的）
--    V92 迁移已把老用户的永久解锁回填成一张 hd_unlocked=true 的快照卡并回填 card_id，
--    仅「购买时档案已删（pet_profile_id IS NULL）」的极少数行没能快照、card_id 留 NULL。
--    ⇒ 成功付费 = hd_unlocked 的卡 + card_id IS NULL 的 attempt 行，两者不重叠。
--
-- 5. 另有一个 legacy 的「生成身份证」动作：pet_profiles.serial_id 分配
--    （FR-49A generateSerial，老档案点「立即申请」触发）。它跟多卡模型是两套编号，
--    不是本次要的「创建卡」。作为参考放在查询 6，别跟查询 1 的创建数混用。
--
-- 6. 用户过滤：排除运营 ADMIN 账号与虚拟种子账号（沿用 内容运营所需数据.sql 的
--    role + google_sub 前缀写法）。
--    ⚠️ 不排除已注销用户：注销是「就地匿名化」不删行，其建过的卡仍在 id_cards 里，
--       历史上确实创建过，计入更符合「有多少人创建了」。其中的注销规模见查询 1 末列。
--
-- 7. 金额单位是 IDR 最小单位、IDR 无小数，5000 = Rp5.000（FR-49D 定价）。
--    PawCoin 单位 koin，1 koin = Rp1。
-- ============================================================


-- ============================================================
-- 查询 1：总览 / Overview（一行，即要的四个数）
-- ============================================================
WITH real_users AS (
    SELECT u.id, u.deleted_at
    FROM users u
    WHERE u.role = 'USER'
      AND COALESCE(u.google_sub, '') NOT LIKE 'admin:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'virtual:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'seed-tailtopia-%'
),
cards AS (                      -- 全部建卡记录 = 创建
    SELECT c.id, c.user_id, c.card_type, c.hd_unlocked, c.created_at
    FROM id_cards c
    JOIN real_users ru ON ru.id = c.user_id
),
legacy_paid AS (                -- 旧单卡端点的成功付费（无对应快照卡，不与 hd_unlocked 重叠）
    SELECT h.id, h.user_id
    FROM id_card_hd_purchases h
    JOIN real_users ru ON ru.id = h.user_id
    WHERE h.card_id IS NULL
),
paid_users AS (                 -- 付费人数：新旧两条路合并去重
    SELECT user_id FROM cards WHERE hd_unlocked
    UNION
    SELECT user_id FROM legacy_paid
)
SELECT
    (SELECT COUNT(DISTINCT user_id) FROM cards)                 AS "创建人数 / Creators",
    (SELECT COUNT(*)                FROM cards)                 AS "创建次数 / Cards created",
    (SELECT COUNT(*)                FROM paid_users)            AS "付费人数 / Payers",
    (SELECT COUNT(*) FROM cards WHERE hd_unlocked)
        + (SELECT COUNT(*) FROM legacy_paid)                    AS "付费次数 / Successful unlocks",
    -- 以下为辅助列
    ROUND((SELECT COUNT(*) FROM cards)::numeric
          / NULLIF((SELECT COUNT(DISTINCT user_id) FROM cards), 0), 2)
                                                                AS "人均建卡张数 / Cards per creator",
    ROUND(100.0 * (SELECT COUNT(*) FROM paid_users)
          / NULLIF((SELECT COUNT(DISTINCT user_id) FROM cards), 0), 2)
                                                                AS "创建到付费转化率% / Creator→payer %",
    (SELECT COUNT(*) FROM id_card_hd_purchases h
      JOIN real_users ru ON ru.id = h.user_id)                   AS "支付尝试笔数 / Payment attempts",
    (SELECT COUNT(DISTINCT c.user_id) FROM cards c
      JOIN real_users ru ON ru.id = c.user_id
     WHERE ru.deleted_at IS NOT NULL)                            AS "其中已注销用户 / Of which deleted";


-- ============================================================
-- 查询 2：按卡面类型拆分 / By card type（KTP / PASSPORT / STUDENT）
-- ⚠️ V93 之前的存量卡被迁移统一置为 KTP，KTP 的数偏高
-- ============================================================
WITH real_users AS (
    SELECT u.id
    FROM users u
    WHERE u.role = 'USER'
      AND COALESCE(u.google_sub, '') NOT LIKE 'admin:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'virtual:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'seed-tailtopia-%'
)
SELECT
    c.card_type                                        AS "卡面类型 / Card type",
    COUNT(DISTINCT c.user_id)                          AS "创建人数 / Creators",
    COUNT(*)                                           AS "创建次数 / Cards created",
    COUNT(DISTINCT c.user_id) FILTER (WHERE c.hd_unlocked)
                                                       AS "付费人数 / Payers",
    COUNT(*) FILTER (WHERE c.hd_unlocked)              AS "付费次数 / Unlocks",
    ROUND(100.0 * COUNT(*) FILTER (WHERE c.hd_unlocked)
          / NULLIF(COUNT(*), 0), 2)                    AS "该卡面解锁率% / Unlock rate %"
FROM id_cards c
JOIN real_users ru ON ru.id = c.user_id
GROUP BY c.card_type
ORDER BY "创建次数 / Cards created" DESC;


-- ============================================================
-- 查询 3：每人建了几张卡 / Cards-per-user distribution
-- 用来验证「用户可以创建三次以上」的实际分布，也是防刷观察口（FR-96 相关）
-- ============================================================
WITH real_users AS (
    SELECT u.id
    FROM users u
    WHERE u.role = 'USER'
      AND COALESCE(u.google_sub, '') NOT LIKE 'admin:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'virtual:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'seed-tailtopia-%'
),
per_user AS (
    SELECT c.user_id, COUNT(*) AS card_cnt
    FROM id_cards c
    JOIN real_users ru ON ru.id = c.user_id
    GROUP BY c.user_id
)
SELECT
    CASE WHEN card_cnt >= 10 THEN '10+' ELSE card_cnt::text END AS "建卡张数 / Cards per user",
    COUNT(*)                                                    AS "用户数 / Users",
    SUM(card_cnt)                                               AS "卡数合计 / Total cards"
FROM per_user
GROUP BY 1
ORDER BY MIN(card_cnt);


-- ============================================================
-- 查询 4：付费漏斗与渠道 / Payment funnel & channels
-- PawCoin 失败不落库（扣费失败整事务回滚），所以「未到账」只可能出现在 QRIS
-- ============================================================
WITH real_users AS (
    SELECT u.id
    FROM users u
    WHERE u.role = 'USER'
      AND COALESCE(u.google_sub, '') NOT LIKE 'admin:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'virtual:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'seed-tailtopia-%'
)
SELECT
    h.pay_channel                                              AS "支付渠道 / Channel",
    COALESCE(pi.status, 'PAWCOIN_INSTANT')                     AS "付款单状态 / Intent status",
    COUNT(*)                                                   AS "尝试笔数 / Attempts",
    COUNT(DISTINCT h.user_id)                                  AS "涉及人数 / Users",
    COUNT(DISTINCT h.card_id)                                  AS "涉及卡数 / Cards",
    COALESCE(SUM(pi.amount), 0)                                AS "金额合计IDR / Amount (IDR)"
FROM id_card_hd_purchases h
JOIN real_users ru ON ru.id = h.user_id
LEFT JOIN payment_intents pi ON pi.id = h.payment_intent_id
GROUP BY h.pay_channel, COALESCE(pi.status, 'PAWCOIN_INSTANT')
ORDER BY "尝试笔数 / Attempts" DESC;

-- 收入合计 / Revenue（QRIS 真钱 + PawCoin 消耗，两者单位不同不要相加）
WITH real_users AS (
    SELECT u.id
    FROM users u
    WHERE u.role = 'USER'
      AND COALESCE(u.google_sub, '') NOT LIKE 'admin:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'virtual:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'seed-tailtopia-%'
)
SELECT
    (SELECT COALESCE(SUM(pi.amount), 0)
     FROM payment_intents pi
     JOIN real_users ru ON ru.id = pi.user_id
     WHERE pi.purpose = 'ID_HD' AND pi.status = 'PAID')      AS "QRIS真钱收入IDR / QRIS revenue",
    (SELECT COALESCE(SUM(-pt.delta), 0)
     FROM pawcoin_transactions pt
     JOIN real_users ru ON ru.id = pt.user_id
     WHERE pt.ref_type = 'ID_HD' AND pt.type = 'SPEND')      AS "PawCoin消耗koin / PawCoin spent";


-- ============================================================
-- 查询 5：按月趋势 / Monthly trend
-- 创建按 id_cards.created_at；付费按 attempt 行的 purchased_at（成功笔数以 hd_unlocked 卡为准，
-- 但卡上没有解锁时间戳，所以趋势只能用 attempt 行的时间近似）
-- ============================================================
WITH real_users AS (
    SELECT u.id
    FROM users u
    WHERE u.role = 'USER'
      AND COALESCE(u.google_sub, '') NOT LIKE 'admin:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'virtual:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'seed-tailtopia-%'
),
created_month AS (
    SELECT DATE_TRUNC('month', c.created_at) AS ym,
           COUNT(DISTINCT c.user_id)         AS creators,
           COUNT(*)                          AS cards
    FROM id_cards c
    JOIN real_users ru ON ru.id = c.user_id
    GROUP BY 1
),
paid_month AS (
    SELECT DATE_TRUNC('month', h.purchased_at) AS ym,
           COUNT(DISTINCT h.user_id)           AS payers,
           COUNT(*)                            AS paid_cnt
    FROM id_card_hd_purchases h
    JOIN real_users ru ON ru.id = h.user_id
    LEFT JOIN payment_intents pi ON pi.id = h.payment_intent_id
    WHERE pi.id IS NULL OR pi.status = 'PAID'   -- 只算成功：PawCoin 即时 + QRIS 已到账
    GROUP BY 1
)
SELECT
    TO_CHAR(COALESCE(c.ym, p.ym), 'YYYY-MM')  AS "月份 / Month",
    COALESCE(c.creators, 0)                   AS "创建人数 / Creators",
    COALESCE(c.cards, 0)                      AS "创建次数 / Cards created",
    COALESCE(p.payers, 0)                     AS "付费人数 / Payers",
    COALESCE(p.paid_cnt, 0)                   AS "付费次数 / Successful unlocks"
FROM created_month c
FULL OUTER JOIN paid_month p ON p.ym = c.ym
ORDER BY "月份 / Month";


-- ============================================================
-- 查询 6（参考）：legacy 流水号分配 / Legacy serial allocation
-- pet_profiles.serial_id 是 FR-49A 的老「生成身份证」动作（老档案点「立即申请」触发），
-- 与多卡模型是两套编号体系。仅供对照，不要与查询 1 的创建数相加。
-- ⚠️ 删档时流水号回收进 pet_serial_pool、行被删，所以这是「当前在册」口径。
-- ============================================================
WITH real_users AS (
    SELECT u.id
    FROM users u
    WHERE u.role = 'USER'
      AND COALESCE(u.google_sub, '') NOT LIKE 'admin:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'virtual:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'seed-tailtopia-%'
)
SELECT
    COUNT(*)                                                AS "建档用户数 / Profiles",
    COUNT(*) FILTER (WHERE p.serial_id IS NOT NULL)          AS "已分配流水号 / Serial assigned",
    COUNT(*) FILTER (WHERE p.serial_id IS NULL)              AS "未分配流水号 / No serial",
    ROUND(100.0 * COUNT(*) FILTER (WHERE p.serial_id IS NOT NULL)
          / NULLIF(COUNT(*), 0), 2)                          AS "分配率% / Assigned %"
FROM pet_profiles p
JOIN real_users ru ON ru.id = p.owner_id;
