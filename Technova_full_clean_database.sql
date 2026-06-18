/* ==========================================================
   TECHNOVA_FULL_CLEAN.sql
   ----------------------------------------------------------
   File SQL mới hoàn toàn cho đồ án của bạn.
   Gồm đủ dữ liệu cần thiết để chạy app Flask hiện tại:
   - Tài khoản / đăng nhập / đăng ký / OTP / avatar
   - Trang điện thoại bài 1: products_phone, colors, images, variants
   - Trang sản phẩm bài 2: products, storages, colors, gallery, specs, reviews

   CẢNH BÁO: File này sẽ XÓA database Technova nếu đã tồn tại.
   Nếu có dữ liệu quan trọng, hãy backup trước khi chạy.
   ========================================================== */

USE master;
GO

IF DB_ID(N'Technova') IS NOT NULL
BEGIN
    ALTER DATABASE Technova SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Technova;
END;
GO

CREATE DATABASE Technova;
GO

USE Technova;
GO

/* ==========================================================
   1. BẢNG TÀI KHOẢN / ĐĂNG NHẬP
   ========================================================== */

CREATE TABLE accounts (
    id INT PRIMARY KEY IDENTITY(1,1),
    username NVARCHAR(100) UNIQUE,
    email NVARCHAR(255) UNIQUE,
    phone NVARCHAR(20) UNIQUE,
    password_md5 CHAR(32) NOT NULL,
    role NVARCHAR(20) NOT NULL CHECK (role IN ('customer', 'admin')),
    status NVARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE customer_profiles (
    id INT PRIMARY KEY IDENTITY(1,1),
    account_id INT NOT NULL UNIQUE,
    full_name NVARCHAR(255),
    gender NVARCHAR(20),
    date_of_birth DATE,
    avatar_data VARBINARY(MAX),
    avatar_mime NVARCHAR(50),
    avatar_original_data VARBINARY(MAX),
    avatar_original_mime NVARCHAR(50),
    CONSTRAINT fk_customer_account
        FOREIGN KEY (account_id) REFERENCES accounts(id)
        ON DELETE CASCADE
);
GO

CREATE TABLE admin_profiles (
    id INT PRIMARY KEY IDENTITY(1,1),
    account_id INT NOT NULL UNIQUE,
    admin_name NVARCHAR(255),
    avatar_url NVARCHAR(MAX),
    CONSTRAINT fk_admin_account
        FOREIGN KEY (account_id) REFERENCES accounts(id)
        ON DELETE CASCADE
);
GO

CREATE TABLE password_reset_codes (
    id INT PRIMARY KEY IDENTITY(1,1),
    account_id INT NOT NULL,
    reset_code NVARCHAR(10) NOT NULL,
    expired_at DATETIME NOT NULL,
    is_used BIT DEFAULT 0,
    CONSTRAINT fk_password_reset_account
        FOREIGN KEY (account_id) REFERENCES accounts(id)
        ON DELETE CASCADE
);
GO

/* Tài khoản mẫu để test nếu cần
   Email: demo@technova.com
   Phone: 0900000000
   Password: 12345678
*/
INSERT INTO accounts (username, email, phone, password_md5, role, status)
VALUES (N'demo@technova.com', N'demo@technova.com', N'0900000000', N'25d55ad283aa400af464c76d713c07ad', N'customer', N'active');

INSERT INTO customer_profiles (account_id, full_name, gender, date_of_birth)
VALUES (SCOPE_IDENTITY(), N'Khách hàng Demo', N'Nam', '2005-01-01');
GO

/* ==========================================================
   2. BẢNG ĐIỆN THOẠI CŨ CỦA BÀI 1
   Dùng cho /phones và /detail/<id>
   ========================================================== */

CREATE TABLE products_phone (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(255),
    category NVARCHAR(50),
    brand NVARCHAR(100),
    created_at DATE,
    release_date DATE,
    rating DECIMAL(2,1),
    sold INT,
    os NVARCHAR(100),
    chipset NVARCHAR(100),
    cpu NVARCHAR(100),
    gpu NVARCHAR(100),
    ram NVARCHAR(50),
    screen_size NVARCHAR(50),
    screen_resolution NVARCHAR(100),
    screen_type NVARCHAR(100),
    screen_refresh_rate NVARCHAR(50),
    screen_features NVARCHAR(MAX),
    rear_camera NVARCHAR(MAX),
    front_camera NVARCHAR(100),
    video_recording NVARCHAR(MAX),
    camera_features NVARCHAR(MAX),
    battery NVARCHAR(100),
    charging NVARCHAR(MAX),
    charging_port NVARCHAR(50),
    network NVARCHAR(50),
    wifi NVARCHAR(100),
    bluetooth NVARCHAR(50),
    nfc BIT,
    sim NVARCHAR(100),
    gps NVARCHAR(255),
    memory_card NVARCHAR(50),
    back_material NVARCHAR(100),
    frame_material NVARCHAR(100),
    weight NVARCHAR(50),
    size NVARCHAR(100),
    waterproof NVARCHAR(50),
    sensors NVARCHAR(MAX),
    special_features NVARCHAR(MAX)
);
GO

CREATE TABLE product_colors_phone (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    color_name NVARCHAR(100) NOT NULL,
    CONSTRAINT fk_color_phone_product
        FOREIGN KEY (product_id) REFERENCES products_phone(id)
        ON DELETE CASCADE,
    CONSTRAINT uq_product_color_phone UNIQUE (product_id, color_name)
);
GO

CREATE TABLE product_images_phone (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    color_id INT NOT NULL,
    image_url NVARCHAR(MAX) NOT NULL,
    display_order INT DEFAULT 1,
    is_primary BIT DEFAULT 0,
    CONSTRAINT fk_image_phone_product
        FOREIGN KEY (product_id) REFERENCES products_phone(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_image_phone_color
        FOREIGN KEY (color_id) REFERENCES product_colors_phone(id)
);
GO

CREATE TABLE product_variants_phone (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    color_id INT,
    storage NVARCHAR(50),
    price INT,
    old_price INT,
    stock INT,
    image_main NVARCHAR(MAX),
    CONSTRAINT fk_variant_phone_product
        FOREIGN KEY (product_id) REFERENCES products_phone(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_variant_phone_color
        FOREIGN KEY (color_id) REFERENCES product_colors_phone(id)
);
GO

/* ==========================================================
   3. BẢNG SẢN PHẨM MỚI CỦA BÀI 2
   Dùng cho /products, /detail?id=..., /api/products
   ========================================================== */

CREATE TABLE products (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(255) NOT NULL,
    category NVARCHAR(50) NOT NULL,
    brand NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    default_storage_order INT DEFAULT 1,
    default_color_order INT DEFAULT 1,
    old_price_text NVARCHAR(50),
    old_price_number INT,
    discount NVARCHAR(20),
    has_discount BIT DEFAULT 0,
    rating DECIMAL(2,1) DEFAULT 0,
    sold INT DEFAULT 0,
    is_flash_sale BIT DEFAULT 0,
    is_featured BIT DEFAULT 0,
    is_new BIT DEFAULT 0,
    technical_image NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL
);
GO

CREATE TABLE product_storages (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    storage NVARCHAR(50) NOT NULL,
    ram NVARCHAR(50),
    price_text NVARCHAR(50) NOT NULL,
    price_number INT NOT NULL,
    display_order INT DEFAULT 1,
    CONSTRAINT fk_storage_product_api
        FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE CASCADE,
    CONSTRAINT uq_product_storage_api UNIQUE (product_id, storage)
);
GO

CREATE TABLE product_colors (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    color_name NVARCHAR(100) NOT NULL,
    color_code NVARCHAR(20) NOT NULL,
    main_image NVARCHAR(500) NOT NULL,
    display_order INT DEFAULT 1,
    CONSTRAINT fk_color_product_api
        FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE CASCADE,
    CONSTRAINT uq_product_color_api UNIQUE (product_id, color_name)
);
GO

CREATE TABLE product_color_images (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    color_id INT NOT NULL,
    image_url NVARCHAR(500) NOT NULL,
    display_order INT DEFAULT 1,
    CONSTRAINT fk_color_image_product_api
        FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_color_image_color_api
        FOREIGN KEY (color_id) REFERENCES product_colors(id)
);
GO

CREATE TABLE product_spec_groups (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    display_order INT DEFAULT 1,
    CONSTRAINT fk_spec_group_product_api
        FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE CASCADE
);
GO

CREATE TABLE product_spec_items (
    id INT PRIMARY KEY IDENTITY(1,1),
    group_id INT NOT NULL,
    label NVARCHAR(255) NOT NULL,
    value NVARCHAR(MAX) NOT NULL,
    display_order INT DEFAULT 1,
    CONSTRAINT fk_spec_item_group_api
        FOREIGN KEY (group_id) REFERENCES product_spec_groups(id)
        ON DELETE CASCADE
);
GO

/* Bảng đánh giá dùng chung, để không bị trùng tên giữa bài 1 và bài 2 */
CREATE TABLE product_reviews (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    product_type NVARCHAR(50) NULL,
    user_id INT NULL,
    reviewer_name NVARCHAR(255) NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);
GO

/* View phụ, không bắt buộc nhưng tiện kiểm tra sản phẩm */
CREATE OR ALTER VIEW v_product_cards AS
SELECT
    p.id,
    p.name,
    p.category,
    p.brand,
    p.description,
    p.old_price_text,
    p.old_price_number,
    p.discount,
    p.has_discount,
    p.rating,
    p.sold,
    p.is_flash_sale,
    p.is_featured,
    p.is_new,
    p.technical_image,
    s.storage,
    s.ram,
    s.price_text,
    s.price_number,
    c.color_name,
    c.color_code,
    c.main_image
FROM products p
OUTER APPLY (
    SELECT TOP 1 *
    FROM product_storages s
    WHERE s.product_id = p.id
    ORDER BY s.display_order
) s
OUTER APPLY (
    SELECT TOP 1 *
    FROM product_colors c
    WHERE c.product_id = p.id
    ORDER BY c.display_order
) c;
GO

/* ==========================================================
   4. DỮ LIỆU ĐIỆN THOẠI CHO BÀI 1
   ========================================================== */

DECLARE @Iphone17eId INT;
DECLARE @IphonePinkId INT;
DECLARE @IphoneBlackId INT;
DECLARE @IphoneWhiteId INT;

INSERT INTO products_phone (
    name, category, brand,
    created_at, release_date,
    rating, sold,

    os, chipset, cpu, gpu, ram,

    screen_size, screen_resolution, screen_type, screen_refresh_rate, screen_features,

    rear_camera, front_camera, video_recording, camera_features,

    battery, charging, charging_port,

    network, wifi, bluetooth, nfc, sim, gps,

    memory_card,

    back_material, frame_material, weight, size, waterproof,

    sensors, special_features
)
VALUES (
    N'iPhone 17e',
    N'phone',
    N'Apple',

    CAST(GETDATE() AS DATE),
    '2016-09-16',

    4.9,
    371,

    N'iOS 10',
    N'Apple A15 Bionic',
    NULL,
    N'Apple GPU',
    N'8GB',

    N'6.1 inch',
    N'2532 x 1170 pixels',
    N'Super Retina XDR OLED',
    N'120Hz',
    N'HDR10, Dolby Vision, Always-on display',

    N'12MP, chống rung quang học OIS',
    N'12MP, khẩu độ f/1.9',
    N'4K@30fps, Full HD 1080p',
    N'HDR, lấy nét tự động, panorama, chống rung điện tử',

    N'5960 mAh',
    N'Sạc tiêu chuẩn 100W',
    N'Lightning',

    N'4G LTE',
    N'Wi-Fi 5',
    N'Bluetooth 4.2',
    0,
    N'1 Nano-SIM',
    N'A-GPS, GLONASS',

    N'Không hỗ trợ',

    N'Nhôm',
    N'Khung nhôm nguyên khối',
    N'138 g',
    N'138.3 x 67.1 x 7.1 mm',
    N'IP68',

    N'Cảm biến vân tay, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
    N'Mở khóa nhanh, quay video 4K, chống rung quang học, thiết kế nhỏ gọn, kháng nước kháng bụi'
);

SET @Iphone17eId = SCOPE_IDENTITY();

/* Màu iPhone 17e */
INSERT INTO product_colors_phone (product_id, color_name)
VALUES (@Iphone17eId, N'Hồng');
SET @IphonePinkId = SCOPE_IDENTITY();

INSERT INTO product_colors_phone (product_id, color_name)
VALUES (@Iphone17eId, N'Đen');
SET @IphoneBlackId = SCOPE_IDENTITY();

INSERT INTO product_colors_phone (product_id, color_name)
VALUES (@Iphone17eId, N'Trắng');
SET @IphoneWhiteId = SCOPE_IDENTITY();

/* Gallery iPhone 17e - Hồng */
INSERT INTO product_images_phone (product_id, color_id, image_url, display_order, is_primary)
VALUES
(@Iphone17eId, @IphonePinkId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/342692/iphone-17e-pink-1-639095328411069989-750x500.jpg', 1, 1),
(@Iphone17eId, @IphonePinkId, N'images/iphone-17e-pink1.jpg', 2, 0),
(@Iphone17eId, @IphonePinkId, N'images/iphone-17e-pink2.jpg', 3, 0),
(@Iphone17eId, @IphonePinkId, N'images/iphone-17e-pink3.jpg', 4, 0);

/* Gallery iPhone 17e - Đen */
INSERT INTO product_images_phone (product_id, color_id, image_url, display_order, is_primary)
VALUES
(@Iphone17eId, @IphoneBlackId, N'images/iPhone_17e-2_2.webp', 1, 1),
(@Iphone17eId, @IphoneBlackId, N'images/iphone-17e-black-2-639081454471266575-750x500.jpg', 2, 0),
(@Iphone17eId, @IphoneBlackId, N'images/iphone-17e-black-3-639081454477150583-750x500.jpg', 3, 0),
(@Iphone17eId, @IphoneBlackId, N'images/iphone-17e-black1.jpg', 4, 0);

/* Gallery iPhone 17e - Trắng */
INSERT INTO product_images_phone (product_id, color_id, image_url, display_order, is_primary)
VALUES
(@Iphone17eId, @IphoneWhiteId, N'images/iPhone_17e-2-2_2.webp', 1, 1);

/* Phiên bản iPhone 17e */
INSERT INTO product_variants_phone (product_id, color_id, storage, price, old_price, stock, image_main)
VALUES
(@Iphone17eId, @IphonePinkId,  N'256GB', 34990000, 39000000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/342692/iphone-17e-pink-1-639095328411069989-750x500.jpg'),
(@Iphone17eId, @IphonePinkId,  N'512GB', 39990000, 39000000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/342692/iphone-17e-pink-1-639095328411069989-750x500.jpg'),
(@Iphone17eId, @IphonePinkId,  N'1TB',   45990000, 39000000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/342692/iphone-17e-pink-1-639095328411069989-750x500.jpg'),

(@Iphone17eId, @IphoneBlackId, N'256GB', 34990000, 39000000, 10, N'images/iPhone_17e-2_2.webp'),
(@Iphone17eId, @IphoneBlackId, N'512GB', 39990000, 39000000, 10, N'images/iPhone_17e-2_2.webp'),
(@Iphone17eId, @IphoneBlackId, N'1TB',   45990000, 39000000, 10, N'images/iPhone_17e-2_2.webp'),

(@Iphone17eId, @IphoneWhiteId, N'256GB', 34990000, 39000000, 10, N'images/iPhone_17e-2-2_2.webp'),
(@Iphone17eId, @IphoneWhiteId, N'512GB', 39990000, 39000000, 10, N'images/iPhone_17e-2-2_2.webp'),
(@Iphone17eId, @IphoneWhiteId, N'1TB',   45990000, 39000000, 10, N'images/iPhone_17e-2-2_2.webp');
GO

/* ==========================================================
   SẢN PHẨM 2: Samsung Galaxy S26 Ultra
   Dữ liệu chuyển từ technova.sql sang cấu trúc bài 1
   ========================================================== */

DECLARE @SamsungId INT;
DECLARE @SamsungBlackId INT;
DECLARE @SamsungBlueId INT;
DECLARE @SamsungPurpleId INT;

INSERT INTO products_phone (
    name, category, brand,
    created_at, release_date,
    rating, sold,

    os, chipset, cpu, gpu, ram,

    screen_size, screen_resolution, screen_type, screen_refresh_rate, screen_features,

    rear_camera, front_camera, video_recording, camera_features,

    battery, charging, charging_port,

    network, wifi, bluetooth, nfc, sim, gps,

    memory_card,

    back_material, frame_material, weight, size, waterproof,

    sensors, special_features
)
VALUES (
    N'Samsung Galaxy S26 Ultra',
    N'phone',
    N'Samsung',

    CAST(GETDATE() AS DATE),
    NULL,

    4.8,
    245,

    N'Android',
    N'Snapdragon 8 Elite',
    NULL,
    N'Adreno GPU',
    N'12GB',

    N'6.9 inch',
    N'3120 x 1440 pixels',
    N'Dynamic AMOLED 2X',
    N'120Hz',
    NULL,

    N'200MP + 50MP + 12MP',
    N'12MP',
    N'8K, 4K, Full HD',
    NULL,

    N'5000 mAh',
    N'Sạc nhanh 45W',
    N'USB-C',

    N'5G',
    N'Wi-Fi 7',
    N'Bluetooth 5.4',
    1,
    NULL,
    NULL,

    N'Không hỗ trợ',

    NULL,
    NULL,
    NULL,
    NULL,
    NULL,

    NULL,
    N'Camera đẳng cấp, AI thông minh.'
);

SET @SamsungId = SCOPE_IDENTITY();

/* Màu Samsung S26 Ultra */
INSERT INTO product_colors_phone (product_id, color_name)
VALUES (@SamsungId, N'Đen');
SET @SamsungBlackId = SCOPE_IDENTITY();

INSERT INTO product_colors_phone (product_id, color_name)
VALUES (@SamsungId, N'Xanh Dương');
SET @SamsungBlueId = SCOPE_IDENTITY();

INSERT INTO product_colors_phone (product_id, color_name)
VALUES (@SamsungId, N'Tím');
SET @SamsungPurpleId = SCOPE_IDENTITY();

/* Gallery Samsung - Đen */
INSERT INTO product_images_phone (product_id, color_id, image_url, display_order, is_primary)
VALUES
(@SamsungId, @SamsungBlackId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-black-1-639077237590341810-750x500.jpg', 1, 1),
(@SamsungId, @SamsungBlackId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-black-2-639077237596234058-750x500.jpg', 2, 0),
(@SamsungId, @SamsungBlackId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-black-4-639077237610396757-750x500.jpg', 3, 0);

/* Gallery Samsung - Xanh */
INSERT INTO product_images_phone (product_id, color_id, image_url, display_order, is_primary)
VALUES
(@SamsungId, @SamsungBlueId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-blue-1-639088370570898166-750x500.jpg', 1, 1),
(@SamsungId, @SamsungBlueId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-blue-2-639088370576908374-750x500.jpg', 2, 0),
(@SamsungId, @SamsungBlueId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-blue-3-639088370583450228-750x500.jpg', 3, 0);

/* Gallery Samsung - Tím */
INSERT INTO product_images_phone (product_id, color_id, image_url, display_order, is_primary)
VALUES
(@SamsungId, @SamsungPurpleId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-purple-1-639077237804750607-750x500.jpg', 1, 1),
(@SamsungId, @SamsungPurpleId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-purple-2-639077237814121787-750x500.jpg', 2, 0),
(@SamsungId, @SamsungPurpleId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-purple-4-639077237827349172-750x500.jpg', 3, 0);

/* Phiên bản Samsung S26 Ultra */
INSERT INTO product_variants_phone (product_id, color_id, storage, price, old_price, stock, image_main)
VALUES
(@SamsungId, @SamsungBlackId,  N'256GB', 29990000, 34990000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-black-1-639077237590341810-750x500.jpg'),
(@SamsungId, @SamsungBlackId,  N'512GB', 34990000, 34990000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-black-1-639077237590341810-750x500.jpg'),
(@SamsungId, @SamsungBlackId,  N'1TB',   39990000, 34990000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-black-1-639077237590341810-750x500.jpg'),

(@SamsungId, @SamsungBlueId,   N'256GB', 29990000, 34990000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-blue-1-639088370570898166-750x500.jpg'),
(@SamsungId, @SamsungBlueId,   N'512GB', 34990000, 34990000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-blue-1-639088370570898166-750x500.jpg'),
(@SamsungId, @SamsungBlueId,   N'1TB',   39990000, 34990000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-blue-1-639088370570898166-750x500.jpg'),

(@SamsungId, @SamsungPurpleId, N'256GB', 29990000, 34990000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-purple-1-639077237804750607-750x500.jpg'),
(@SamsungId, @SamsungPurpleId, N'512GB', 34990000, 34990000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-purple-1-639077237804750607-750x500.jpg'),
(@SamsungId, @SamsungPurpleId, N'1TB',   39990000, 34990000, 10, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-purple-1-639077237804750607-750x500.jpg');
GO

/* ==========================================================
   5. DỮ LIỆU SẢN PHẨM CHO BÀI 2/API
   ========================================================== */

DECLARE @ProductId INT;
DECLARE @ColorPinkId INT;
DECLARE @ColorBlackId INT;
DECLARE @ColorWhiteId INT;
DECLARE @GroupId INT;

INSERT INTO products (
    name,
    category,
    brand,
    description,
    default_storage_order,
    default_color_order,
    old_price_text,
    old_price_number,
    discount,
    has_discount,
    rating,
    sold,
    is_flash_sale,
    is_featured,
    is_new,
    technical_image
)
VALUES (
    N'iPhone 17e',
    N'phone',
    N'Apple',
    N'Pro đỉnh cao.',
    1,
    1,
    N'39.000.000 đ',
    39000000,
    N'-10%',
    1,
    4.9,
    371,
    1,
    1,
    1,
    N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/342692/iphone-17e-pink-1-639095328411069989-750x500.jpg'
);

SET @ProductId = SCOPE_IDENTITY();

/* Phiên bản */

INSERT INTO product_storages (
    product_id,
    storage,
    ram,
    price_text,
    price_number,
    display_order
)
VALUES
    (@ProductId, N'256 GB', N'8 GB', N'34.990.000 đ', 34990000, 1),
    (@ProductId, N'512 GB', N'8 GB', N'39.990.000 đ', 39990000, 2),
    (@ProductId, N'1 TB',   N'8 GB', N'45.990.000 đ', 45990000, 3);

/* Màu sắc */

INSERT INTO product_colors (
    product_id,
    color_name,
    color_code,
    main_image,
    display_order
)
VALUES (
    @ProductId,
    N'Hồng',
    N'#ffc2e9',
    N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/342692/iphone-17e-pink-1-639095328411069989-750x500.jpg',
    1
);
SET @ColorPinkId = SCOPE_IDENTITY();

INSERT INTO product_colors (
    product_id,
    color_name,
    color_code,
    main_image,
    display_order
)
VALUES (
    @ProductId,
    N'Đen',
    N'#000000',
    N'images/iPhone_17e-2_2.webp',
    2
);
SET @ColorBlackId = SCOPE_IDENTITY();

INSERT INTO product_colors (
    product_id,
    color_name,
    color_code,
    main_image,
    display_order
)
VALUES (
    @ProductId,
    N'Trắng',
    N'#ffffff',
    N'images/iPhone_17e-2-2_2.webp',
    3
);
SET @ColorWhiteId = SCOPE_IDENTITY();

/* Gallery màu 1 */

INSERT INTO product_color_images (
    product_id,
    color_id,
    image_url,
    display_order
)
VALUES
    (@ProductId, @ColorPinkId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/342692/iphone-17e-pink-1-639095328411069989-750x500.jpg', 1),
    (@ProductId, @ColorPinkId, N'images/iphone-17e-pink1.jpg', 2),
    (@ProductId, @ColorPinkId, N'images/iphone-17e-pink2.jpg', 3),
    (@ProductId, @ColorPinkId, N'images/iphone-17e-pink3.jpg', 4);

/* Gallery màu 2 */

INSERT INTO product_color_images (
    product_id,
    color_id,
    image_url,
    display_order
)
VALUES
    (@ProductId, @ColorBlackId, N'images/iPhone_17e-2_2.webp', 1),
    (@ProductId, @ColorBlackId, N'images/iphone-17e-black-2-639081454471266575-750x500.jpg', 2),
    (@ProductId, @ColorBlackId, N'images/iphone-17e-black-3-639081454477150583-750x500.jpg', 3),
    (@ProductId, @ColorBlackId, N'images/iphone-17e-black1.jpg', 4);

/* Gallery màu 3 */

INSERT INTO product_color_images (
    product_id,
    color_id,
    image_url,
    display_order
)
VALUES
    (@ProductId, @ColorWhiteId, N'images/iPhone_17e-2-2_2.webp', 1);

/* ==========================================================
   THÔNG SỐ KỸ THUẬT
   ========================================================== */

/* Màn hình */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Màn hình', 1);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Kích thước màn hình', N'6.1 inch', 1),
    (@GroupId, N'Công nghệ màn hình', N'Super Retina XDR OLED', 2),
    (@GroupId, N'Độ phân giải', N'2532 x 1170 pixels', 3),
    (@GroupId, N'Tính năng màn hình', N'HDR10, Dolby Vision, Always-on display', 4),
    (@GroupId, N'Tần số quét', N'120Hz', 5),
    (@GroupId, N'Kiểu màn hình', N'IPS LCD', 6);

/* Camera */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Camera', 2);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Camera sau', N'12MP, chống rung quang học OIS', 1),
    (@GroupId, N'Camera trước', N'12MP, khẩu độ f/1.9', 2),
    (@GroupId, N'Quay video', N'4K@30fps, Full HD 1080p', 3),
    (@GroupId, N'Tính năng camera', N'HDR, lấy nét tự động, panorama, chống rung điện tử', 4);

/* Vi xử lý & đồ họa */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Vi xử lý & đồ họa', 3);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Chipset', N'Apple A15 Bionic', 1),
    (@GroupId, N'GPU', N'Apple GPU', 2);

/* Giao tiếp & kết nối */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Giao tiếp & kết nối', 4);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Công nghệ NFC', N'Không', 1),
    (@GroupId, N'Thẻ SIM', N'1 Nano-SIM', 2),
    (@GroupId, N'GPS', N'A-GPS, GLONASS', 3);

/* RAM & Bộ nhớ */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'RAM & Bộ nhớ', 5);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'RAM', N'{ram}', 1),
    (@GroupId, N'Bộ nhớ trong', N'{storage}', 2);

/* Hệ điều hành */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Hệ điều hành', 6);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Hệ điều hành', N'iOS 10', 1);

/* Kích thước & trọng lượng */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Kích thước & trọng lượng', 7);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Kích thước', N'138.3 x 67.1 x 7.1 mm', 1),
    (@GroupId, N'Trọng lượng', N'138 g', 2);

/* Kháng nước */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Kháng nước', 8);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Chỉ số kháng nước', N'IP68', 1);

/* Pin & sạc */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Pin & sạc', 9);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Dung lượng pin', N'5960 mAh', 1),
    (@GroupId, N'Công nghệ sạc', N'Sạc tiêu chuẩn 100W', 2);

/* Cảm biến & tính năng đặc biệt */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Cảm biến & tính năng đặc biệt', 10);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Cảm biến', N'Cảm biến vân tay, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển', 1),
    (@GroupId, N'Tính năng đặc biệt', N'Mở khóa nhanh, quay video 4K, chống rung quang học, thiết kế nhỏ gọn, kháng nước kháng bụi', 2),
    (@GroupId, N'Cổng sạc', N'Lightning', 3);

/* Kết nối */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Kết nối', 11);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Tương thích mạng', N'4G LTE', 1),
    (@GroupId, N'Công nghệ Wifi', N'Wi-Fi 5', 2),
    (@GroupId, N'Bluetooth', N'Bluetooth 4.2', 3),
    (@GroupId, N'Thẻ nhớ', N'Không hỗ trợ', 4);

/* Thiết kế & hoàn thiện */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Thiết kế & hoàn thiện', 12);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Vật liệu khung', N'Khung nhôm nguyên khối', 1),
    (@GroupId, N'Mặt lưng', N'Nhôm', 2);

/* Thông tin chung */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Thông tin chung', 13);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Thời điểm ra mắt', N'2016-09-16', 1);

/* Đánh giá */

INSERT INTO product_reviews (
    product_id,
    reviewer_name,
    rating,
    comment
)
VALUES
    (@ProductId, N'Phúc Nguyễn', 1, N'Máy chơi game chưa ổn định, đôi lúc bị drop FPS.'),
    (@ProductId, N'Cường Văn Nguyễn', 5, N'Máy dùng khá mượt, thiết kế đẹp, đáng mua.'),
    (@ProductId, N'Luân Hồng', 5, N'Giao diện đẹp, chức năng ổn, trải nghiệm tốt.'),
    (@ProductId, N'Nguyễn Phát', 5, N'Sản phẩm tốt, phù hợp với nhu cầu sử dụng hằng ngày.');
GO


/* ==========================================================
   SẢN PHẨM 2: Samsung Galaxy S26 Ultra
   ========================================================== */

DECLARE @ProductId INT;
DECLARE @ColorBlackId INT;
DECLARE @ColorBlueId INT;
DECLARE @ColorPurpleId INT;
DECLARE @GroupId INT;

INSERT INTO products (
    name,
    category,
    brand,
    description,
    default_storage_order,
    default_color_order,
    old_price_text,
    old_price_number,
    discount,
    has_discount,
    rating,
    sold,
    is_flash_sale,
    is_featured,
    is_new,
    technical_image
)
VALUES (
    N'Samsung Galaxy S26 Ultra',
    N'phone',
    N'Samsung',
    N'Camera đẳng cấp, AI thông minh.',
    1,
    1,
    N'34.990.000 đ',
    34990000,
    N'-14%',
    1,
    4.8,
    245,
    0,
    1,
    1,
    N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-black-1-639077237590341810-750x500.jpg'
);

SET @ProductId = SCOPE_IDENTITY();


/* Phiên bản */

INSERT INTO product_storages (
    product_id,
    storage,
    ram,
    price_text,
    price_number,
    display_order
)
VALUES
    (@ProductId, N'256 GB', N'12 GB', N'29.990.000 đ', 29990000, 1),
    (@ProductId, N'512 GB', N'12 GB', N'34.990.000 đ', 34990000, 2),
    (@ProductId, N'1 TB',   N'12 GB', N'39.990.000 đ', 39990000, 3);


/* Màu sắc */

INSERT INTO product_colors (
    product_id,
    color_name,
    color_code,
    main_image,
    display_order
)
VALUES (
    @ProductId,
    N'Đen',
    N'#000000',
    N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-black-1-639077237590341810-750x500.jpg',
    1
);
SET @ColorBlackId = SCOPE_IDENTITY();

INSERT INTO product_colors (
    product_id,
    color_name,
    color_code,
    main_image,
    display_order
)
VALUES (
    @ProductId,
    N'Xanh Dương',
    N'#037dff',
    N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-blue-1-639088370570898166-750x500.jpg',
    2
);
SET @ColorBlueId = SCOPE_IDENTITY();

INSERT INTO product_colors (
    product_id,
    color_name,
    color_code,
    main_image,
    display_order
)
VALUES (
    @ProductId,
    N'Tím',
    N'#91008a',
    N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-purple-1-639077237804750607-750x500.jpg',
    3
);
SET @ColorPurpleId = SCOPE_IDENTITY();


/* Gallery màu Đen */

INSERT INTO product_color_images (
    product_id,
    color_id,
    image_url,
    display_order
)
VALUES
    (@ProductId, @ColorBlackId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-black-1-639077237590341810-750x500.jpg', 1),
    (@ProductId, @ColorBlackId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-black-2-639077237596234058-750x500.jpg', 2),
    (@ProductId, @ColorBlackId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-black-4-639077237610396757-750x500.jpg', 3);


/* Gallery màu Xanh */

INSERT INTO product_color_images (
    product_id,
    color_id,
    image_url,
    display_order
)
VALUES
    (@ProductId, @ColorBlueId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-blue-1-639088370570898166-750x500.jpg', 1),
    (@ProductId, @ColorBlueId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-blue-2-639088370576908374-750x500.jpg', 2),
    (@ProductId, @ColorBlueId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-blue-3-639088370583450228-750x500.jpg', 3);


/* Gallery màu Tím */

INSERT INTO product_color_images (
    product_id,
    color_id,
    image_url,
    display_order
)
VALUES
    (@ProductId, @ColorPurpleId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-purple-1-639077237804750607-750x500.jpg', 1),
    (@ProductId, @ColorPurpleId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-purple-2-639077237814121787-750x500.jpg', 2),
    (@ProductId, @ColorPurpleId, N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/361951/samsung-galaxy-s26-ultra-purple-4-639077237827349172-750x500.jpg', 3);


/* ==========================================================
   THÔNG SỐ KỸ THUẬT
   ========================================================== */

/* Màn hình */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Màn hình', 1);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Kích thước màn hình', N'6.9 inch', 1),
    (@GroupId, N'Công nghệ màn hình', N'Dynamic AMOLED 2X', 2),
    (@GroupId, N'Độ phân giải', N'3120 x 1440 pixels', 3),
    (@GroupId, N'Tần số quét', N'120Hz', 4);


/* Camera */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Camera', 2);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Camera sau', N'200MP + 50MP + 12MP', 1),
    (@GroupId, N'Camera trước', N'12MP', 2),
    (@GroupId, N'Quay video', N'8K, 4K, Full HD', 3);


/* Vi xử lý & đồ họa */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Vi xử lý & đồ họa', 3);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Chipset', N'Snapdragon 8 Elite', 1),
    (@GroupId, N'GPU', N'Adreno GPU', 2);


/* RAM & Bộ nhớ */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'RAM & Bộ nhớ', 4);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'RAM', N'{ram}', 1),
    (@GroupId, N'Bộ nhớ trong', N'{storage}', 2);


/* Pin & sạc */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Pin & sạc', 5);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Dung lượng pin', N'5000 mAh', 1),
    (@GroupId, N'Công nghệ sạc', N'Sạc nhanh 45W', 2);


/* Kết nối */
INSERT INTO product_spec_groups (product_id, title, display_order)
VALUES (@ProductId, N'Kết nối', 6);
SET @GroupId = SCOPE_IDENTITY();

INSERT INTO product_spec_items (group_id, label, value, display_order)
VALUES
    (@GroupId, N'Tương thích mạng', N'5G', 1),
    (@GroupId, N'Công nghệ Wifi', N'Wi-Fi 7', 2),
    (@GroupId, N'Bluetooth', N'Bluetooth 5.4', 3);


/* Đánh giá */

INSERT INTO product_reviews (
    product_id,
    reviewer_name,
    rating,
    comment
)
VALUES
    (@ProductId, N'Minh Khang', 5, N'Máy đẹp, màn hình sắc nét, hiệu năng mạnh.'),
    (@ProductId, N'Thanh Tùng', 4, N'Camera tốt, pin ổn, giá hơi cao.'),
    (@ProductId, N'Hoàng Nam', 5, N'Dùng rất mượt, đáng tiền.');

GO

/* ==========================================================
   6. KIỂM TRA NHANH SAU KHI CHẠY
   ========================================================== */

SELECT name FROM sys.tables ORDER BY name;
SELECT id, name, brand FROM products_phone;
SELECT id, name, brand, category FROM products;
GO
SELECT name 
FROM sys.databases;