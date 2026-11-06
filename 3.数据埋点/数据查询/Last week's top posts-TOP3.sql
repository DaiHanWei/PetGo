-- ============================================================
-- 上周热门帖子 TOP3（互动得分榜，同一用户只取最佳一条）
-- 创建日期：2026-07-31
-- 说明：本查询基于现有数据库表，不依赖任何新增埋点。
--       表名/字段名/枚举值已对照 db-schema-reference.md（staging 库 petgo_stag）核对。
--       互动得分口径沿用「内容运营所需数据.sql」「运营周报数据.sql」：点赞×1 + 评论×5。
--
-- 输出：3 行（互动得分 TOP1~TOP3），来自 3 个不同用户。
--       含帖子 id、发帖用户、帖子正文、点赞数、评论数、互动得分。
--
-- 口径说明（本人判断，需运营/产品确认是否符合预期）：
--   1. 「上一周」= 上一个完整的自然周（周一 ~ 周日）。今天是 2026-07-31（周五），
--      跑出来的窗口是 2026-07-20 ~ 2026-07-26。params 里已改成自动计算，
--      想查指定某一周，把 params 换成写死日期的那两行（见下方注释）。
--   2. 「在该周发布的帖子」= content_posts.created_at 落在窗口内，
--      且 status='PUBLISHED' AND deleted_at IS NULL（公开可见口径）。
--      审核中(UNDER_REVIEW)、作者已注销隐藏(AUTHOR_DEACTIVATED)、已删除的帖子不参与排名。
--   3. 点赞数/评论数取的是这些帖子【截至查询时刻累计收到】的互动，不限定互动发生在本周内
--      （与内容运营 SQL 的「今日帖子总得分」一致）。若只想算"周内产生的互动"，
--      把下方 like_cnt / comment_cnt 两个子查询里被注释掉的时间过滤打开即可。
--   4. 评论只算 deleted_at IS NULL 且 moderation_status='VISIBLE'（对他人可见的评论）；
--      content_likes 取消点赞是直接删行，无需额外过滤。
--   5. 榜单【排除】内部账号所发的内容（见 internal_users CTE：4 个官方昵称 + user id 81）。
--      注意这只排掉「内部账号发的帖」，不排「内部账号给别人点的赞/评的论」——
--      即真实用户的帖子若被官方号点赞评论，这些互动仍计入分数。
--      想把内部账号产生的互动也剔掉，把 like_cnt / comment_cnt 子查询里
--      "-- AND cl.user_id NOT IN (...)" / "-- AND cm.author_id NOT IN (...)" 两行的注释打开。
--   6. ⚠️ 除上述内部账号外，榜单仍【不】排除其他虚拟/种子账号所发的内容
--      （与周报的内容量口径一致）。若只想看真实用户发的帖，把下方
--      "-- AND u.account_type = 'REAL'" 这行的注释打开。
--   7. 【去重用户】同一用户在该周发了多条高分帖时，只取其得分最高的那一条参与排名，
--      所以 TOP3 一定来自 3 个不同用户。同一用户被"挤掉"的其他帖子不会出现在结果里。
--      想改回「纯按帖子排、允许同一用户占多个名次」，把 ranked 里
--      "WHERE b.rn_author = 1" 这行删掉即可。
--   8. 并列处理：分数相同时按「点赞多 → 评论多 → 发布时间早」排序取前 3
--      （同一用户内部选最佳一条也用这个规则），所以并列第 3 的帖子只会显示其中一条。
--
-- 时区提醒：created_at 存的是 UTC。此处按数据库会话时区切周，与既有 SQL 一致。
--   若需严格按印尼时间（WIB, UTC+7）切周，执行前先 SET TIME ZONE 'Asia/Jakarta';
-- ============================================================

