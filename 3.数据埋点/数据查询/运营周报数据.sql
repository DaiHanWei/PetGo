-- ============================================================
-- 运营周报数据 SQL（7 日累计）
-- 创建日期：2026-07-27
-- 说明：本查询基于现有数据库表，不依赖任何新增埋点。
--       表名/字段名/枚举值已对照 db-schema-reference.md（staging 库 petgo_stag）核对。
--       与「内容运营所需数据.sql」口径保持一致，只是把「分天」改为「整周一个累计数」。
--
-- 本周窗口：2026-07-20 ~ 2026-07-26（含头含尾，共 7 天），在下方 params 里改日期即可复用到其他周。
--
-- 口径说明（本人判断，需运营/产品确认是否符合预期）：
--   1. 「真实用户」= role='USER' 且排除运营 ADMIN / 虚拟种子账号——沿用内容运营 SQL 的
--      google_sub 前缀判断：admin:=ADMIN、virtual: / seed-tailtopia-=种子账号。
--      （users 表现已新增 account_type 列 REAL/VIRTUAL，若 stag 已回填数据，可换成
--       account_type='REAL' 更直接；此处为与既有 SQL 完全一致仍用 google_sub。）
--   2. 「内容总发布数量」「知识类发布数量」统计当周 created_at 落在窗口内、
--      status='PUBLISHED' AND deleted_at IS NULL 的公开可见帖子。
--      ⚠️ 注意：这两个内容量指标【不】排除虚拟/种子账号所发内容——即包含运营发布的种子内容
--      （与内容运营 SQL 中 posts_by_day 的口径一致）。如运营只想看真实用户发布量，需另行加过滤。
--   3. 「知识类」= content_posts.type='KNOWLEDGE'（专业科普）。
--   4. 「周活跃用户数量」：数据库【没有】登录/打开 App 日志表（真正的登录事件只进 PostHog，
--      不落库，见 埋点文件/analytics-posthog-tracking.md）。因此这里的「活跃」是可从库里算出的
--      【行为口径代理值】= 当周做过以下任一动作的去重真实用户：发布帖子 / 评论 / 点赞。
--      真正基于「打开 App / 登录」的 WAU 请去 PostHog 查，两者不是同一口径。
--   5. 「知识类活跃用户数量」= 当周对 KNOWLEDGE 类帖子点过赞 或 评论过 的去重真实用户数。
--      评论只算 deleted_at IS NULL；取消点赞是直接删行，无需额外过滤。
--   6. 「新增用户数量」= 当周新注册的去重真实用户数。
--
-- 时区提醒：created_at 存的是 UTC。此处 created_at::date 依赖数据库会话时区，与内容运营 SQL 一致。
--   若需严格按印尼时间（WIB, UTC+7）切天，把 created_at::date 换成
--   (created_at AT TIME ZONE 'Asia/Jakarta')::date，或先 SET TIME ZONE 'Asia/Jakarta'。
-- ============================================================

