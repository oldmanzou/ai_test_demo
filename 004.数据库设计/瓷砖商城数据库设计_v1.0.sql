-- ============================================================
-- 瓷砖品牌自营微信小程序 · 数据库设计
-- 版本: V1.0 (MVP)
-- 适用数据库: MySQL 8.0+
-- 字符集: utf8mb4 (支持完整中文/emoji)
-- 认证框架: Sa-Token
-- ============================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS tile_mall
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE tile_mall;

-- ============================================================
-- 第一部分: 用户与认证
-- ============================================================

-- 2.1 微信用户表
-- 对应 PRD §3.5 / §5.2 用户信息存储结构
CREATE TABLE `user` (
  `id`              VARCHAR(36)  NOT NULL COMMENT '用户ID (UUID)',
  `openid`          VARCHAR(64)  NOT NULL COMMENT '微信 openid (每个小程序唯一)',
  `unionid`         VARCHAR(64)           DEFAULT NULL COMMENT '微信 unionid (跨应用识别,可选)',
  `nickname`        VARCHAR(64)           DEFAULT NULL COMMENT '微信昵称',
  `avatar_url`      VARCHAR(512)          DEFAULT NULL COMMENT '微信头像 URL',
  `phone_encrypted` VARCHAR(256)          DEFAULT NULL COMMENT '手机号 (AES 加密存储)',
  `phone_masked`    VARCHAR(18)           DEFAULT NULL COMMENT '手机号 (脱敏展示,如 138****6789)',
  `role`            ENUM('owner','worker','designer') NOT NULL DEFAULT 'owner' COMMENT '角色: owner=家装业主, worker=装修工人, designer=设计师',
  `status`          ENUM('active','deleted') NOT NULL DEFAULT 'active' COMMENT '状态: active=正常, deleted=已注销',
  `created_at`      DATETIME     NOT NULL COMMENT '注册时间',
  `updated_at`      DATETIME     NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_login_at`   DATETIME              DEFAULT NULL COMMENT '最近登录时间',
  `deleted_at`      DATETIME              DEFAULT NULL COMMENT '注销时间 (30天冷静期后永久删除)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_openid` (`openid`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='微信用户表';


-- 2.2 商家管理员表
-- 对应 PRD §2.3 商家端-登录/账号管理
-- 配合 Sa-Token 做登录鉴权 + RBAC 权限控制
CREATE TABLE `admin_user` (
  `id`            INT           NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username`      VARCHAR(50)   NOT NULL COMMENT '登录用户名',
  `password`      VARCHAR(255)  NOT NULL COMMENT '密码 (Sa-Token 使用, bcrypt 哈希)',
  `nickname`      VARCHAR(50)            DEFAULT NULL COMMENT '管理员昵称',
  `status`        ENUM('active','disabled') NOT NULL DEFAULT 'active' COMMENT '状态: active=正常, disabled=禁用',
  `last_login_at` DATETIME               DEFAULT NULL COMMENT '最近登录时间',
  `created_at`    DATETIME      NOT NULL COMMENT '创建时间',
  `updated_at`    DATETIME      NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商家管理员表';


-- ============================================================
-- 第三部分: RBAC 权限体系 (配合 Sa-Token)
-- ============================================================
-- Sa-Token 提供 StpUtil.checkRole() / StpUtil.checkPermission()
-- 做角色/权限校验，以下四张表为其数据来源
-- ============================================================

-- 3.1 后台角色表
CREATE TABLE `admin_role` (
  `id`          INT          NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `code`        VARCHAR(50)  NOT NULL COMMENT '角色编码 (如: admin, operator)',
  `name`        VARCHAR(50)  NOT NULL COMMENT '角色名称 (如: 超级管理员, 运营人员)',
  `description` VARCHAR(200)          DEFAULT NULL COMMENT '角色描述',
  `status`      TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '状态: 1=启用, 0=禁用',
  `created_at`  DATETIME     NOT NULL COMMENT '创建时间',
  `updated_at`  DATETIME     NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='后台角色表';


-- 3.2 后台权限表
CREATE TABLE `admin_permission` (
  `id`          INT          NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `code`        VARCHAR(100) NOT NULL COMMENT '权限编码 (如: product:create, order:ship)',
  `name`        VARCHAR(100) NOT NULL COMMENT '权限名称 (如: 创建商品, 发货操作)',
  `module`      VARCHAR(50)           DEFAULT NULL COMMENT '所属模块 (如: product, order, customer)',
  `description` VARCHAR(200)          DEFAULT NULL COMMENT '权限描述',
  `created_at`  DATETIME     NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`),
  KEY `idx_module` (`module`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='后台权限表';


-- 3.3 管理员-角色关联表
CREATE TABLE `admin_role_mapping` (
  `id`       INT NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `admin_id` INT NOT NULL COMMENT '管理员ID',
  `role_id`  INT NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_admin_role` (`admin_id`, `role_id`),
  KEY `idx_role_id` (`role_id`),
  CONSTRAINT `fk_arm_admin` FOREIGN KEY (`admin_id`) REFERENCES `admin_user`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_arm_role` FOREIGN KEY (`role_id`) REFERENCES `admin_role`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理员-角色关联表';


-- 3.4 角色-权限关联表
CREATE TABLE `admin_role_permission` (
  `id`            INT NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `role_id`       INT NOT NULL COMMENT '角色ID',
  `permission_id` INT NOT NULL COMMENT '权限ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_permission` (`role_id`, `permission_id`),
  KEY `idx_permission_id` (`permission_id`),
  CONSTRAINT `fk_arp_role` FOREIGN KEY (`role_id`) REFERENCES `admin_role`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_arp_permission` FOREIGN KEY (`permission_id`) REFERENCES `admin_permission`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色-权限关联表';


-- ============================================================
-- 第四部分: 商品体系
-- ============================================================

-- 4.1 产品分类表 (一级分类)
-- 对应 PRD §2.2 产品分类页: 通体砖/釉面砖/抛光砖/玻化砖/马赛克
CREATE TABLE `product_category` (
  `id`         INT          NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name`       VARCHAR(50)  NOT NULL COMMENT '分类名称',
  `icon_url`   VARCHAR(512)          DEFAULT NULL COMMENT '分类图标 URL',
  `sort_order` INT          NOT NULL DEFAULT 0 COMMENT '排序号 (升序)',
  `created_at` DATETIME     NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='产品一级分类';


-- 4.2 适用空间字典表
-- 来自 PRD §2.2 筛选: 客厅/卧室/厨房/卫生间/阳台
CREATE TABLE `dict_space` (
  `id`   INT         NOT NULL AUTO_INCREMENT COMMENT '空间ID',
  `name` VARCHAR(50) NOT NULL COMMENT '空间名称',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='适用空间字典';


-- 4.3 风格字典表
-- 来自 PRD §2.2 筛选: 现代/简约/北欧/中式/工业风
CREATE TABLE `dict_style` (
  `id`   INT         NOT NULL AUTO_INCREMENT COMMENT '风格ID',
  `name` VARCHAR(50) NOT NULL COMMENT '风格名称',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='风格字典';


-- 4.4 颜色字典表
-- 来自 PRD §2.2 筛选: 灰/白/米黄/深色/木纹
CREATE TABLE `dict_color` (
  `id`   INT         NOT NULL AUTO_INCREMENT COMMENT '颜色ID',
  `name` VARCHAR(50) NOT NULL COMMENT '颜色名称',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='颜色字典';


-- 4.5 产品表 (核心)
-- 对应 PRD §5.1 商品信息结构
CREATE TABLE `product` (
  `id`                VARCHAR(36)   NOT NULL COMMENT '商品ID (UUID)',
  `name`              VARCHAR(200)  NOT NULL COMMENT '商品名称',
  `model_no`          VARCHAR(100)  NOT NULL COMMENT '型号 (品牌型号)',
  `price`             DECIMAL(10,2) NOT NULL COMMENT '单价 (与 price_unit 配合使用)',
  `original_price`    DECIMAL(10,2)          DEFAULT NULL COMMENT '原价 (划线价,可选)',
  `price_unit`        ENUM('piece','sqm','box') NOT NULL DEFAULT 'piece' COMMENT '价格单位: piece=片, sqm=㎡, box=箱',
  `category_id`       INT           NOT NULL COMMENT '所属分类ID',
  `material`          VARCHAR(100)           DEFAULT NULL COMMENT '材质 (如: 通体瓷质砖)',
  `process`           VARCHAR(100)           DEFAULT NULL COMMENT '工艺 (如: 3D纳米喷墨技术)',
  `size`              VARCHAR(50)            DEFAULT NULL COMMENT '尺寸 (如: 800x800mm)',
  `thickness`         VARCHAR(20)            DEFAULT NULL COMMENT '厚度 (如: 10.5mm)',
  `surface_treatment` VARCHAR(50)            DEFAULT NULL COMMENT '表面处理 (亮面/哑面/防滑)',
  `color_id`          INT                    DEFAULT NULL COMMENT '颜色ID',
  `pieces_per_box`    INT                    DEFAULT NULL COMMENT '每箱片数',
  `stock`             INT           NOT NULL DEFAULT 0 COMMENT '当前库存量',
  `sales_volume`      INT           NOT NULL DEFAULT 0 COMMENT '累计销量',
  `description`       TEXT                   DEFAULT NULL COMMENT '商品描述/简介',
  `status`            ENUM('active','inactive') NOT NULL DEFAULT 'active' COMMENT '状态: active=上架, inactive=下架',
  `created_at`        DATETIME      NOT NULL COMMENT '创建时间 (上架时间)',
  `updated_at`        DATETIME      NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_model_no` (`model_no`),
  KEY `idx_color` (`color_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `product_category`(`id`),
  CONSTRAINT `fk_product_color` FOREIGN KEY (`color_id`) REFERENCES `dict_color`(`id`),
  CONSTRAINT `ck_product_stock` CHECK (`stock` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='产品表';


-- 4.6 产品-空间关联表 (多对多)
CREATE TABLE `product_space_mapping` (
  `product_id` VARCHAR(36) NOT NULL COMMENT '商品ID',
  `space_id`   INT         NOT NULL COMMENT '空间ID',
  PRIMARY KEY (`product_id`, `space_id`),
  CONSTRAINT `fk_psm_product` FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_psm_space` FOREIGN KEY (`space_id`) REFERENCES `dict_space`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='产品-适用空间关联';


-- 4.7 产品-风格关联表 (多对多)
CREATE TABLE `product_style_mapping` (
  `product_id` VARCHAR(36) NOT NULL COMMENT '商品ID',
  `style_id`   INT         NOT NULL COMMENT '风格ID',
  PRIMARY KEY (`product_id`, `style_id`),
  CONSTRAINT `fk_pstyl_product` FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pstyl_style` FOREIGN KEY (`style_id`) REFERENCES `dict_style`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='产品-风格关联';


-- 4.8 产品图片表
-- 对应 PRD §4.1 / §5.1: 产品图 + 效果图
CREATE TABLE `product_image` (
  `id`         INT          NOT NULL AUTO_INCREMENT COMMENT '图片ID',
  `product_id` VARCHAR(36)  NOT NULL COMMENT '商品ID',
  `image_url`  VARCHAR(512) NOT NULL COMMENT '图片 URL',
  `image_type` ENUM('product','effect') NOT NULL COMMENT '类型: product=产品图, effect=效果图',
  `sort_order` INT          NOT NULL DEFAULT 0 COMMENT '排序号 (升序)',
  `created_at` DATETIME     NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_product_type` (`product_id`, `image_type`),
  CONSTRAINT `fk_pi_product` FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='产品图片表';


-- 4.9 产品标签表
-- 对应 PRD §4.5: 产品详情页标签行 (如"耐磨易洁""意大利进口釉料")
CREATE TABLE `product_tag` (
  `id`   INT         NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `name` VARCHAR(50) NOT NULL COMMENT '标签名称',
  `type` ENUM('style','feature','quality') NOT NULL DEFAULT 'feature' COMMENT '标签类型: style=风格, feature=功能卖点, quality=品质',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='产品标签表';


-- 4.10 产品-标签关联表 (多对多)
CREATE TABLE `product_tag_mapping` (
  `product_id` VARCHAR(36) NOT NULL COMMENT '商品ID',
  `tag_id`     INT         NOT NULL COMMENT '标签ID',
  PRIMARY KEY (`product_id`, `tag_id`),
  CONSTRAINT `fk_ptag_product` FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ptag_tag` FOREIGN KEY (`tag_id`) REFERENCES `product_tag`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='产品-标签关联表';


-- ============================================================
-- 第五部分: 购物车
-- ============================================================

-- 5.1 购物车条目表
-- 对应 PRD §4.3 购物车
CREATE TABLE `cart_item` (
  `id`         INT          NOT NULL AUTO_INCREMENT COMMENT '条目ID',
  `user_id`    VARCHAR(36)  NOT NULL COMMENT '用户ID',
  `product_id` VARCHAR(36)  NOT NULL COMMENT '商品ID',
  `quantity`   INT          NOT NULL DEFAULT 1 COMMENT '数量',
  `selected`   TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '是否勾选: 1=选中, 0=未选',
  `created_at` DATETIME     NOT NULL COMMENT '创建时间',
  `updated_at` DATETIME     NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product` (`user_id`, `product_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_ci_product` FOREIGN KEY (`product_id`) REFERENCES `product`(`id`),
  CONSTRAINT `fk_ci_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='购物车条目表';


-- 5.2 收藏表
-- 对应 PRD §6: 用户可收藏产品和案例
CREATE TABLE `favorite` (
  `id`          INT          NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
  `user_id`     VARCHAR(36)  NOT NULL COMMENT '用户ID',
  `target_id`   VARCHAR(36)  NOT NULL COMMENT '收藏对象ID (产品ID或案例ID)',
  `target_type` ENUM('product','case') NOT NULL COMMENT '收藏对象类型: product=产品, case=案例',
  `created_at`  DATETIME     NOT NULL COMMENT '收藏时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_target` (`user_id`, `target_id`, `target_type`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_target` (`target_id`, `target_type`),
  CONSTRAINT `fk_fav_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏表';


-- ============================================================
-- 第六部分: 订单体系
-- ============================================================

-- 6.1 收货地址表
-- 对应 PRD §4.4 / §4.6: 用户收货地址管理
CREATE TABLE `address` (
  `id`             INT          NOT NULL AUTO_INCREMENT COMMENT '地址ID',
  `user_id`        VARCHAR(36)  NOT NULL COMMENT '用户ID',
  `receiver_name`  VARCHAR(50)  NOT NULL COMMENT '收货人姓名',
  `phone`          VARCHAR(20)  NOT NULL COMMENT '联系电话',
  `region`         VARCHAR(200) NOT NULL COMMENT '所在地区 (省市区, 如: 广东省 佛山市 禅城区)',
  `detail_address` VARCHAR(500) NOT NULL COMMENT '详细地址 (街道/门牌号等)',
  `is_default`     TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '是否默认地址: 1=是, 0=否',
  `created_at`     DATETIME     NOT NULL COMMENT '创建时间',
  `updated_at`     DATETIME     NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_addr_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收货地址表';


-- 6.2 订单主表
-- 对应 PRD §5.3 订单信息结构
CREATE TABLE `orders` (
  `id`                VARCHAR(36) NOT NULL COMMENT '订单ID (UUID)',
  `order_no`          VARCHAR(50) NOT NULL COMMENT '订单编号 (可读, 如: ORD-20260610-0001)',
  `user_id`           VARCHAR(36) NOT NULL COMMENT '下单用户ID',
  `status`            ENUM('pending_payment','pending_delivery','shipped','completed','cancelled','refunding') NOT NULL DEFAULT 'pending_payment' COMMENT '订单状态',
  `discount_amount`   DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额',
  `consignee_name`    VARCHAR(50) NOT NULL COMMENT '收货人姓名',
  `consignee_phone`   VARCHAR(20) NOT NULL COMMENT '收货人电话',
  `consignee_region`  VARCHAR(200) NOT NULL COMMENT '收货地区 (省市区)',
  `consignee_address` VARCHAR(500) NOT NULL COMMENT '收货详细地址',
  `total_amount`      DECIMAL(10,2) NOT NULL COMMENT '商品总额 (不含运费)',
  `freight`           DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '运费 (MVP默认0, 显示"线下协商")',
  `actual_amount`     DECIMAL(10,2) NOT NULL COMMENT '实付金额',
  `tracking_no`       VARCHAR(100)           DEFAULT NULL COMMENT '运单号',
  `tracking_company`  VARCHAR(50)            DEFAULT NULL COMMENT '物流公司',
  `remark`            TEXT                   DEFAULT NULL COMMENT '买家备注',
  `paid_at`           DATETIME              DEFAULT NULL COMMENT '支付完成时间',
  `shipped_at`        DATETIME              DEFAULT NULL COMMENT '发货时间',
  `delivered_at`      DATETIME              DEFAULT NULL COMMENT '确认收货时间',
  `cancelled_at`      DATETIME              DEFAULT NULL COMMENT '取消时间',
  `created_at`        DATETIME    NOT NULL COMMENT '下单时间',
  `updated_at`        DATETIME    NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_user_status` (`user_id`, `status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_order_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单主表';



-- 6.3 支付记录表
-- 记录微信支付回调结果，用于对账和订单状态更新
CREATE TABLE `payment_record` (
  `id`              VARCHAR(36)  NOT NULL COMMENT '记录ID (UUID)',
  `order_id`        VARCHAR(36)  NOT NULL COMMENT '订单ID',
  `transaction_id`  VARCHAR(64)  NOT NULL COMMENT '微信支付订单号 (transaction_id)',
  `prepay_id`       VARCHAR(128)          DEFAULT NULL COMMENT '微信预支付ID (prepay_id)',
  `amount`          DECIMAL(10,2) NOT NULL COMMENT '支付金额 (元)',
  `pay_type`        VARCHAR(20)  NOT NULL DEFAULT 'wechat' COMMENT '支付方式 (wechat)',
  `trade_state`     ENUM('success','fail','refund','closed') NOT NULL DEFAULT 'success' COMMENT '交易状态: success=成功, fail=失败, refund=已退款, closed=已关闭',
  `notify_raw`      TEXT                  DEFAULT NULL COMMENT '微信回调原始JSON (用于对账/排障)',
  `notified_at`     DATETIME              DEFAULT NULL COMMENT '回调通知时间',
  `created_at`      DATETIME     NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_transaction_id` (`transaction_id`),
  CONSTRAINT `fk_payment_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付记录表';


-- 6.4 首页轮播图表
-- 对应 PRD §4.2: Banner 区展示新品/活动
CREATE TABLE `banner` (
  `id`          INT           NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `title`       VARCHAR(100)           DEFAULT NULL COMMENT '标签 (如: 新品上市)',
  `subtitle`    VARCHAR(200)           DEFAULT NULL COMMENT '副标题/主文案 (如: 意式卡拉拉白·柔光系列)',
  `image_url`   VARCHAR(512)  NOT NULL COMMENT '图片 URL',
  `link_type`   ENUM('product','category','custom') DEFAULT NULL COMMENT '跳转类型: product=商品, category=分类, custom=自定义链接',
  `link_value`  VARCHAR(512)           DEFAULT NULL COMMENT '跳转值 (商品ID/分类ID/自定义URL)',
  `sort_order`  INT           NOT NULL DEFAULT 0 COMMENT '排序号 (升序)',
  `status`      ENUM('active','inactive') NOT NULL DEFAULT 'active' COMMENT '状态: active=上线, inactive=下线',
  `start_at`    DATETIME               DEFAULT NULL COMMENT '生效开始时间 (定时投放)',
  `end_at`      DATETIME               DEFAULT NULL COMMENT '生效结束时间',
  `created_at`  DATETIME      NOT NULL COMMENT '创建时间',
  `updated_at`  DATETIME      NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_status_sort` (`status`, `sort_order`),
  KEY `idx_time_range` (`start_at`, `end_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='首页轮播图表';


-- 6.5 订单明细表
-- 对应 PRD §5.3: 商品明细 (商品ID/数量/单价)
-- 冗余存储商品快照,防止商品变更后订单历史不一致
CREATE TABLE `order_item` (
  `id`            INT           NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id`      VARCHAR(36)   NOT NULL COMMENT '订单ID',
  `product_id`    VARCHAR(36)   NOT NULL COMMENT '商品ID',
  `product_name`  VARCHAR(200)  NOT NULL COMMENT '商品名称 (下单时快照)',
  `product_image` VARCHAR(512)  NOT NULL COMMENT '商品图片 (下单时快照)',
  `product_spec`  VARCHAR(200)  NOT NULL COMMENT '商品规格 (下单时快照, 如: 800x800mm | 亮面)',
  `unit_price`    DECIMAL(10,2) NOT NULL COMMENT '单价',
  `quantity`      INT           NOT NULL COMMENT '数量',
  `subtotal`      DECIMAL(10,2) NOT NULL COMMENT '小计金额',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_oi_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_oi_product` FOREIGN KEY (`product_id`) REFERENCES `product`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单明细表';


-- 6.6 退款/售后表
-- 对应 PRD §4.9: 退款申请页
CREATE TABLE `refund` (
  `id`            VARCHAR(36)  NOT NULL COMMENT '退款ID (UUID)',
  `order_id`      VARCHAR(36)  NOT NULL COMMENT '订单ID',
  `order_item_id`      INT                   DEFAULT NULL COMMENT '关联订单明细ID (空=整单退款)',
  `payment_record_id` VARCHAR(36)          DEFAULT NULL COMMENT '关联支付记录ID (用于微信退款)',
  `reason`            VARCHAR(50)  NOT NULL COMMENT '退款原因',
  `description`   TEXT                  DEFAULT NULL COMMENT '退款说明',
  `evidence_imgs` JSON                  DEFAULT NULL COMMENT '凭证图片URL数组 (最多3张)',
  `amount`        DECIMAL(10,2) NOT NULL COMMENT '退款金额',
  `status`        ENUM('pending','approved','rejected','refunded') NOT NULL DEFAULT 'pending' COMMENT '状态: pending=审核中, approved=已通过, rejected=已拒绝, refunded=已退款',
  `created_at`    DATETIME     NOT NULL COMMENT '申请时间',
  `updated_at`    DATETIME     NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_payment_record_id` (`payment_record_id`),
  CONSTRAINT `fk_refund_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='退款/售后表';


-- 6.7 订单时间线表
-- 对应 PRD §4.11: 订单详情页的4步时间线
CREATE TABLE `order_timeline` (
  `id`          INT          NOT NULL AUTO_INCREMENT COMMENT '事件ID',
  `order_id`    VARCHAR(36)  NOT NULL COMMENT '订单ID',
  `event_type`  VARCHAR(50)  NOT NULL COMMENT '事件类型 (如: created, paid, shipped, delivered)',
  `event_desc`  VARCHAR(200) NOT NULL COMMENT '事件描述 (如: 订单已创建, 仓库已发货)',
  `extra_info`  VARCHAR(200)          DEFAULT NULL COMMENT '额外信息 (如运单号)',
  `created_at`  DATETIME     NOT NULL COMMENT '事件时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_tl_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单时间线表';


-- ============================================================
-- 第七部分: 装修案例 (来自前端 case 页面)
-- ============================================================

-- 7.1 装修案例表
CREATE TABLE `case_study` (
  `id`          VARCHAR(36)  NOT NULL COMMENT '案例ID (UUID)',
  `title`       VARCHAR(200) NOT NULL COMMENT '案例标题',
  `style`       VARCHAR(50)           DEFAULT NULL COMMENT '风格 (如: 现代简约)',
  `location`    VARCHAR(200)          DEFAULT NULL COMMENT '案例地点 (如: 上海·滨江壹号院)',
  `area`        VARCHAR(50)           DEFAULT NULL COMMENT '面积 (如: 140㎡)',
  `duration`    VARCHAR(50)           DEFAULT NULL COMMENT '施工时长 (如: 12天)',
  `description` TEXT                  DEFAULT NULL COMMENT '案例描述',
  `hero_image`  VARCHAR(512)          DEFAULT NULL COMMENT '封面大图 URL',
  `created_at`  DATETIME     NOT NULL COMMENT '创建时间',
  `updated_at`  DATETIME     NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_style` (`style`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='装修案例表';


-- 7.2 案例-产品关联表 (多对多)
CREATE TABLE `case_product` (
  `id`         INT         NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `case_id`    VARCHAR(36) NOT NULL COMMENT '案例ID',
  `product_id` VARCHAR(36) NOT NULL COMMENT '商品ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_case_product` (`case_id`, `product_id`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_cp_case` FOREIGN KEY (`case_id`) REFERENCES `case_study`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cp_product` FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='案例-产品关联表';


-- ============================================================
-- 第八部分: 种子数据
-- ============================================================

-- 8.1 产品一级分类
INSERT INTO `product_category` (`id`, `name`, `icon_url`, `sort_order`, `created_at`) VALUES
(1, '通体砖', NULL, 1, NOW()),
(2, '釉面砖', NULL, 2, NOW()),
(3, '抛光砖', NULL, 3, NOW()),
(4, '玻化砖', NULL, 4, NOW()),
(5, '马赛克', NULL, 5, NOW());

-- 8.2 适用空间
INSERT INTO `dict_space` (`id`, `name`) VALUES
(1, '客厅'),
(2, '卧室'),
(3, '厨房'),
(4, '卫生间'),
(5, '阳台');

-- 8.3 风格
INSERT INTO `dict_style` (`id`, `name`) VALUES
(1, '现代'),
(2, '简约'),
(3, '北欧'),
(4, '中式'),
(5, '工业风');

-- 8.4 颜色
INSERT INTO `dict_color` (`id`, `name`) VALUES
(1, '灰'),
(2, '白'),
(3, '米黄'),
(4, '深色'),
(5, '木纹');

-- 8.5 产品标签
INSERT INTO `product_tag` (`id`, `name`, `type`) VALUES
(1, '现代简约', 'style'),
(2, '北欧风',   'style'),
(3, '中式',     'style'),
(4, '工业风',   'style'),
(5, '耐磨易洁', 'feature'),
(6, '防滑',     'feature'),
(7, '意大利进口釉料', 'quality'),
(8, '3D 纳米工艺',    'quality');

-- 8.6 后台角色
INSERT INTO `admin_role` (`id`, `code`, `name`, `description`, `status`, `created_at`) VALUES
(1, 'super_admin', '超级管理员', '拥有系统全部权限', 1, NOW()),
(2, 'operator',    '运营人员',   '商品管理、订单处理', 1, NOW()),
(3, 'customer_service', '客服人员', '查看订单、客户信息', 1, NOW());

-- 8.7 后台权限 (按模块划分)
INSERT INTO `admin_permission` (`id`, `code`, `name`, `module`, `created_at`) VALUES
-- 商品管理
(1,  'product:list',     '查看商品列表',   'product', NOW()),
(2,  'product:create',   '添加商品',       'product', NOW()),
(3,  'product:edit',     '编辑商品',       'product', NOW()),
(4,  'product:delete',   '删除商品',       'product', NOW()),
(5,  'product:publish',  '上架/下架商品',  'product', NOW()),
-- 订单管理
(6,  'order:list',       '查看订单列表',   'order',   NOW()),
(7,  'order:detail',     '查看订单详情',   'order',   NOW()),
(8,  'order:ship',       '发货操作',       'order',   NOW()),
(9,  'order:complete',   '完成订单',       'order',   NOW()),
-- 客户管理
(10, 'customer:list',    '查看客户列表',   'customer', NOW()),
(11, 'customer:detail',  '查看客户详情',   'customer', NOW()),
-- 库存管理
(12, 'stock:list',       '查看库存',       'stock',   NOW()),
(13, 'stock:adjust',     '调整库存',       'stock',   NOW()),
-- 权限管理
(14, 'admin:list',       '查看管理员',     'admin',   NOW()),
(15, 'admin:create',     '添加管理员',     'admin',   NOW()),
(16, 'admin:role',       '分配角色',       'admin',   NOW()),
-- 退款管理
(17, 'refund:list',      '查看退款列表',   'refund',  NOW()),
(18, 'refund:approve',   '审核退款',       'refund',  NOW());

-- 8.8 角色-权限关联
-- super_admin: 所有权限 (含退款)
INSERT INTO `admin_role_permission` (`role_id`, `permission_id`) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
(1, 6), (1, 7), (1, 8), (1, 9),
(1, 10), (1, 11),
(1, 12), (1, 13),
(1, 14), (1, 15), (1, 16),
(1, 17), (1, 18);

-- operator: 商品 + 订单 + 库存 + 查看退款
INSERT INTO `admin_role_permission` (`role_id`, `permission_id`) VALUES
(2, 1), (2, 2), (2, 3), (2, 5),
(2, 6), (2, 7), (2, 8), (2, 9),
(2, 12), (2, 13),
(2, 17);

-- customer_service: 查看订单 + 查看客户
INSERT INTO `admin_role_permission` (`role_id`, `permission_id`) VALUES
(3, 6), (3, 7), (3, 10), (3, 11);

-- 8.9 默认超级管理员 (密码: admin123, 请首次登录后修改!)
-- bcrypt hash for 'admin123': $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
INSERT INTO `admin_user` (`id`, `username`, `password`, `nickname`, `status`, `created_at`) VALUES
(1, 'admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '系统管理员', 'active', NOW());

-- 8.10 给默认管理员分配 super_admin 角色
INSERT INTO `admin_role_mapping` (`admin_id`, `role_id`) VALUES
(1, 1);

-- 8.11 首页轮播图示例数据
INSERT INTO `banner` (`title`, `subtitle`, `image_url`, `link_type`, `link_value`, `sort_order`, `status`, `created_at`) VALUES
('新品上市', '意式卡拉拉白·柔光系列', '/images/banners/new-arrivals.jpg', 'category', '1', 1, 'active', NOW()),
('人气之选', '现代简约灰岩地砖',       '/images/banners/popular.jpg',        'product', NULL,    2, 'active', NOW());


-- ============================================================
-- 附录: 表关系总览与索引说明
-- ============================================================
--
-- 一、表结构总览 (共 24 张表)
--
--   用户体系 (2):
--     user               ──── 微信小程序用户
--     admin_user         ──── 商家后台管理员
--
--   RBAC 权限 (4):
--     admin_role                ── 后台角色
--     admin_permission          ── 后台权限
--     admin_role_mapping        ── 管理员-角色 (多对多)
--     admin_role_permission     ── 角色-权限 (多对多)
--
--   商品体系 (10):
--     product_category          ── 产品分类
--     dict_space                ── 空间字典
--     dict_style                ── 风格字典
--     dict_color                ── 颜色字典
--     product                   ── 产品主表
--     product_space_mapping     ── 产品-空间 (多对多)
--     product_style_mapping     ── 产品-风格 (多对多)
--     product_image             ── 产品图片/效果图
--     product_tag               ── 产品标签
--     product_tag_mapping       ── 产品-标签关联 (多对多)
--
--   购物车 (1):
--     cart_item                 ── 购物车条目
--
--   收藏 (1):
--     favorite                  ── 收藏 (产品和案例)
--
--   订单体系 (7):
--     address                   ── 收货地址
--     orders                    ── 订单主表
--     order_item                ── 订单明细
--     payment_record            ── 支付记录
--     banner                    ── 首页轮播图
--     refund                    ── 退款/售后
--     order_timeline            ── 订单时间线
--
--   装修案例 (2):
--     case_study                ── 装修案例
--     case_product              ── 案例-产品 (多对多)
--
-- 二、核心查询场景与索引
--
--   1. 微信小程序登录:       WHERE openid = ?                    → uk_openid
--   2. 后台管理员登录:       WHERE username = ?                  → uk_username
--   3. 商品列表 (按分类):     WHERE category_id = ?              → idx_category
--   4. 商品列表 (上架商品):   WHERE status = 'active'            → idx_status
--   5. 用户订单列表:         WHERE user_id = ? ORDER BY created_at DESC → idx_user_id + idx_created_at
--   6. 订单详情:             WHERE order_no = ?                  → uk_order_no
--   7. 购物车列表:           WHERE user_id = ?                   → idx_user_id (cart_item)
--   8. 地址列表:             WHERE user_id = ?                   → idx_user_id (address)
--   9. 管理员权限:           JOIN admin_role_mapping + admin_role_permission + admin_permission
--  10. 首页活跃 Banner:     WHERE status='active' AND now() BETWEEN start_at AND end_at → idx_status_sort + idx_time_range
--  11. 支付记录查询:         WHERE transaction_id = ?            → idx_transaction_id
--  12. 用户收藏列表:         WHERE user_id=? AND target_type=?   → idx_user_id
--  13. 用户订单按状态查询:   WHERE user_id=? AND status=?        → idx_user_status (复合)
--  14. 退款列表:             WHERE order_id = ?                  → idx_order_id
--  15. 订单时间线:           WHERE order_id = ? ORDER BY created_at → idx_order_id + idx_created_at
--
-- 三、外键策略说明
--
--   ON DELETE CASCADE 的场景 (数据从属, 父删子删):
--     - 产品图片、产品-空间/风格/标签关联 → 删除产品时自动清理
--     - 订单明细、订单时间线              → 删除订单时自动清理
--     - 案例-产品关联                     → 删除案例或产品时自动清理
--     - 管理员-角色、角色-权限             → 删除管理员/角色时自动清理
--
--   无 CASCADE 的场景 (需业务层处理):
--     - 购物车条目、地址、订单        → 用户注销时需手动清理或保留记录
--     - 产品 (被订单引用)             → 产品可下架但不可物理删除 (或有订单关联时禁止删除)
-- ============================================================