WITH params AS (
    -- 上一个完整自然周：本周一往前推 7 天 = 上周一，+6 天 = 上周日
    SELECT (date_trunc('week', CURRENT_DATE) - INTERVAL '7 day')::date AS week_start,
           (date_trunc('week', CURRENT_DATE) - INTERVAL '1 day')::date AS week_end
    -- 查指定某一周时，改用下面这两行（并把上面两行注释掉）：
    -- SELECT DATE '2026-07-20' AS week_start,
    --        DATE '2026-07-26' AS week_end
),
internal_users AS (
    -- 内部账号（官方运营号），不参与热门榜排名。
    -- 按昵称匹配 + 按 id 兜底；昵称大小写/首尾空格做了容错，改名后请同步维护这里。
    -- 新增内部账号只需往下面的列表里加一行。
    SELECT u.id
    FROM users u
    WHERE lower(btrim(u.nickname)) IN (
              lower('TailUs by Tailtopia'),
              lower('TailTeman'),
              lower('TailCek'),
              lower('TailTips')
          )
       OR u.id IN (81)
),
week_posts AS (
    -- 本周发布的公开可见帖子 + 各自的累计点赞数/评论数/互动得分
    SELECT
        cp.id                                       AS post_id,
        cp.type                                     AS post_type,
        cp.created_at                               AS published_at,
        cp.text                                     AS post_text,
        COALESCE(jsonb_array_length(cp.image_urls), 0) AS image_count,
        cp.author_id,
        COALESCE(NULLIF(u.nickname, ''), NULLIF(u.display_name, ''), '（已注销/无昵称）') AS author_name,
        u.account_type                              AS author_account_type,
        COALESCE(l.like_cnt, 0)                     AS like_cnt,
        COALESCE(c.comment_cnt, 0)                  AS comment_cnt,
        COALESCE(l.like_cnt, 0) * 1
      + COALESCE(c.comment_cnt, 0) * 5              AS engagement_score
    FROM content_posts cp
    CROSS JOIN params p
    JOIN users u ON u.id = cp.author_id
    LEFT JOIN LATERAL (
        SELECT COUNT(*) AS like_cnt
        FROM content_likes cl
        WHERE cl.post_id = cp.id
          -- 只算周内产生的点赞时，打开下面一行：
          -- AND cl.created_at::date BETWEEN p.week_start AND p.week_end
          -- 不算内部账号点的赞时，打开下面一行：
          -- AND cl.user_id NOT IN (SELECT id FROM internal_users)
    ) l ON TRUE
    LEFT JOIN LATERAL (
        SELECT COUNT(*) AS comment_cnt
        FROM comments cm
        WHERE cm.post_id = cp.id
          AND cm.deleted_at IS NULL
          AND cm.moderation_status = 'VISIBLE'
          -- 只算周内产生的评论时，打开下面一行：
          -- AND cm.created_at::date BETWEEN p.week_start AND p.week_end
          -- 不算内部账号发的评论时，打开下面一行：
          -- AND cm.author_id NOT IN (SELECT id FROM internal_users)
    ) c ON TRUE
    WHERE cp.status = 'PUBLISHED'
      AND cp.deleted_at IS NULL
      AND cp.created_at::date BETWEEN p.week_start AND p.week_end
      -- 排除内部账号（官方号）发的帖，见 internal_users CTE
      AND cp.author_id NOT IN (SELECT id FROM internal_users)
      -- 只看真实用户发的帖时，打开下面一行：
      -- AND u.account_type = 'REAL'
),
best_per_author AS (
    -- 每个作者只留互动得分最高的那一条（同分则赞多 → 评论多 → 发布早）
    SELECT
        wp.*,
        ROW_NUMBER() OVER (
            PARTITION BY wp.author_id
            ORDER BY wp.engagement_score DESC, wp.like_cnt DESC, wp.comment_cnt DESC, wp.published_at ASC
        ) AS rn_author
    FROM week_posts wp
),
ranked AS (
    -- 去重后再按互动得分排全站名次
    SELECT
        b.*,
        ROW_NUMBER() OVER (
            ORDER BY b.engagement_score DESC, b.like_cnt DESC, b.comment_cnt DESC, b.published_at ASC
        ) AS rn
    FROM best_per_author b
    WHERE b.rn_author = 1   -- 删掉这行即恢复「纯按帖子排、同一用户可占多名」
)
SELECT
    p.week_start                AS "统计开始日 / Week Start",
    p.week_end                  AS "统计结束日 / Week End",
    r.rn                        AS "排名 / Rank",
    r.post_id                   AS "帖子ID / Post ID",
    CASE r.post_type
        WHEN 'DAILY'         THEN '日常分享 / Daily'
        WHEN 'GROWTH_MOMENT' THEN '成长日历快乐时刻 / Growth Moment'
        WHEN 'KNOWLEDGE'     THEN '专业科普 / Knowledge'
        ELSE r.post_type
    END                         AS "帖子类型 / Post Type",
    r.published_at              AS "发布时间 / Published At",
    r.author_id                 AS "作者ID / Author ID",
    r.author_name               AS "作者昵称 / Author Nickname",
    CASE r.author_account_type
        WHEN 'REAL'    THEN '真实用户 / Real'
        WHEN 'VIRTUAL' THEN '虚拟种子账号 / Virtual Seed'
        ELSE r.author_account_type
    END                         AS "作者账号类型 / Account Type",
    r.like_cnt                  AS "点赞数 / Likes",
    r.comment_cnt               AS "评论数 / Comments",
    r.engagement_score          AS "互动得分 / Engagement Score",
    r.image_count               AS "配图数 / Images",
    COALESCE(r.post_text, '（纯图帖，无正文）/ (image-only post)') AS "帖子内容 / Post Content"
FROM ranked r
CROSS JOIN params p
WHERE r.rn <= 3
ORDER BY r.rn;