WITH params AS (
    SELECT DATE '2026-07-20' AS week_start,
           DATE '2026-07-26' AS week_end          -- 含尾：统计到 7/26 当天
),
real_users AS (
    -- 真实用户白名单：后续所有「用户数」指标都 JOIN 它来排除 ADMIN / 虚拟种子账号
    SELECT u.id
    FROM users u
    WHERE u.role = 'USER'
      AND COALESCE(u.google_sub, '') NOT LIKE 'admin:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'virtual:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'seed-tailtopia-%'
),
content_pub AS (
    -- 指标 1 & 2：当周公开可见帖子的发布量（内容量口径，不排除种子内容）
    SELECT
        COUNT(*)                                    AS total_posts,
        COUNT(*) FILTER (WHERE cp.type = 'KNOWLEDGE') AS knowledge_posts
    FROM content_posts cp
    CROSS JOIN params p
    WHERE cp.status = 'PUBLISHED'
      AND cp.deleted_at IS NULL
      AND cp.created_at::date BETWEEN p.week_start AND p.week_end
),
active_actors AS (
    -- 指标 3 素材：当周做过任一行为的用户 id（发帖 / 评论 / 点赞），UNION 自动去重
    SELECT cp.author_id AS uid
    FROM content_posts cp CROSS JOIN params p
    WHERE cp.status = 'PUBLISHED' AND cp.deleted_at IS NULL
      AND cp.created_at::date BETWEEN p.week_start AND p.week_end
    UNION
    SELECT c.author_id
    FROM comments c CROSS JOIN params p
    WHERE c.deleted_at IS NULL
      AND c.created_at::date BETWEEN p.week_start AND p.week_end
    UNION
    SELECT cl.user_id
    FROM content_likes cl CROSS JOIN params p
    WHERE cl.created_at::date BETWEEN p.week_start AND p.week_end
),
wau AS (
    SELECT COUNT(*) AS weekly_active_users
    FROM active_actors a
    JOIN real_users ru ON ru.id = a.uid
),
knowledge_actors AS (
    -- 指标 4 素材：当周对 KNOWLEDGE 帖子点赞 / 评论过的用户 id，UNION 自动去重
    SELECT cl.user_id AS uid
    FROM content_likes cl
    JOIN content_posts cp ON cp.id = cl.post_id AND cp.type = 'KNOWLEDGE'
    CROSS JOIN params p
    WHERE cl.created_at::date BETWEEN p.week_start AND p.week_end
    UNION
    SELECT c.author_id
    FROM comments c
    JOIN content_posts cp ON cp.id = c.post_id AND cp.type = 'KNOWLEDGE'
    CROSS JOIN params p
    WHERE c.deleted_at IS NULL
      AND c.created_at::date BETWEEN p.week_start AND p.week_end
),
knowledge_active AS (
    SELECT COUNT(*) AS knowledge_active_users
    FROM knowledge_actors a
    JOIN real_users ru ON ru.id = a.uid
),
new_users AS (
    -- 指标 5：当周新注册的去重真实用户数
    SELECT COUNT(*) AS new_users
    FROM users u
    JOIN real_users ru ON ru.id = u.id
    CROSS JOIN params p
    WHERE u.created_at::date BETWEEN p.week_start AND p.week_end
)
SELECT
    p.week_start                     AS 统计开始日,
    p.week_end                       AS 统计结束日,
    cp.total_posts                   AS 内容总发布数量,
    cp.knowledge_posts               AS 知识类发布数量,
    w.weekly_active_users            AS 周活跃用户数量,
    k.knowledge_active_users         AS 知识类活跃用户数量,
    n.new_users                      AS 新增用户数量
FROM params p
CROSS JOIN content_pub     cp
CROSS JOIN wau             w
CROSS JOIN knowledge_active k
CROSS JOIN new_users       n;


-- ============================================================
-- ============================================================
-- 【新增】2026-07-27 ~ 2026-08-02 周报数据
-- 新增日期：2026-08-03
-- 说明：口径与上面那段完全一致（真实用户白名单、公开可见帖子定义、活跃=行为代理值），
--       只是把窗口换成 7/27~8/02，并额外加一段「指定 3 个账号的内容互动用户数」。
--       分两条 SQL：查询 A = 全站两个总量；查询 B = 三个账号分别的活跃用户数。
--       ⚠️ 改周期时两条 SQL 的 params 都要改（CTE 不能跨语句共享）。
-- ============================================================

-- ------------------------------------------------------------
-- 查询 A：内容类总发布数量 + 周活跃用户数量（2026-07-27 ~ 2026-08-02）
-- ------------------------------------------------------------
WITH params AS (
    SELECT DATE '2026-07-27' AS week_start,
           DATE '2026-08-02' AS week_end          -- 含尾：统计到 8/2 当天
),
real_users AS (
    SELECT u.id
    FROM users u
    WHERE u.role = 'USER'
      AND COALESCE(u.google_sub, '') NOT LIKE 'admin:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'virtual:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'seed-tailtopia-%'
),
content_pub AS (
    -- 内容类总发布数量：当周新发布且公开可见的帖子（含 DAILY / GROWTH_MOMENT / KNOWLEDGE 三类）
    -- ⚠️ 内容量口径不排除虚拟/种子账号，包含运营发布的种子内容
    SELECT COUNT(*) AS total_posts
    FROM content_posts cp
    CROSS JOIN params p
    WHERE cp.status = 'PUBLISHED'
      AND cp.deleted_at IS NULL
      AND cp.created_at::date BETWEEN p.week_start AND p.week_end
),
active_actors AS (
    -- 周活跃用户口径 = 当周发帖 / 评论 / 点赞过的用户（库里没有登录日志，真 WAU 看 PostHog）
    SELECT cp.author_id AS uid
    FROM content_posts cp CROSS JOIN params p
    WHERE cp.status = 'PUBLISHED' AND cp.deleted_at IS NULL
      AND cp.created_at::date BETWEEN p.week_start AND p.week_end
    UNION
    SELECT c.author_id
    FROM comments c CROSS JOIN params p
    WHERE c.deleted_at IS NULL
      AND c.created_at::date BETWEEN p.week_start AND p.week_end
    UNION
    SELECT cl.user_id
    FROM content_likes cl CROSS JOIN params p
    WHERE cl.created_at::date BETWEEN p.week_start AND p.week_end
),
wau AS (
    SELECT COUNT(*) AS weekly_active_users
    FROM active_actors a
    JOIN real_users ru ON ru.id = a.uid
)
SELECT
    p.week_start          AS 统计开始日,
    p.week_end            AS 统计结束日,
    cp.total_posts        AS 内容类总发布数量,
    w.weekly_active_users AS 周活跃用户数量
