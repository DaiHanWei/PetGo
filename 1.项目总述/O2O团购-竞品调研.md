# 印尼「团购 / 本地生活预付券」竞品调研（宠物服务方向）

- 调研日期：2026-11-26
- 方法：公开网页搜索 + 部分页面直读。凡写「未查到」「不确定」的地方，就是公开资料里没找到可靠出处，不要当成结论。
- 说明：第 4 节资金流与合规只是信息梳理，**不是法律或税务意见**，上线前要找印尼律师 / 税务顾问和支付网关的合规团队确认。

---

## 0. 一页结论

1. **印尼没有一家专门做「本地生活团购」的平台还活着。** Fave（前身是 Groupon Indonesia）2023-04-01 退出印尼；现在的玩家都是大平台顺带做的：Grab Dine Out、Gojek GoDineIn、ShopeeFood Deals（这三家都只做餐饮），Traveloka Xperience / tiket.com To Do（以旅游景点为主，也有 spa / 美容）。宠物服务团购这个空白目前没人占。
2. **各家佣金率基本都不公开。** 目前唯一公开的费用结构是 Grab Dine Out：分「代金券服务费 + 折扣服务费 + MDR（支付手续费）」三项，打款时间是**交易后不超过 3 个工作日**。其他平台的具体费率都未查到。
3. **印尼宠物服务线上化程度很低。** 能查到的只有小型预约 / 上门 App（Petskita、PETO、Pompy Go 等）和 Halodoc 的兽医在线问诊，**没有哪家在做预付券**。东南亚可参考的是菲律宾 PetPal（年费会员 + 按次付费）和马来西亚 Petotum（先做门店 SaaS，再收交易服务费）。
4. **资金流上，主流做法是「接持牌支付网关的分账 / 子账户」，不自己沉淀资金。** Xendit（2020 年拿到 BI 的支付网关牌照）的 xenPlatform 支持主账户代收、按规则分账到商家子账户并扣佣金。BI 2025 年第 10 号条例（PBI 10/2025）已于 2026-03-31 生效，取代了 PBI 22/23/2020。至于平台代收再结算给商家需不需要自己的 PJP（支付服务商）许可，**没查到明确的公开解读**，必须找律师确认。
5. **税务上，「代金券本身不征 PPN（增值税），只对平台的服务费 / 佣金征」是现行口径**（PMK 6/2021 把代金券视为等同货币的支付工具；PMK 71/2022 对「以代金券为媒介的营销服务」规定了按券售价计征的特定比例）。另外，电商平台代扣卖家 0.5% 所得税（PPh 22）的 PMK 37/2025 已经推迟了好几次，目前状态不确定。

---

## 1. 印尼本地团购 / 本地生活优惠平台

### 1.1 总览表

