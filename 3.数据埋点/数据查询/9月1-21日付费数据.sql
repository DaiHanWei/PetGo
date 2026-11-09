-- ============================================================
-- 9 月 1–21 日付费数据（去重付费用户数 / 付费金额 / 付费次数 / 付费用户名单）
-- 创建日期：2026-09-21
-- 说明：表名/字段名/枚举值已对照 db-schema-reference.md 核对。
--       口径与「8月付费数据.sql」保持一致，可直接月度对比。
--       输出列名统一用英文，便于导出 CSV / 交付他人。
--
-- ⚠️ 库选择：这是"实际有多少用户付了钱"的问题，必须查【正式库 petgo】，
--   不能查 staging 库 petgo_stag（那是测试数据，金额都是假的）。
--
-- ⚠️ 窗口不完整：9/21 是今天，当天数据尚未走完，与 9/1–9/20 的整日不可直接
--   按日均类比。如只要完整日，把 period_end 改成 DATE '2026-09-20'。
--
-- 口径说明（沿用 8 月口径）：
--   1. 「付费」= payment_intents.status = 'PAID'（已到账的付款单）。
--      覆盖全部收费场景：VET_CONSULT 兽医问诊 / PAWCOIN_TOPUP 充值 /
--      AI_UNLOCK AI 详情解锁 / ID_HD 身份证高清图。
--   2. ⚠️ channel = 'PAWCOIN'（用站内 PawCoin 余额扣减消费）不产生
--      payment_intents 行，只有【真实花钱】的 QRIS 支付会进本表。
--      即本表统计的是"真金白银流入平台"的笔数与金额，不含用户消费已充值
--      余额的行为（那部分钱已在充值时统计过一次，此处不重复计收入）。
--   3. 「去重付费用户数」= 窗口内至少有一笔 PAID 记录的去重用户数。
--   4. 「付费金额」= 窗口内 PAID 记录 amount 之和，单位 IDR 最小单位
--      （IDR 无小数分位，50000 即 Rp50.000）。
--   5. 「付费次数」= PAID 记录行数。查询 1 给总笔数与人均次数，
--      查询 3 给次数分布，查询 4 给完整付费用户名单。
--   6. ⚠️ 未扣除退款：refund_requests 里已退的钱仍计在查询 1–4 内，
--      查询 1–4 是"流入口径"而非"净收入口径"。如需净额见查询 5。
--   7. 查询 1–3 未排除 ADMIN / 虚拟种子账号。查询 4 的名单单独给出
--      account_flag 列标出可疑账号，先看名单再决定要不要回头剔除。
--   8. 付费时间取 created_at（下单时刻），与 8 月一致。严格说到账时刻是
--      status 改 PAID 的 updated_at，但跨日下单次日支付的边界单极少，
--      为保持月度可比仍用 created_at。
--   9. 时区：created_at 存 UTC，此处按 UTC 切日（与 8 月一致）。若要严格按
--      印尼时间（WIB, UTC+7）切日，把 created_at::date 换成
--      (created_at AT TIME ZONE 'Asia/Jakarta')::date。
-- ============================================================


-- ============================================================
-- 查询 1：总览
-- ============================================================
WITH params AS (
    SELECT DATE '2026-08-01' AS period_start,
           DATE '2026-08-31' AS period_end      -- 含尾：统计到 9/21 当天
),
paid AS (
    SELECT pi.user_id, pi.amount
    FROM payment_intents pi
    CROSS JOIN params p
    WHERE pi.status = 'PAID'
      AND pi.created_at::date BETWEEN p.period_start AND p.period_end
),
per_user AS (
    SELECT user_id, COUNT(*) AS pay_times, SUM(amount) AS user_amount
    FROM paid
    GROUP BY user_id
)
SELECT
    (SELECT COUNT(*) FROM per_user)                          AS paying_users,
    (SELECT COALESCE(SUM(amount), 0) FROM paid)              AS revenue_idr,
    (SELECT COUNT(*) FROM paid)                              AS payment_count,
    ROUND(
        (SELECT COUNT(*) FROM paid)::numeric
        / NULLIF((SELECT COUNT(*) FROM per_user), 0), 2)     AS avg_payments_per_user,
    (SELECT COUNT(*) FROM per_user WHERE pay_times >= 2)     AS repeat_payers,
    ROUND(
        (SELECT COALESCE(SUM(amount), 0) FROM paid)::numeric
        / NULLIF((SELECT COUNT(*) FROM per_user), 0), 0)     AS arppu_idr,
    ROUND(
        (SELECT COALESCE(SUM(amount), 0) FROM paid)::numeric
        / NULLIF((SELECT COUNT(*) FROM paid), 0), 0)         AS avg_order_value_idr;


