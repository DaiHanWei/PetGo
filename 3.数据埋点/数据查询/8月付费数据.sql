-- ============================================================
-- 8 月付费数据（付费用户数 / 复购用户数 / 付费笔数 / 总收入）
-- 创建日期：2026-09-04
-- 说明：表名/字段名/枚举值已对照 db-schema-reference.md 核对。
--
-- ⚠️ 库选择：这是"实际有多少用户付了钱"的问题，必须查【正式库 petgo】，
--   不能查 staging 库 petgo_stag（那是测试数据，会员/金额都是假的）。
--   payment_intents 表随 V1.1 付费链路上线，8 月已在生产运行，正式库应已有该表。
--
-- 口径说明（本人判断，需运营/产品确认）：
--   1. 「付费」= payment_intents.status = 'PAID'（已到账的付款单）。
--      该表覆盖全部收费场景：VET_CONSULT 兽医问诊 / PAWCOIN_TOPUP 充值 /
--      AI_UNLOCK AI 详情解锁 / ID_HD 身份证高清图。
--   2. ⚠️ channel = 'PAWCOIN'（用站内 PawCoin 余额扣减消费，如问诊/解锁）
--      不产生 payment_intents 行（无外部收款），只有【真实花钱】的 QRIS
--      支付、以及 PawCoin 充值本身（PAWCOIN_TOPUP，channel=QRIS）会进本表。
--      即本表统计的是"真金白银流入平台"的笔数与金额，不含用户消费已充值
--      余额的行为（那部分钱已经在充值时统计过一次，此处不重复计收入）。
--   3. 「付费用户数」= 8 月内至少有一笔 PAID 记录的去重用户数。
--   4. 「复购用户数」= 8 月内 PAID 记录数 >= 2 的用户数（月内多次付费，
--      不是跨月复购）。
--   5. 「付费笔数」= 8 月内 PAID 记录总行数。
--   6. 「总收入」= 8 月内 PAID 记录 amount 之和，单位 IDR 最小单位
--      （无小数分位，如 50000 即 Rp50,000）。
--   7. 未排除 ADMIN / 虚拟种子账号——这类账号理论上不具备真实支付能力，
--      如需严格排除可加 real_users 过滤（写法见 运营周报数据.sql）。
--   8. 时区：created_at 存 UTC，此处按 UTC 自然月切；若要严格按印尼时间
--      （WIB, UTC+7）切月，把 created_at::date 换成
--      (created_at AT TIME ZONE 'Asia/Jakarta')::date。
-- ============================================================

WITH params AS (
    SELECT DATE '2026-09-01' AS month_start,
           DATE '2026-09-30' AS month_end   -- 含尾：统计到 8/31 当天
),
paid AS (
    SELECT pi.user_id, pi.amount
    FROM payment_intents pi
    CROSS JOIN params p
    WHERE pi.status = 'PAID'
      AND pi.created_at::date BETWEEN p.month_start AND p.month_end
),
per_user AS (
    SELECT user_id, COUNT(*) AS pay_times, SUM(amount) AS user_amount
    FROM paid
    GROUP BY user_id
)
SELECT
    (SELECT COUNT(*) FROM per_user)                        AS 付费用户数,
    (SELECT COUNT(*) FROM per_user WHERE pay_times >= 2)   AS 复购用户数_月内2次及以上,
    (SELECT COUNT(*) FROM paid)                             AS 付费总笔数,
    (SELECT COALESCE(SUM(amount), 0) FROM paid)             AS 总收入_IDR;

-- 如需按用途拆分收入（问诊/充值/解锁/身份证），把上面 paid 的 SELECT 加一列
-- pi.purpose，并在最终统计里加 GROUP BY purpose。