| 平台 | 现状 | 品类 | 核销方式 | 退款 | 佣金 / 费率 | 结算周期 | 商家入驻 |
|---|---|---|---|---|---|---|---|
| **Fave**（Pine Labs 旗下） | **已退出印尼**（2023-04-01 生效） | 原来覆盖餐饮、美容、休闲等全品类 | 原来是 App 内券码 + FavePay 扫码付 | 未查到印尼的历史规则 | 按笔抽佣，印尼费率**未查到**；马来西亚 / 新加坡帮助中心的示例是 1% 的「Fave fee」+ 返现，但那是 FavePay 的扫码付费，不是团购券 | 未查到 | 原来以地推 BD 签约为主 |
| **Traveloka Xperience** | 在运营 | 景点、旅游项目、美容 & spa、活动 | 电子券（App 里的 My Booking），到店出示 | 2021 年起部分商品支持「Easy Refund」一键退；其他按单品政策；门店关门时自动换发延期券 | 供应商佣金**未查到**（网上流传的 3.5–4.8% 是**联盟推广**佣金，不是商家佣金） | 未查到 | 通过 AXES 后台自助注册，或发邮件给合作团队 |
| **tiket.com To Do** | 在运营 | 景点、活动 | 电子票，到场出示 | 按各商家自己的政策；另卖付费「100% 退款」保险产品（最多保 85%，单笔上限 Rp5 juta / 500 万印尼盾） | 未查到 | 未查到 | 有合作伙伴后台和「Preferred Partner」计划 |
| **Grab Dine Out**（原 Dine In Deals → GrabFood Dine Out Deals） | 在运营，2024-08 起扩大，加了订座功能 | **只做餐饮** | 用户在 Grab App 的 Dine Out 里买券，到店核销 / 用 App 付款时自动抵扣 | 条款没写；有一条搜索摘要说「30 天有效、100% 退款保证」，但读原新闻稿没找到这句 → **不确定** | 三项：Voucher Service Fee（按核销面额，扣掉商家出资部分后计）、Discount Service Fee、MDR；费用含税；新商家可能有补贴（co-funding）和试用佣金；具体费率**未公开** | **交易后不超过 3 个工作日**，打到银行账户或 OVO，转账费由商家承担 | 商家在 GrabMerchant App 的营销模块自助开通，或留资料等 BD 联系 |
| **Gojek GoDineIn** | 2024-07 在雅加达上线；2026-02 还在 Blok M Hub 合作里出现，说明仍在运营 | **只做餐饮**，最高 25% 折扣 | App 内买券 → 到店点「Redeem」→ 给收银员看二维码 | 未查到 GoDineIn 专门的退款规则 | 未查到 | 未查到 | 上线时是精选餐厅（Common Grounds、Kintaro Sushi 等），看起来是 BD 签约 |
| **ShopeeFood Deals / Shopee 电子券** | 在运营 | 印尼能查到的主要是餐饮（如 2025-06 HokBen Rp1 券）；马来西亚 / 菲律宾 / 新加坡的 Shopee 电子券有餐饮、服务、酒店、娱乐等类目 | 在 App 里出示券码给店员（这是马来西亚帮助中心的流程，印尼**未核实**） | 有博客说 ShopeeFood Deals 的券可以退，**未核实官方条款** | 未查到 | 未查到 | 未查到 |
| **Tokopedia（现与 TikTok Shop 合并）电子券** | 不确定 | 没查到「到店服务券」作为一个独立类目 | 未查到 | 未查到 | 平台通用佣金 6.97%，但「数字产品」等类目除外（2025-09 报道），服务券的费率**未查到** | 未查到 | — |

### 1.2 逐个说明