-- ============================================================
-- 查询 2：按付款用途拆分（看钱从哪来）
-- ============================================================
WITH params AS (
    SELECT DATE '2026-08-01' AS period_start,
           DATE '2026-08-31' AS period_end
),
paid AS (
    SELECT pi.user_id, pi.amount, pi.purpose
    FROM payment_intents pi
    CROSS JOIN params p
    WHERE pi.status = 'PAID'
      AND pi.created_at::date BETWEEN p.period_start AND p.period_end
)
SELECT
    purpose                          AS purpose,
    COUNT(DISTINCT user_id)          AS paying_users,
    COUNT(*)                         AS payment_count,
    SUM(amount)                      AS revenue_idr
FROM paid
GROUP BY purpose
ORDER BY SUM(amount) DESC;
-- 用途枚举：VET_CONSULT=兽医问诊 / PAWCOIN_TOPUP=PawCoin充值
--          / AI_UNLOCK=AI详情解锁 / ID_HD=身份证高清图
-- ⚠️ 各行 paying_users 相加 ≠ 查询 1 的总数（同一人可能付多个用途）


-- ============================================================
-- 查询 3：付费次数分布（多少人付了 1 次、2 次、3 次……）
-- ============================================================
WITH params AS (
    SELECT DATE '2026-08-01' AS period_start,
           DATE '2026-08-31' AS period_end
),
per_user AS (
    SELECT pi.user_id, COUNT(*) AS pay_times, SUM(pi.amount) AS user_amount
    FROM payment_intents pi
    CROSS JOIN params p
    WHERE pi.status = 'PAID'
      AND pi.created_at::date BETWEEN p.period_start AND p.period_end
    GROUP BY pi.user_id
)
SELECT
    pay_times                                          AS payment_times,
    COUNT(*)                                           AS user_count,
    SUM(user_amount)                                   AS revenue_idr,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS user_share_pct
FROM per_user
GROUP BY pay_times
ORDER BY pay_times;


-- ============================================================
-- 查询 4：付费用户名单（完整，可直接导 CSV）
--   按付费金额从高到低排。account_flag 列用于判断是否运营/测试账号，
--   先看名单再决定是否剔除，不默认过滤。
-- ============================================================
WITH params AS (
    SELECT DATE '2026-09-01' AS period_start,
           DATE '2026-09-21' AS period_end
),
paid AS (
    SELECT pi.user_id, pi.amount, pi.purpose, pi.created_at
    FROM payment_intents pi
    CROSS JOIN params p
    WHERE pi.status = 'PAID'
      AND pi.created_at::date BETWEEN p.period_start AND p.period_end
),
per_user AS (
    SELECT user_id,
           COUNT(*)                                        AS pay_times,
           SUM(amount)                                     AS user_amount,
           MIN(created_at)                                 AS first_paid_at,
           MAX(created_at)                                 AS last_paid_at,
           STRING_AGG(DISTINCT purpose::text, ' + ' ORDER BY purpose::text) AS purposes
    FROM paid
    GROUP BY user_id
)
SELECT
    ROW_NUMBER() OVER (ORDER BY pu.user_amount DESC, pu.pay_times DESC) AS rank,
    pu.user_id                            AS user_id,
    u.nickname                            AS nickname,
    u.email                               AS email,
    u.role                                AS role,
    u.status                              AS account_status,
    CASE
        WHEN u.role = 'ADMIN'                          THEN 'ADMIN'
        WHEN u.google_sub LIKE 'admin:%'               THEN 'ADMIN'
        WHEN u.google_sub LIKE 'virtual:%'             THEN 'VIRTUAL'
        WHEN u.google_sub LIKE 'seed-tailtopia-%'      THEN 'SEED'
        WHEN u.google_sub LIKE 'deleted:%'             THEN 'DELETED'
        WHEN u.deleted_at IS NOT NULL                  THEN 'DELETED'
        ELSE 'REAL'
    END                                   AS account_flag,
    u.pet_status                          AS pet_status,
    u.created_at                          AS registered_at_utc,
    pu.pay_times                          AS payment_times,
    pu.user_amount                        AS revenue_idr,
    pu.purposes                           AS purposes,
    pu.first_paid_at                      AS first_paid_at_utc,
    pu.last_paid_at                       AS last_paid_at_utc,
    CASE WHEN u.created_at::date BETWEEN (SELECT period_start FROM params)
                                     AND (SELECT period_end   FROM params)
         THEN 'Y' ELSE 'N' END            AS new_user_in_period
