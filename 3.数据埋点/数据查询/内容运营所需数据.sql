-- ============================================================
-- 内容运营所需数据 SQL
-- 创建日期：2026-07-17 · 最近更新：2026-07-22
-- 说明：以下查询全部基于现有数据库表，不依赖任何新增埋点。
--       表名/字段名/枚举值已对照 db-schema-reference.md（staging 库 petgo_stag，56 张表）核对。
--
-- 口径（本人判断，需运营/产品确认是否符合预期）：
--   1. 「新增用户数」「总安装用户数」排除 role=ADMIN 和种子/虚拟账号——
--      通过 google_sub 前缀识别：admin: 开头 = 运营 ADMIN 账号，virtual: / seed-tailtopia- 开头 = 种子账号
--      （stag 库目前没有 account_type 列，等它上线后可以换成更直接的判断）。
--   2. 「发帖数/发帖用户数」只统计 status='PUBLISHED' AND deleted_at IS NULL 的公开可见帖子，
--      审核中(UNDER_REVIEW)、作者已注销隐藏(AUTHOR_DEACTIVATED)、已删除的帖子不计入。
--   3. 「评论数」只统计 deleted_at IS NULL 的评论（stag 库 comments 表暂时没有 moderation_status 列，
--      所以没有再加"审核通过"的过滤）。
--   4. content_likes 取消点赞是直接删行，没有软删标记，点赞数无需额外过滤。
--   5. 「当日发diary的建档用户数」中的 diary = content_posts.type='GROWTH_MOMENT'（成长日历快乐时刻），
--      且发帖人必须是 pet_profiles 的 owner（即已建档用户）。
--
-- 日报口径：
--   - 所有时间窗口的截止点统一是"查询当天的 00:00"，即"今日新增"实际统计的是上一个完整自然日
--     （比如 7/20 执行这条查询，看到的是 7/19 00:00 ~ 7/20 00:00 一整天，因为 7/20 还没走完，
--     统计还不完整，不适合拿来做日报）。
--   - 周一执行时自动补上周五、周六、周日三天（分天各一行，不合并求和），其他日期只有昨天一天。
--     判断逻辑：EXTRACT(DOW FROM CURRENT_DATE)，Postgres 里周日=0、周一=1……周六=6。
--
-- 两个指标的含义（本人推断，需运营/产品确认）：
--   - 总安装用户数：不是当天新增，而是"截至该天 24:00 为止"的累计注册用户数，放进每日一行的表里
--     是为了看累计增长趋势。
--   - 今日帖子总得分：指"当天新发布的帖子"，用它们目前累计收到的点赞×1+评论×5 算出来的总分，
--     衡量的是"这天发的内容质量/热度"，跟「总互动得分」不同——后者统计的是"当天发生的互动"
--     （不管被互动的帖子是哪天发的）。
--
-- 次日留存：数据库没有登录/打开 App 日志表（真正的登录事件只进 PostHog，不落库，
--   见 埋点文件/analytics-posthog-tracking.md），所以这份 SQL 不包含次日留存，改去 PostHog 里查。
-- ============================================================