FROM params p
CROSS JOIN content_pub cp
CROSS JOIN wau         w;


-- ------------------------------------------------------------
-- 查询 B：指定 3 个账号，各自的内容互动用户数（2026-07-27 ~ 2026-08-02）
--   定义：当周对「该账号发布的内容」点过赞 或 评论过 的去重真实用户数。
--
-- 口径选择（本人判断，需确认是否符合预期）：
--   a. 时间窗口卡在【互动行为】上，不卡帖子发布时间——即老帖本周被赞/被评也算
--      （与上面「知识类活跃用户数量」的处理方式一致）。
--   b. 帖子侧不过滤 status / deleted_at：本周产生的互动就是本周的真实互动量，
--      不因为帖子后来被删/被下架而抹掉。如只想看当前仍公开可见的帖子，
--      在两处 JOIN content_posts 后加 AND cp.status='PUBLISHED' AND cp.deleted_at IS NULL。
--   c. 【排除作者本人】的自赞/自评（cl.user_id <> 作者、c.author_id <> 作者），
--      否则运营账号自己操作会把数抬高。
--   d. 互动用户同样只算真实用户（排除 ADMIN / virtual: / seed-tailtopia- 账号）。
--   e. 评论只排除已软删（deleted_at IS NULL），不看 moderation_status——
--      被下架/被拒的评论仍视为发生过互动。
--   f. 账号用 users.email 匹配（大小写不敏感）。若某账号查不到（用户ID 为空），
--      说明该邮箱在库中不存在、或该用户已注销被匿名化（email 置空、快照进 deleted_email）。
-- ------------------------------------------------------------
WITH params AS (
    SELECT DATE '2026-07-27' AS week_start,
           DATE '2026-08-02' AS week_end
),
targets (email) AS (
    -- 要看的账号，直接在这里增删
    VALUES ('aria.zjw@gmail.com'),
           ('qingyin.zjw@gmail.com'),
           ('raffyleonard2021@gmail.com')
),
target_users AS (
    -- LEFT JOIN：邮箱查不到也保留一行，结果里显示 0 而不是整行消失
    SELECT t.email, u.id AS author_id
    FROM targets t
    LEFT JOIN users u ON lower(u.email) = lower(t.email)
),
real_users AS (
    SELECT u.id
    FROM users u
    WHERE u.role = 'USER'
      AND COALESCE(u.google_sub, '') NOT LIKE 'admin:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'virtual:%'
      AND COALESCE(u.google_sub, '') NOT LIKE 'seed-tailtopia-%'
),
engagers AS (
    -- 当周点赞过该账号帖子的用户
    SELECT tu.email, cl.user_id AS uid
    FROM target_users tu
    JOIN content_posts cp ON cp.author_id = tu.author_id
    JOIN content_likes cl ON cl.post_id = cp.id
    CROSS JOIN params p
    WHERE cl.created_at::date BETWEEN p.week_start AND p.week_end
      AND cl.user_id <> tu.author_id                 -- 排除自赞
    UNION
    -- 当周评论过该账号帖子的用户（含二级回复）
    SELECT tu.email, c.author_id
    FROM target_users tu
    JOIN content_posts cp ON cp.author_id = tu.author_id
    JOIN comments c ON c.post_id = cp.id
    CROSS JOIN params p
    WHERE c.deleted_at IS NULL
      AND c.created_at::date BETWEEN p.week_start AND p.week_end
      AND c.author_id <> tu.author_id                -- 排除自评
),
engagers_real AS (
    SELECT e.email, e.uid
    FROM engagers e
    JOIN real_users ru ON ru.id = e.uid
)
SELECT
    tu.email                   AS 账号邮箱,
    tu.author_id               AS 用户ID,
    COUNT(DISTINCT e.uid)      AS 活跃用户数量
FROM target_users tu
LEFT JOIN engagers_real e ON e.email = tu.email
GROUP BY tu.email, tu.author_id
ORDER BY 活跃用户数量 DESC, tu.email;