FROM per_user pu
JOIN users u ON u.id = pu.user_id
ORDER BY pu.user_amount DESC, pu.pay_times DESC;
-- account_flag：REAL=真实用户 / ADMIN=运营账号 / VIRTUAL,SEED=虚拟种子账号
--               / DELETED=已注销（个人信息已擦空，nickname、email 会是空）
-- new_user_in_period：Y=本窗口内新注册且当期就付费（拉新即转化）
-- ⚠️ email、nickname 为 PII，导出后请勿外发，不要贴进公开文档或飞书群


-- ============================================================
-- 查询 4b：逐笔付费流水（名单的下钻，看每一笔而非每个人）
-- ============================================================
WITH params AS (
    SELECT DATE '2026-08-01' AS period_start,
           DATE '2026-08-31' AS period_end
)
SELECT
    pi.created_at        AS paid_at_utc,
    pi.user_id           AS user_id,
    u.nickname           AS nickname,
    pi.purpose           AS purpose,
    pi.channel           AS channel,
    pi.amount            AS amount_idr,
    pi.public_token      AS payment_token
FROM payment_intents pi
CROSS JOIN params p
JOIN users u ON u.id = pi.user_id
WHERE pi.status = 'PAID'
  AND pi.created_at::date BETWEEN p.period_start AND p.period_end
ORDER BY pi.created_at;


-- ============================================================
-- 查询 5：扣除退款后的净收入
-- 字段/枚举已对照 db-schema-reference.md 的 refund_requests 核对。
--
-- ⚠️ 三点注意：
--   1. 退款只覆盖【兽医问诊订单】（refund_requests.order_id FK→consult_orders），
--      PawCoin 充值、AI 解锁、身份证高清图不走本表，无法退。
--   2. 退款滞后：本查询统计的是"9/1–9/21 内打款完成"的退款，其对应订单
--      可能是 8 月甚至更早下的；反过来 9 月订单的退款也可能在 10 月才出账。
--      所以这是【现金流口径】的净额，不是"9 月订单的最终净额"。
--   3. 扣减用 order_amount（用户付的全额）而非 net_amount：渠道手续费由平台
--      承担，平台实际流出的是订单全额。
-- ============================================================
WITH params AS (
    SELECT DATE '2026-09-01' AS period_start,
           DATE '2026-09-21' AS period_end
),
gross AS (
    SELECT COALESCE(SUM(pi.amount), 0) AS amt, COUNT(*) AS cnt
    FROM payment_intents pi
    CROSS JOIN params p
    WHERE pi.status = 'PAID'
      AND pi.created_at::date BETWEEN p.period_start AND p.period_end
),
refunded AS (
    SELECT COALESCE(SUM(r.order_amount), 0) AS amt, COUNT(*) AS cnt
    FROM refund_requests r
    CROSS JOIN params p
    WHERE r.approval_status = 'DONE'
      AND r.paid_at IS NOT NULL
      AND r.paid_at::date BETWEEN p.period_start AND p.period_end
)
SELECT
    g.amt                                       AS gross_revenue_idr,
    g.cnt                                       AS payment_count,
    rf.amt                                      AS refund_amount_idr,
    rf.cnt                                      AS refund_count,
    g.amt - rf.amt                              AS net_revenue_idr,
    ROUND(100.0 * rf.amt / NULLIF(g.amt, 0), 2) AS refund_rate_pct
FROM gross g CROSS JOIN refunded rf;