WITH report_days AS (
    SELECT gs::date AS report_date
    FROM generate_series(
        CURRENT_DATE - (CASE WHEN EXTRACT(DOW FROM CURRENT_DATE) = 1 THEN 3 ELSE 1 END),
        CURRENT_DATE - INTERVAL '1 day',
        INTERVAL '1 day'
    ) AS gs
),
new_users_by_day AS (
    SELECT rd.report_date, COUNT(u.id) AS new_users
    FROM report_days rd
    LEFT JOIN users u
      ON u.created_at::date = rd.report_date
     AND u.role = 'USER'
     AND COALESCE(u.google_sub, '') NOT LIKE 'admin:%'
     AND COALESCE(u.google_sub, '') NOT LIKE 'virtual:%'
     AND COALESCE(u.google_sub, '') NOT LIKE 'seed-tailtopia-%'
    GROUP BY rd.report_date
),
total_installs_by_day AS (
    SELECT rd.report_date,
        (SELECT COUNT(*)
         FROM users u2
         WHERE u2.created_at::date <= rd.report_date
           AND u2.role = 'USER'
           AND COALESCE(u2.google_sub, '') NOT LIKE 'admin:%'
           AND COALESCE(u2.google_sub, '') NOT LIKE 'virtual:%'
           AND COALESCE(u2.google_sub, '') NOT LIKE 'seed-tailtopia-%'
        ) AS total_installed_users
    FROM report_days rd
),
posts_by_day AS (
    SELECT rd.report_date,
        COUNT(DISTINCT cp.author_id) AS posting_users,
        COUNT(cp.id)                 AS new_posts
    FROM report_days rd
    LEFT JOIN content_posts cp
      ON cp.created_at::date = rd.report_date
     AND cp.status = 'PUBLISHED'
     AND cp.deleted_at IS NULL
    GROUP BY rd.report_date
),
profiles_by_day AS (
    SELECT rd.report_date, COUNT(pp.id) AS new_pet_profiles
    FROM report_days rd
    LEFT JOIN pet_profiles pp
      ON pp.created_at::date = rd.report_date
    GROUP BY rd.report_date
),
cumulative_pet_owners_by_day AS (
    -- 累计建档用户数：截至该天 24:00 为止，累计拥有至少一个 pet_profiles 的去重用户数（同一用户建多个档只算一次）
    SELECT rd.report_date,
        (SELECT COUNT(DISTINCT pp2.owner_id)
         FROM pet_profiles pp2
         WHERE pp2.created_at::date <= rd.report_date
        ) AS cumulative_pet_owners
    FROM report_days rd
),
diary_posters_by_day AS (
    -- 建档用户中，当日发过 diary（GROWTH_MOMENT 成长日历快乐时刻）的人数；发帖人必须是 pet_profiles 的 owner
    SELECT rd.report_date, COUNT(DISTINCT cp.author_id) AS pet_owner_diary_posters
    FROM report_days rd
    LEFT JOIN content_posts cp
      ON cp.created_at::date = rd.report_date
     AND cp.status = 'PUBLISHED'
     AND cp.deleted_at IS NULL
     AND cp.type = 'GROWTH_MOMENT'
     AND EXISTS (SELECT 1 FROM pet_profiles pp WHERE pp.owner_id = cp.author_id)
    GROUP BY rd.report_date
),
interactions_raw AS (
    SELECT post_id, 'like' AS source, created_at FROM content_likes
    UNION ALL
    SELECT post_id, 'comment' AS source, created_at FROM comments WHERE deleted_at IS NULL
),
interaction_by_day AS (
    SELECT rd.report_date, COUNT(DISTINCT ir.post_id) AS posts_with_interaction
    FROM report_days rd
    LEFT JOIN interactions_raw ir ON ir.created_at::date = rd.report_date
    GROUP BY rd.report_date
),
silent_posts_by_day AS (
    -- 今日沉默帖子数：当天发布(status='PUBLISHED' 且未删除)、且当天完全没有收到互动（0 点赞、0 评论）的帖子数。
    -- 互动的判定口径与其他指标一致：只看 created_at 落在当天的点赞/评论（评论已过滤 deleted_at IS NULL）。
    SELECT rd.report_date, COUNT(cp.id) AS silent_posts
    FROM report_days rd
    LEFT JOIN content_posts cp
      ON cp.created_at::date = rd.report_date
     AND cp.status = 'PUBLISHED'
     AND cp.deleted_at IS NULL
     AND NOT EXISTS (
         SELECT 1 FROM interactions_raw ir
         WHERE ir.post_id = cp.id
           AND ir.created_at::date = rd.report_date
     )
    GROUP BY rd.report_date
),
engagement_by_day AS (
    SELECT rd.report_date,
        COALESCE(SUM(CASE WHEN ir.source = 'like'    THEN 1 ELSE 0 END), 0) * 1
      + COALESCE(SUM(CASE WHEN ir.source = 'comment' THEN 1 ELSE 0 END), 0) * 5 AS total_engagement_score
    FROM report_days rd
    LEFT JOIN interactions_raw ir ON ir.created_at::date = rd.report_date
    GROUP BY rd.report_date
),
post_score_by_day AS (
    -- 今日帖子总得分：当天新发布的帖子，用它们目前累计（不限时间）的点赞×1+评论×5 求和
    SELECT rd.report_date,
        COALESCE(SUM(
            COALESCE(l.like_count, 0)    * 1
          + COALESCE(c.comment_count, 0) * 5
        ), 0) AS posts_total_score
    FROM report_days rd
    LEFT JOIN content_posts cp
      ON cp.created_at::date = rd.report_date
     AND cp.status = 'PUBLISHED'
     AND cp.deleted_at IS NULL
    LEFT JOIN (
        SELECT post_id, COUNT(*) AS like_count
        FROM content_likes
        GROUP BY post_id
    ) l ON l.post_id = cp.id
    LEFT JOIN (
        SELECT post_id, COUNT(*) AS comment_count
        FROM comments
        WHERE deleted_at IS NULL
        GROUP BY post_id
    ) c ON c.post_id = cp.id
    GROUP BY rd.report_date
),
all_posts_avg_score AS (
    -- 全部帖子全量平均分：不分天，统计截至"查询当天00:00"为止的全部公开可见帖子及其历史互动，累计得分取平均——
    -- 跟其他指标的截止点保持一致，避免同一天内多次运行结果不一样；每天这一列都是同一个数，仅作参考基准
    SELECT AVG(
        COALESCE(l.like_count, 0)    * 1
      + COALESCE(c.comment_count, 0) * 5
    ) AS avg_score
    FROM content_posts p
    LEFT JOIN (
        SELECT post_id, COUNT(*) AS like_count
        FROM content_likes
        WHERE created_at::date < CURRENT_DATE
        GROUP BY post_id
    ) l ON l.post_id = p.id
    LEFT JOIN (
        SELECT post_id, COUNT(*) AS comment_count
        FROM comments
        WHERE deleted_at IS NULL AND created_at::date < CURRENT_DATE
        GROUP BY post_id
    ) c ON c.post_id = p.id
    WHERE p.status = 'PUBLISHED' AND p.deleted_at IS NULL
      AND p.created_at::date < CURRENT_DATE
),
all_time_engagement_score AS (
    -- 总互动得分_全部历史：不分天，统计截至"查询当天00:00"为止的全部历史点赞×1+评论×5 的总和——
    -- 跟其他指标的截止点保持一致；每天这一列都是同一个数，仅作参考基准
    SELECT
        (SELECT COUNT(*) FROM content_likes WHERE created_at::date < CURRENT_DATE) * 1
      + (SELECT COUNT(*) FROM comments WHERE deleted_at IS NULL AND created_at::date < CURRENT_DATE) * 5 AS total_engagement_score_all_time
),
daily_interaction_per_post AS (
    -- 当天有互动的帖子，各自当天新产生的点赞/评论次数（不是帖子的累计总数）
    SELECT rd.report_date, ir.post_id,
        SUM(CASE WHEN ir.source = 'like'    THEN 1 ELSE 0 END) AS today_likes,
        SUM(CASE WHEN ir.source = 'comment' THEN 1 ELSE 0 END) AS today_comments
    FROM report_days rd
    JOIN interactions_raw ir ON ir.created_at::date = rd.report_date
    GROUP BY rd.report_date, ir.post_id
),
daily_interaction_avg_by_day AS (
    -- 当日互动帖子平均得分：只看当天有互动的帖子，按它们当天新增的点赞×1+评论×5 取平均
    SELECT rd.report_date,
        AVG(dip.today_likes * 1 + dip.today_comments * 5) AS interacted_posts_avg_score_today
    FROM report_days rd
    LEFT JOIN daily_interaction_per_post dip ON dip.report_date = rd.report_date
    GROUP BY rd.report_date
)
SELECT
    rd.report_date                       AS 日期,
    nu.new_users                         AS 新增用户数,
    ti.total_installed_users             AS 总安装用户数_累计,
    p.posting_users                      AS 发帖用户数,
    p.new_posts                          AS 新增帖子数,
    pf.new_pet_profiles                  AS 新增建档用户数,
    cpo.cumulative_pet_owners            AS 累计建档用户数,
    dp.pet_owner_diary_posters           AS 当日发diary的建档用户数,
    ib.posts_with_interaction            AS 有互动的帖子数,
    sp.silent_posts                      AS 今日沉默帖子数,
    eb.total_engagement_score            AS 总互动得分,
    ps.posts_total_score                 AS 今日帖子总得分,
    apa.avg_score                        AS 全部帖子全量平均分,
    dia.interacted_posts_avg_score_today AS 当日互动帖子平均得分,
    ate.total_engagement_score_all_time  AS 总互动得分_全部历史
FROM report_days rd
JOIN new_users_by_day        nu  ON nu.report_date  = rd.report_date
JOIN total_installs_by_day   ti  ON ti.report_date  = rd.report_date
JOIN posts_by_day            p   ON p.report_date   = rd.report_date
JOIN profiles_by_day         pf  ON pf.report_date  = rd.report_date
JOIN cumulative_pet_owners_by_day cpo ON cpo.report_date = rd.report_date
JOIN diary_posters_by_day    dp  ON dp.report_date  = rd.report_date
JOIN interaction_by_day      ib  ON ib.report_date  = rd.report_date
JOIN silent_posts_by_day     sp  ON sp.report_date  = rd.report_date
JOIN engagement_by_day       eb  ON eb.report_date  = rd.report_date
JOIN post_score_by_day       ps  ON ps.report_date  = rd.report_date
JOIN daily_interaction_avg_by_day dia ON dia.report_date = rd.report_date
CROSS JOIN all_posts_avg_score apa
CROSS JOIN all_time_engagement_score ate
ORDER BY rd.report_date;