**Fave（已退出）**
- 2016 年 Fave 收购了 Groupon 在印尼、马来西亚、新加坡的业务，2017 年 Groupon Indonesia 改名 Fave Indonesia。当时全部约 1,200 个上架商家里，近 70% 在大雅加达（Jabodetabek）。来源：[Jakarta Post 2017-05-09](https://www.thejakartapost.com/news/2017/05/09/groupon-indonesia-changes-name-eyes-smaller-cities.html)、[DailySocial 2017](https://en.dailysocial.id/post/Indonesia-fave-group-strategy-2017)
- 2021 年被 Pine Labs 以约 4,500 万美元收购。来源：[TechCrunch 2021-04-13](https://techcrunch.com/2021/04/13/pine-labs-acquires-southeast-asian-startup-fave-for-45-million/embed/)
- **2023-04-01 起退出印尼**，官方说法是「集中资源做新加坡、马来西亚、印度这几个核心市场」，印尼网站上的团购和代金券全部下架，也没有正式公告。来源：[Marketing-Interactive 2023-05-03](https://www.marketing-interactive.com/fave-abruptly-exits-indonesian-market-as-it-looks-to-focus-on-other-regions)
- 退出的具体原因（亏损规模、返现成本）**未查到**。背景信息：Fave 的模式靠返现驱动（[The Ken](https://the-ken.com/sea/story/malaysias-fave-struggles-to-get-cashback-train-on-track/)）；同期印尼大平台都在收缩补贴（[Jakarta Post 2023-12-28](https://www.thejakartapost.com/business/2023/12/28/yearender-less-discounting-fewer-players-for-indonesia-e-commerce-in-2023)）。「补贴退潮 + 钱包巨头竞争」是合理推断，但**没有直接出处**。
- 收费模式：每张团购券抽佣，FavePay 每笔另收小额费用，费率没公开。来源：[KrASIA 对 CEO 的访谈](https://kr-asia.com/fave-is-on-its-way-to-be-southeast-asias-first-merchant-super-app-qa-with-joel-neoh)、[Fave 商家帮助中心](https://favepartner.zendesk.com/hc/en-us/articles/9161626390809-How-does-Fave-charge-per-transaction)（这个页面直接打开是 403，内容来自搜索摘要，适用于马来西亚 / 新加坡）

**Traveloka Xperience**
- 商家入口：在 AXES（axes.traveloka.com）注册，覆盖景点、美容 & spa、旅游项目等。页面上没写佣金、结算和核销工具，要另外联系 partnership@traveloka.com。来源：[Traveloka 合作页](https://www.traveloka.com/en-id/partnership)（2026-11 查阅）
- 平台上已经有雅加达周边的 spa / 美容门店，比如 PuteriSpa BSD、Martha Tilaar Salon Day Spa（PIK）。来源：[商品页示例](https://www.traveloka.com/en-en/activities/indonesia/product/8170062389033)
- 用户端规则：券在有效期内都能用；门店关门或遇到社会限制时，自动发一张延期的新券。来源：[Xperience 购买须知](https://www.traveloka.com/en-sg/explore/activities/xperience-epic-sale-2022-faq/137359)（2022）。2021 年推出「Easy Refund」，符合条件的订单在 My Booking 里直接点退款（原页面现在 404，来源是搜索摘要）。
- 联盟推广佣金 3.5–4.8%，来源是第三方联盟平台 [Ecomobi](https://ecomobi.com/traveloka-affiliate-indonesia-new-highest-commission)，**不是商家佣金**。
- 搜了 Traveloka 上的宠物美容 / 宠物酒店，**没找到上架商品**。

**tiket.com To Do**
- 退款按各商家自己的政策；tiket.com 另卖付费的「To Do 100% Refund」保险，只保不可退的部分，最多退票价的 85%，上限 Rp5 juta。来源：[tiket.com](https://www.tiket.com/en-sg/info/todo-100-percent-refund-insurance)
- tiket FLEXI：用户先买一张灵活日期的券，到 To Do 合作商家那里出示核销，**不能退款也不能兑现**；商家可以在旺季加价。来源：[tiket FLEXI](https://www.tiket.com/info/tiket-flexi)
- 商家佣金和结算周期**未查到**。

**Grab Dine Out（目前机制公开得最清楚的参照对象）**
- 2024-08-15 新闻稿：Dine In Deals 改名 GrabFood Dine Out Deals，覆盖「上万家」餐厅、50 多个城市，合作商家一年增长超过 400%；有两种形式：整单直接打折（Diskon Total Bill），或买 Dine Out 代金券。来源：[Grab 新闻稿](https://www.grab.com/id/en/press/others/transformasi-dine-in-deals-di-grab-jadi-grabfood-dine-out-deals-diskon-hingga-50-untuk-makan-di-belasan-ribu-resto/)
- 商家条款（页面日期 2026-03-16）：费用分三项（Voucher Service Fee 按核销面额扣掉商家出资部分后计；Discount Service Fee 按扣掉商家出资后的最终价计；MDR 按支付方式计）；**费用含税**，税率上调时 Grab 可以书面通知调价；**Grab 扣完服务费后，不晚于交易后 3 个工作日打款**，转账费由商家承担；具体销售期和核销期由双方邮件确认。来源：[Dine Out 条款](https://www.grab.com/id/en/terms-policies/dine-out-terms-and-conditions/)
- 商家端：至少有一家实体堂食门店就能申请，在 GrabMerchant App 的「Marketing」里自助建活动；新商家可能有补贴和试用佣金。来源：[Grab 商家页](https://www.grab.com/id/en/merchant/in-store-solutions-2/)
- 2023 年 CNBC 报道：Grab 和 foodpanda 在外卖增长放缓后转做到店，Grab 在新加坡、泰国、印尼 15 个城市测试过最高 5 折的到店券，收入来自每张券的佣金。来源：[CNBC 2023-08-03](https://www.cnbc.com/2023/08/03/food-delivery-apps-grab-and-foodpanda-expand-into-dine-in-services.html/)

**Gojek GoDineIn**
- 2024-07 在雅加达上线，到店餐饮券最高 25% 折扣，只能在 Gojek App 里买；核销方式是在 App 里点 Redeem，给收银员看二维码。来源：[Jakarta Post 2024-07-12](https://www.thejakartapost.com/business/2024/07/12/meet-godinein-from-gojek-your-go-to-companion-to-dine-out-with-discount-voucher-up-to-25)、[Katadata 2024-07](https://katadata.co.id/amp/digital/startup/668fa8b6a61ed/tutup-gofood-festival-pada-2020-gojek-luncurkan-godinein/)（报道里提到 GoFood Festival 2020 年关闭）
- 2026-02 GoTo 和 MRT Jakarta 合作的 Blok M Hub 里仍在推 GoDineIn 到店券。来源：[GoTo 新闻稿](https://www.gotocompany.com/en/news/press/goto-and-mrt-jakarta-collaborate-to-launch-blok-m-hub-gojek-to-drive-the-local-economy)
- 商家规模、佣金、退款规则**未查到**。

**Shopee / Tokopedia**
- Shopee 在马来西亚、菲律宾、新加坡的「Digital Products」里有 e-voucher（电子代金券），类目包括餐饮、零售、服务、酒店、娱乐；核销方式按券各自说明，到店的一般是给店员出示券码，核销出问题找 Shopee 在线客服。来源：[Shopee PH](https://help.shopee.ph/4/article/82892-%5BDigital-Products%5D-What-are-e-vouchers)、[Shopee MY](https://help.shopee.com.my/portal/4/article/78933-[Digital-Product]-How-to-use-Food-Services-Vouchers-purchased-from-Prepaid,-Bills-Tickets-at-the-store)
- 印尼能查到的是 ShopeeFood Deals 的到店券（如 2025-06 HokBen Rp1 券，指定门店使用）。来源：[Republika 2025-06-18](https://ekonomi.republika.co.id/berita/sy1ofb472/cuma-satu-hari-saja-makan-hokben-hemat-cuma-rp1-dengan-voucher)。印尼「服务类电子券」的商家规则**未查到**。
- Tokopedia：2025-10-01 起 Mall 商家佣金上调；普通商家平台佣金 6.97%，但数字产品等类目除外。来源：[Katadata 2025-09](https://katadata.co.id/amp/digital/e-commerce/68d4b36c592d9/biaya-admin-penjual-kategori-mall-di-tokopedia-naik-per-1-oktober/)。另外 2025-08-11 起 Shopee、Tokopedia、TikTok Shop 都对卖家加收每单 Rp1.250 的订单处理费。来源：[Bisnis.com 2025-08-11](https://teknologi.bisnis.com/read/20250811/266/1901232/tokopedia-tiktok-mulai-berlakukan-biaya-seller-rp1250-per-transaksi-hari-ini)。**电子服务券是否收这笔费用：不确定。**
- 2026-01 UMKM（中小微企业）部表示，平台向中小商家收管理费的上限规定还没出台，正在研究。来源：[Jakarta Post 2026-01-24](https://www.thejakartapost.com/business/2026/01/24/e-commerce-sellers-wait-for-tighter-rules-on-platform-fees)、[Bisnis 2026-01-27](https://teknologi.bisnis.com/read/20260127/84/1947675/respons-bos-tokopedia-tiktok-shop-soal-rencana-pengaturan-biaya-admin-pedagang)。**这对我们的佣金定价是潜在的监管变量。**

### 1.3 小结：谁还活着、谁退了
- **退出的**：独立团购平台 Fave（2023）。更早的 Groupon Indonesia 在 2016 年被 Fave 收购。
- **还活着的**：都是超级 App 或 OTA（在线旅游平台）里的一个功能，靠主 App 的流量和支付体系撑着，主要做餐饮或旅游。
- **启示**：在印尼，靠「独立团购 App + 补贴拉新」这条路已经有先例走不通；附着在已有高频场景上的做法活了下来。我们是有社区和成长档案的宠物 App，属于「垂直场景 + 已有用户」，这一点上比 Fave 有利。

---

## 2. 印尼和东南亚的宠物服务线上平台

| 平台 | 国家 | 模式 | 收费 | 规模 | 来源 / 日期 |
|---|---|---|---|---|---|
| **Petskita** | 印尼 | 宠物用品 + 服务目录（宠物医院、宠物酒店、美容沙龙、保险、训练、运输、遛狗），**在线预约** | 未查到 | 早期阶段，2020-02 上线 | [Koala 公司档案](https://getkoala.com/companies/petskita.com)（无日期）、[Wellfound](https://wellfound.com/company/petskita) |
| **PETO** | 印尼 + 马来西亚 | 上门美容、遛狗、清洁笼子、兽医、宠物运输、领养，**预约制** | 未查到 | 未查到 | [App Store](https://apps.apple.com/us/app/id1089123108)（日期不明） |
| **Pompy Go** | 印尼（大雅加达） | 大学生创业项目，预约美容、遛狗、寄养、接送；计划和宠物店 / 宠物酒店合作 | 未查到 | 小 | [UMN 毕业论文](https://kc.umn.ac.id/id/eprint/42948/4/BAB_III.pdf)（2025） |
| **Pocket Pet** | 印尼（雅加达） | 宠物服务、问诊、病历 | 未查到 | 种子轮，2019 年成立 | [CB Insights](https://www.cbinsights.com/company/pocket-pet) |
| **Kamipetz** | 印尼 | 兽医服务 | 未查到（原文 403） | 未查到 | [Jakarta Post 2022-01-21](https://www.thejakartapost.com/front-row/2022/01/21/kamipetz-aims-to-ease-veterinarian-care-for-all.html) |
| **Halodoc 兽医** | 印尼 | 在线问诊（图文 / 视频），**按次付费** | 2020 年每次 Rp25.000；现在医生页显示约 Rp35.000–75.000 | 覆盖全国 | [KrASIA 2020-11-04](https://kr-asia.com/halodoc-launches-online-vet-consultation-more-services-to-come-cmo)、[Halodoc 兽医频道](https://www.halodoc.com/tanya-dokter/kategori/dokter-hewan)（2026-11 查阅） |
| 线下连锁（Pet Kingdom 等） | 印尼 | 门店 + Instagram + 电商店铺 | — | — | [Little Steps Asia](https://www.littlestepsasia.com/jakarta/family-life/pets/pet-food-and-supplies-stores)；**没查到连锁店自己做的预约或会员 App** |
| **PetPal**（917Ventures 旗下） | 菲律宾 | 远程问诊 + 上门兽医 + 门诊预约 + 上门美容；**按次付费 + 年费会员** | 远程问诊 P385、上门 P550、上门美容 P750；PetPal Club 年费 P2,499（含无限次问诊、1 次上门、疫苗折扣） | 1,500 多名兽医、500 家合作诊所；服务过 1 万只宠物 | [Daily Tribune 2024-01-21](https://tribune.net.ph/2024/01/21/presenting-phls-first-all-in-one-pet-care-super-app) |
| **Petotum** | 马来西亚 | 先给美容店 / 宠物酒店 / 诊所做 SaaS（预约 + 收款），再做用户端；**收交易服务费** | 费率未公开 | 约 1 万名宠物主人；B 端业务 2021-08 月环比增长 250% | [Vulcan Post 2021-09-24](https://vulcanpost.com/762911/petotum-online-pet-grooming-medical-hotel-booking-malaysia)（合作稿，数字是公司自报） |
| **Mypetslibrary / JomPaw** | 马来西亚 | 认证商家生态 / 寄养、日托、遛狗撮合 | 未查到 | 未查到 | [Mypetslibrary 博客](https://mypetslibrary.com/blog/detail/how-mypetslibrary-is-building-trust-in-malaysias-pet-industry) |
| **美团宠物**（对照） | 中国 | 团购 + 医院榜单 + 宠物保险 | — | 2026-08 报道：宠物团购商品同比增长 51%，交易额同比增长 76%；把 13 个常见病诊疗项目做成标准化套餐 | [上海证券报 2026-08-19](https://finance.eastmoney.com/a/202608193846221861.html) |

**结论**：印尼的宠物服务线上平台**全是预约制或按次付费**，没有一家在做「预付团购券」；规模都很小，也没有 2025–2026 年的融资或用户规模报道。美团在中国的经验是：**把诊疗项目标准化成套餐**是宠物医疗类目能卖团购的前提。

---

## 3. 美团团购关键机制（对照）

| 机制 | 内容 | 来源 |
|---|---|---|
| 随时退 / 过期退 | 美团 2011-03 推出「过期未消费包退」，2012 年前后把「过期退、随时退、免预约」作为卖点。现在过期没用的券会系统自动退款 | [人人都是产品经理](https://www.woshipm.com/operate/6478873.html)、[投资界 2015-09](https://news.pedaily.cn/201509/20150907387965.shtml)、[人人都是产品经理 2025-06-12](https://www.woshipm.com/operate/6229004.html) |
| 过期退款的坑 | 2025-08 有博主反映美团历史订单显示「过期自动退」但钱没到账（多是 2014–2019 年的订单）。说明**自动退款要做到账核对和状态提醒** | [IT 之家 2025-08-24](https://www.ithome.com/0/877/619.htm) |
| 佣金 / 技术服务费 | 按（用户实付 + 美团承担的优惠）× 费率计算，文章举例用的是 5%；**各类目官方费率没公开**。行业文章里常见的外卖基础佣金 6–8% 是外卖口径，不能直接套到团购上 | [人人都是产品经理 2025-06-12](https://www.woshipm.com/operate/6229004.html)、[虎嗅](https://www.huxiu.com/article/4895517.html) |
| 结算 | **按核销结算**（只结已核销的部分，扣掉退款）；每周出账单，商家申请提现；连续 4 周没提，平台自动帮商家提 | 同上 |
| 核销工具 | 商家 App 扫二维码验券 / 手动输入券码；一个订单多张券可以一次验完；一周内验错的可以撤销；也可以接入第三方收银 SaaS（如微盟）核销 | [美团门票商家 App](https://apps.apple.com/cn/app/id1133443077)、[美团境外商家 App](https://apps.apple.com/py/app/%E7%BE%8E%E5%9B%A2%E5%A2%83%E5%A4%96%E5%95%86%E5%AE%B6/id1327175580)、[驱动之家（微盟打通）](https://news.mydrivers.com/1/1066/1066571.htm) |
| 核销率 | 行业文章说美团核销率 80–90%，抖音本地生活约 50%（「冲动买、不去用」是内容平台团购的通病） | [36 氪](https://www.36kr.com/p/3769328471536384) |
| 早期地推 / 冷启动 | 千团大战时期：地推 BD 扫街签约，「小城市垄断供给、大城市争夺需求」，在不同阶段选直营还是代理开城；早期定位是「帮中小商家在线上引流到店」，不是纯补贴；2015 年和大众点评合并后拿到约 8 成份额。**具体的地推团队人数、签约补贴标准未查到** | [新浪财经 2021-01-27](https://finance.sina.cn/2021-01-27/detail-ikftssap1165562.d.html)、[虎嗅](https://www.huxiu.com/article/4858607.html) |

---

## 4. 资金流与合规（信息梳理，非法律 / 税务意见）

### 4.1 支付牌照
- **监管框架换代**：PBI 22/23/2020（支付系统条例）已被 **PBI 10/2025（支付系统行业条例）** 取代，2025-12-24 发布，**2026-03-31 生效**，配套的实施细则是 PADG 32/2025。新框架把牌照按「业务包」分：Package 1（资金来源管理，比如电子钱包，加交易路由）、Package 2（交易路由，比如收单和支付网关，加转账）、Package 3（只做汇款 / 转账）；另外把服务商分成「主要服务商」和其他服务商。已经持牌的服务商一年内重新分类。来源：[BI 官网 PBI 10/2025](https://www.bi.go.id/id/publikasi/peraturan/Pages/PBI_102025.aspx)、[Veritas 2026-01-09](https://veritask.ai/en/artikel/bank-indonesia-regulation-number-10-of-2025-reorganizing-the-payment-system-industry)、[Crowe](https://www.crowe.com/id/news/memahami-tikmi-dan-kewajiban-psp-dalam-pbi-10-2025)
- 旧框架下（PBI 23/6/2021），一类牌照的实缴资本要求是 Rp15 miliar（150 亿印尼盾），二类是 Rp5 miliar。来源：[BI PBI 23/6/2021](https://www.bi.go.id/id/publikasi/peraturan/Pages/PBI_230621.aspx)。新框架下的资本要求**未核实**。
- **「平台代收再结算给第三方商家」是否需要平台自己持 PJP 牌照：公开资料里没查到明确解读，不确定。** 我们的推断：「持有用户 / 商家的资金余额」最接近「资金来源管理」这类最高级别的业务，自己申请牌照的门槛很高（资本金 + 审批周期），所以行业通行做法是让持牌支付网关来持有和划转资金。连 TikTok 都在为电商争取支付牌照（[PYMNTS](https://www.pymnts.com/?p=1590191)），说明大平台倾向自己拿牌，小平台则依靠网关。

### 4.2 支付网关的分账 / 子账户能力
- **Xendit**：2020-02-06 拿到 BI 支付网关牌照（[Xendit 帮助中心](https://help.xendit.co/hc/en-us/articles/360045244972-Is-Xendit-licensed)）。xenPlatform 的机制是：平台作为主账户给每个商家开子账户；用户付的钱可以直接进商家子账户的余额，或者由主账户代收后按分账规则（Split Rule）分给子账户，平台按笔扣佣金（Platform Fee）；商家可以从子账户提现到自己的银行卡。印尼账户默认只能开「托管型子账户」（Managed），「自有型子账户」（Owned）要另外申请开通。来源：[xenPlatform 文档](https://docs.xendit.co/xenplatform)、[Split payments](https://docs.xendit.co/docs/split-payments)、[子账户类型](https://help.xendit.co/hc/en-us/articles/6787784288665-What-is-the-difference-between-managed-and-owned-sub-accounts)。子账户的 KYC 要求、结算 T+N、资金的法律属性：**文档里没写，要问 Xendit**。
- **Midtrans**：有 Payouts（原名 IRIS）批量代付，可以通过 API 打款到任何印尼银行账户；有两种模式：从平台在 Midtrans 预存的余额里出款，或从平台自己的银行账户出款。**没查到收款时直接分账的原生功能**，常见做法是「Midtrans 收款 → 平台余额 → Payouts 打给商家」，这样资金会在平台名下过一手。来源：[Midtrans Disbursement 文档](https://docs.midtrans.com/docs/disbursement-overview)
- **iPaymu** 等也宣传分账功能，但分账流程和佣金分配要商家自己开发。来源：[iPaymu](https://ipaymu.com/en/split-payment/)
- **Stripe 印尼**不支持 Connect 的 destination charges（on_behalf_of），不适合做这类场景。来源：[Stripe 支持页](https://support.stripe.com/questions/stripe-indonesia-support-for-marketplaces)

### 4.3 税务口径
- **增值税（PPN）税率**：2025-01-01 起名义税率 12%；非奢侈品和服务用「11/12 × 售价」作为计税基础，所以实际税负还是 11%（对终端消费者的销售，这个口径的过渡期只到 2025-01-31，之后的处理以最新规定为准）。来源：[DJP：PMK 131/2024](https://www.pajak.go.id/id/artikel/pmk-1312024-tarif-ppn-sebelas-dua-belas)、[DDTC](https://news.ddtc.co.id/berita/nasional/1807939/pmk-terbaru-soal-ppn-12-akhirnya-terbit-begini-perinciannya)；PMK 11/2025 另外调整了其他按「另定税基」和「特定比例」计征的项目（[DJP](https://www.pajak.go.id/id/node/114038)）。
- **代金券本身不是 PPN 的征税对象**：PMK 6/PMK.03/2021 把代金券视为「等同货币的支付工具」，只对代金券营销 / 分销商拿到的佣金或差价征 PPN。来源：[DJP 新闻稿](https://www.pajak.go.id/en/node/47515)、[hukumonline](https://www.hukumonline.com/berita/a/voucer-pulsa-dan-token-listrik-dikenai-pajak--begini-penjelasannya-lt60151898917f0/)
- **PMK 71/PMK.03/2022**（2022-03-30）把「以代金券为媒介的营销服务」「代金券分销相关的支付服务」「会员积分 / 奖励计划」列为特定应税服务，PPN 按「10% × PPN 税率 × 券售价」计征（按当时 11% 的税率，约等于券售价的 1.1%）。来源：[DDTC 2022-04-06](https://news.ddtc.co.id/berita/nasional/38230/pmk-baru-simak-5-jenis-jkp-yang-dipungut-ppn-dengan-besaran-tertentu)、[JDIH Kemenkeu](https://jdih.kemenkeu.go.id/dok/71-pmk-03-2022/view)。**12% 时代这个特定比例有没有调整、我们「平台代售商家服务券」算不算「代金券营销服务」还是「普通中介 / 平台服务（佣金按 11–12% 计 PPN）」：不确定，要问税务顾问。** 另外，商家在券被核销、提供服务时，是否要就服务本身缴 PPN，取决于商家是不是已登记的应税企业（PKP），这是商家自己的义务。
- **参照**：Grab Dine Out 写的是「费用含税」（[条款](https://www.grab.com/id/en/terms-policies/dine-out-terms-and-conditions/)）。
- **所得税（PPh）**：代金券营销服务的报酬适用 PPh 23 预扣（[DJP](https://www.pajak.go.id/en/node/47515)）。**PMK 37/2025** 规定，被指定的电商平台要从境内卖家的流水里代扣 0.5% 的 PPh 22，时间点是「平台代卖家收到款的时候」（[Baker McKenzie 2025-08](https://www.bakermckenzie.com/en/insight/publications/alerts/2025/08/indonesia-the-appointment-of-e-commerce-platforms-as-income-tax-collectors)）。目前只指定了 Tokopedia、Shopee、Lazada、Blibli，生效日期一再推迟（推到 2026-11-01，2026-08 有报道说又推迟了），**现在的状态不确定**。来源：[DJP 推迟公告](https://pajak.go.id/id/pengumuman/penundaan-waktu-pemberlakuan-ketentuan-pemungutan-pph-pasal-22-oleh-marketplace)、[Bisnis 2026-08-06](https://ekonomi.bisnis.com/read/20260806/12/1994208/hippindo-kecewa-pemungutan-pajak-lewat-e-commerce-kembali-ditunda)。如果我们以后代收的规模变大，可能会被指定为代扣方，**系统要预留按商家维度代扣的能力**。

---

## 5. 对我们 MVP 的启示

1. **资金流：接持牌网关的分账 / 子账户，平台不自己沉淀资金，也不申请 PJP 牌照。**
   优先评估 Xendit xenPlatform：每个商家一个子账户，用户付款后资金先挂起，核销后再分账，平台佣金按笔扣。上线前需要请律师和网关书面确认三件事：①「核销前资金挂在哪个账户、法律上属于谁」；②商家子账户要哪些 KYC 材料（线下团队代注册时要收齐，比如 KTP 身份证、NPWP 税号、NIB 营业执照号、银行账户）；③结算是 T+几。
   *依据*：第 4.1、4.2 节；PJP 是否必需的公开解读查不到，自己拿牌门槛高。

2. **结算节奏对标 Grab：「按核销结算、核销后 ≤3 个工作日打款」，商家后台看得到每一笔。**
   这是印尼商家已经见过的标准，比美团的周结更快，地推谈判时可以当卖点。
   *依据*：Grab Dine Out 条款（2026-03）；美团按核销结算、周结。

3. **退款规则：未核销随时退 + 过期自动退，但宠物服务要加「预约后 X 小时内不可退」。**
   「随时退 / 过期退」是美团建立信任的关键；印尼竞品大多「按商家政策」甚至「不可退」（tiket FLEXI），所以这是差异化点。寄养和美容是占用档期的服务，要给商家留保护。过期自动退要有到账核对和状态提醒（参考美团 2025 年的「退款没到账」投诉）。
   *依据*：第 3 节；第 1.2 节 tiket.com 的规则。

4. **品类顺序：先做标准化程度高的洗护美容套餐（按体型 / 毛长分 SKU），再做寄养（按晚 + 档期）；疫苗 / 体检套餐晚一点、并且要单独审核兽医资质；宠物友好餐厅可以对标 Grab / Gojek 的餐饮券，但它们已经在做，不是我们的主战场。**
   美团宠物的经验是「先把诊疗项目标准化成套餐」；印尼还没有人做宠物团购，洗护美容价格透明、复购高，最容易冷启动。
   *依据*：第 2 节（印尼宠物平台全是预约制，没有预付券）；美团宠物 2026-08 的数据。

5. **核销工具：MVP 不做独立的商家 App，用「商家网页端 / 轻量 H5 扫码 + 手动输入券码」，支持一单多券、24 小时内撤销误核销。**
   线下团队代注册的商家多半是小店，安装和培训成本要低。美团和 Grab 的核心核销能力也就是扫码和输码。
   *依据*：第 3 节核销工具；第 1.2 节 GoDineIn「给收银员看二维码」。

6. **佣金和税：先定一个统一的低佣金加首月试用免佣（参考 Grab 的试用佣金和补贴），报价写明「含不含 PPN」；在财税上明确我们是「平台服务费」口径还是「代金券营销」口径。**
   竞品费率都不公开，没办法直接对标；UMKM 部在研究平台收费上限，佣金别定太高，免得撞上监管。系统层面预留按商家代扣 PPh 22 / PPh 23 的字段。
   *依据*：第 1.2 节（Grab 有试用佣金、费用含税；2026-01 平台收费监管动向）；第 4.3 节。

---

## 附：未查到 / 不确定清单
- Traveloka Xperience、tiket.com To Do、GoDineIn、Shopee / Tokopedia 电子券的商家佣金率和结算周期：未查到（都不公开，要以商家身份询价）。
- Grab Dine Out 用户端「30 天有效、100% 退款」：不确定（有搜索摘要提到，但原新闻稿里没找到）。
- Fave 退出印尼的具体财务原因：未查到。
- 印尼平台代收再结算给商家是否需要平台自己持 PJP 牌照（PBI 10/2025 框架下）：不确定，需要律师意见。
- PMK 71/2022 的代金券特定比例在 12% 税率下怎么算、我们适用哪个口径：不确定，需要税务顾问确认。
- PMK 37/2025（平台代扣 0.5% PPh 22）现在的实施状态：不确定。
- 美团各类目官方佣金率：未查到（文章示例 5%，非官方数字）。
