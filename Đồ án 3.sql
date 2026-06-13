CREATE DATABASE Technova;
GO

USE Technova;
GO

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

    CONSTRAINT uq_product_color UNIQUE (product_id, color_name)
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

    -- ❌ BỎ CASCADE Ở ĐÂY
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

    CONSTRAINT fk_variant_product
    FOREIGN KEY (product_id) REFERENCES products_phone(id)
    ON DELETE CASCADE,

    -- ❌ BỎ CASCADE Ở ĐÂY
    CONSTRAINT fk_variant_color
    FOREIGN KEY (color_id) REFERENCES product_colors_phone(id)
);
GO

--Đánh giá dùng chung toàn ngành hàng

CREATE TABLE product_reviews (
    id INT PRIMARY KEY IDENTITY(1,1),

    product_id INT NOT NULL,
    product_type NVARCHAR(50) NOT NULL,

    user_id INT NOT NULL,

    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment NVARCHAR(MAX),

    created_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT fk_review_product
    FOREIGN KEY (product_id) REFERENCES products_phone(id)
    ON DELETE CASCADE,

    CONSTRAINT fk_review_user
    FOREIGN KEY (user_id) REFERENCES accounts(id),

    CONSTRAINT uq_user_product 
    UNIQUE (user_id, product_id, product_type)
);
GO


--Tài khoản-------------------------------------------------------------------
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

ALTER TABLE customer_profiles
ALTER COLUMN avatar_data VARBINARY(MAX);

ALTER TABLE customer_profiles
ALTER COLUMN avatar_mime NVARCHAR(50);

ALTER TABLE customer_profiles
ADD avatar_original_data VARBINARY(MAX),
    avatar_original_mime NVARCHAR(100);

Select * from customer_profiles
SELECT * FROM accounts;
drop table customer_profiles

DELETE FROM customer_profiles;
DELETE FROM accounts;
DBCC CHECKIDENT ('accounts', RESEED, 0);
DBCC CHECKIDENT ('customer_profiles', RESEED, 0);

CREATE TABLE customer_profiles (
    id INT PRIMARY KEY IDENTITY(1,1),

    account_id INT NOT NULL UNIQUE,

    full_name NVARCHAR(255),
    gender NVARCHAR(20),
    date_of_birth DATE,

    avatar_data VARBINARY(MAX),
    avatar_mime NVARCHAR(50),

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

    FOREIGN KEY (account_id)
    REFERENCES accounts(id)
    ON DELETE CASCADE
);
GO


















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
VALUES
(
N'iPhone 7',
N'phone',
N'Apple',

'2016-09-16',
'2016-09-16',

0,
0,

N'iOS 10 (hỗ trợ nâng cấp đến iOS 15)',
N'Apple A10 Fusion',
N'Quad-core (2 nhân hiệu năng + 2 nhân tiết kiệm điện)',
N'Apple GPU 6 nhân',
N'2GB',

N'4.7 inch',
N'1334 x 750 pixels',
N'IPS LCD',
N'60Hz',
N'Retina HD, 326 ppi, độ sáng 625 nits, True Tone, hiển thị màu sắc chính xác',

N'12MP (wide), khẩu độ f/1.8, chống rung quang học OIS',
N'Camera trước 7MP, khẩu độ f/2.2',
N'Quay video 4K@30fps, Full HD 1080p@30/60/120fps',
N'HDR, lấy nét tự động, panorama, chống rung điện tử',

N'1960 mAh',
N'Sạc tiêu chuẩn 10W',
N'Lightning',

N'4G LTE',
N'Wi-Fi 5 (802.11ac)',
N'Bluetooth 4.2',
1,
N'1 Nano-SIM',
N'A-GPS, GLONASS',

N'Không hỗ trợ',

N'Khung nhôm nguyên khối',
N'Khung nhôm',
N'138g',
N'138.3 x 67.1 x 7.1 mm',
N'IP67 (kháng nước và bụi)',

N'Cảm biến vân tay (Touch ID), cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Touch ID mở khóa nhanh và bảo mật, quay video 4K ổn định, chụp ảnh tốt với chống rung quang học, thiết kế nhỏ gọn dễ sử dụng, kháng nước kháng bụi, hiệu năng ổn định từ chip A10 Fusion'
),

(
N'iPhone 7 Plus',
N'phone',
N'Apple',

'2016-09-16',
'2016-09-16',

0,
0,

N'iOS 10 (hỗ trợ nâng cấp đến iOS 15)',
N'Apple A10 Fusion',
N'Quad-core (2 nhân hiệu năng + 2 nhân tiết kiệm điện)',
N'Apple GPU 6 nhân',
N'3GB',

N'5.5 inch',
N'1920 x 1080 pixels',
N'IPS LCD',
N'60Hz',
N'Retina HD, 401 ppi, độ sáng 625 nits, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (telephoto), chống rung quang học OIS',
N'Camera trước 7MP, khẩu độ f/2.2',
N'Quay video 4K@30fps, Full HD 1080p@30/60/120fps',
N'HDR, zoom quang học 2x, chụp chân dung, chống rung điện tử',

N'2900 mAh',
N'Sạc tiêu chuẩn 10W',
N'Lightning',

N'4G LTE',
N'Wi-Fi 5 (802.11ac)',
N'Bluetooth 4.2',
1,
N'1 Nano-SIM',
N'A-GPS, GLONASS',

N'Không hỗ trợ',

N'Khung nhôm nguyên khối',
N'Khung nhôm',
N'188g',
N'158.2 x 77.9 x 7.3 mm',
N'IP67 (kháng nước và bụi)',

N'Cảm biến vân tay (Touch ID), cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Touch ID mở khóa nhanh và bảo mật, camera kép hỗ trợ zoom quang học và chụp chân dung, quay video 4K ổn định, kháng nước kháng bụi, hiệu năng ổn định từ chip A10 Fusion'
),

(
N'iPhone 8',
N'phone',
N'Apple',

'2017-09-22',
'2017-09-22',

0,
0,

N'iOS 11 (hỗ trợ nâng cấp đến iOS 16)',
N'Apple A11 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 3 nhân',
N'2GB',

N'4.7 inch',
N'1334 x 750 pixels',
N'IPS LCD',
N'60Hz',
N'Retina HD, True Tone, độ sáng 625 nits, hiển thị màu sắc chính xác',

N'12MP (wide), chống rung quang học OIS',
N'Camera trước 7MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps',
N'HDR, tự động lấy nét, chống rung điện tử',

N'1821 mAh',
N'Sạc nhanh 15W, sạc không dây Qi',
N'Lightning',

N'4G LTE',
N'Wi-Fi 5 (802.11ac)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM',
N'A-GPS, GLONASS',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'148g',
N'138.4 x 67.3 x 7.3 mm',
N'IP67 (kháng nước và bụi)',

N'Cảm biến vân tay (Touch ID), cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Touch ID mở khóa nhanh và bảo mật, hỗ trợ sạc không dây, quay video 4K ổn định, chụp ảnh tốt với chống rung quang học, thiết kế nhỏ gọn dễ sử dụng, kháng nước kháng bụi, hiệu năng ổn định từ chip A11 Bionic'
),

(
N'iPhone 8 Plus',
N'phone',
N'Apple',

'2017-09-22',
'2017-09-22',

0,
0,

N'iOS 11 (hỗ trợ nâng cấp đến iOS 16)',
N'Apple A11 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 3 nhân',
N'3GB',

N'5.5 inch',
N'1920 x 1080 pixels',
N'IPS LCD',
N'60Hz',
N'Retina HD, True Tone, độ sáng 625 nits, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (telephoto), chống rung quang học OIS',
N'Camera trước 7MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps',
N'HDR, zoom quang học 2x, chụp chân dung, chống rung điện tử',

N'2691 mAh',
N'Sạc nhanh 15W, sạc không dây Qi',
N'Lightning',

N'4G LTE',
N'Wi-Fi 5 (802.11ac)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM',
N'A-GPS, GLONASS',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'202g',
N'158.4 x 78.1 x 7.5 mm',
N'IP67 (kháng nước và bụi)',

N'Cảm biến vân tay (Touch ID), cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Touch ID mở khóa nhanh và bảo mật, hỗ trợ sạc không dây, chụp ảnh chân dung với camera kép, quay video 4K ổn định, kháng nước kháng bụi, hiệu năng tốt từ chip A11 Bionic'
),

(
N'iPhone X',
N'phone',
N'Apple',

'2017-11-03',
'2017-11-03',

0,
0,

N'iOS 11 (hỗ trợ nâng cấp đến iOS 16)',
N'Apple A11 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 3 nhân',
N'3GB',

N'5.8 inch',
N'2436 x 1125 pixels',
N'Super Retina OLED',
N'60Hz',
N'HDR10, Dolby Vision, 458 ppi, True Tone, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (telephoto), chống rung quang học OIS kép',
N'Camera trước 7MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps',
N'HDR, chụp chân dung, Animoji, chống rung điện tử',

N'2716 mAh',
N'Sạc nhanh 15W, sạc không dây Qi',
N'Lightning',

N'4G LTE',
N'Wi-Fi 5 (802.11ac)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM',
N'A-GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung thép không gỉ',
N'174g',
N'143.6 x 70.9 x 7.7 mm',
N'IP67 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Face ID bảo mật cao, thiết kế màn hình tràn viền, hỗ trợ sạc không dây, chụp ảnh chân dung, quay video 4K ổn định, kháng nước kháng bụi, hiệu năng tốt từ chip A11 Bionic'
),

(
N'iPhone XR',
N'phone',
N'Apple',

'2018-10-26',
'2018-10-26',

0,
0,

N'iOS 12 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A12 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'3GB',

N'6.1 inch',
N'1792 x 828 pixels',
N'Liquid Retina IPS LCD',
N'60Hz',
N'326 ppi, True Tone, độ sáng 625 nits, hiển thị màu sắc chính xác',

N'12MP (wide), chống rung quang học OIS',
N'Camera trước 7MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps',
N'Smart HDR, chụp chân dung (Portrait Mode), chống rung điện tử',

N'2942 mAh',
N'Sạc nhanh 15W, sạc không dây Qi',
N'Lightning',

N'4G LTE',
N'Wi-Fi 5 (802.11ac)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'A-GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'194g',
N'150.9 x 75.7 x 8.3 mm',
N'IP67 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Face ID bảo mật cao, chụp ảnh chân dung với một camera duy nhất, quay video 4K ổn định, hiệu năng tốt từ chip A12 Bionic, hỗ trợ sạc không dây, kháng nước kháng bụi'
),

(
N'iPhone XS',
N'phone',
N'Apple',

'2018-09-21',
'2018-09-21',

0,
0,

N'iOS 12 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A12 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'4GB',

N'5.8 inch',
N'2436 x 1125 pixels',
N'Super Retina OLED',
N'60Hz',
N'HDR10, Dolby Vision, 458 ppi, True Tone, độ sáng cao, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (telephoto), chống rung quang học OIS kép',
N'Camera trước 7MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps',
N'Smart HDR, chụp chân dung, zoom quang học 2x, chống rung điện tử',

N'2658 mAh',
N'Sạc nhanh 15W, sạc không dây Qi',
N'Lightning',

N'4G LTE',
N'Wi-Fi 5 (802.11ac)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'A-GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung thép không gỉ',
N'177g',
N'143.6 x 70.9 x 7.7 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Face ID bảo mật cao, chụp ảnh chân dung với hiệu ứng xóa phông, quay video 4K ổn định, hiệu năng ổn định từ chip A12 Bionic, hỗ trợ sạc không dây, kháng nước kháng bụi'
),

(
N'iPhone XS Max',
N'phone',
N'Apple',

'2018-09-21',
'2018-09-21',

0,
0,

N'iOS 12 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A12 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'4GB',

N'6.5 inch',
N'2688 x 1242 pixels',
N'Super Retina OLED',
N'60Hz',
N'HDR10, Dolby Vision, 458 ppi, True Tone, độ sáng cao, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (telephoto), chống rung quang học OIS kép',
N'Camera trước 7MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps',
N'Smart HDR, chụp chân dung, zoom quang học 2x, chống rung điện tử',

N'3174 mAh',
N'Sạc nhanh 15W, sạc không dây Qi',
N'Lightning',

N'4G LTE',
N'Wi-Fi 5 (802.11ac)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'A-GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung thép không gỉ',
N'208g',
N'157.5 x 77.4 x 7.7 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Face ID bảo mật cao, chụp ảnh chân dung với hiệu ứng xóa phông, quay video 4K ổn định, hiệu năng ổn định từ chip A12 Bionic, hỗ trợ sạc không dây, kháng nước kháng bụi'
),

(
N'iPhone 11',
N'phone',
N'Apple',

'2019-09-20',
'2019-09-20',

0,
0,

N'iOS 13 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A13 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'4GB',

N'6.1 inch',
N'1792 x 828 pixels',
N'Liquid Retina IPS LCD',
N'60Hz',
N'326 ppi, True Tone, độ sáng 625 nits, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (ultra-wide), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps',
N'Smart HDR, Deep Fusion, Night Mode, chụp chân dung, góc siêu rộng, chống rung điện tử',

N'3110 mAh',
N'Sạc nhanh 18W, sạc không dây Qi',
N'Lightning',

N'4G LTE',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'194g',
N'150.9 x 75.7 x 8.3 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Face ID bảo mật cao, chụp ảnh linh hoạt với camera góc rộng và siêu rộng, quay video 4K ổn định, kháng nước kháng bụi, hiệu năng ổn định từ chip A13 Bionic'
),

(
N'iPhone 11 Pro',
N'phone',
N'Apple',

'2019-09-20',
'2019-09-20',

0,
0,

N'iOS 13 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A13 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'4GB',

N'5.8 inch',
N'2436 x 1125 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'HDR10, Dolby Vision, True Tone, 458 ppi, độ sáng cao, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (ultra-wide) + 12MP (telephoto), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps',
N'Night Mode, Smart HDR, Deep Fusion, zoom quang học 2x, chụp chân dung, chống rung điện tử',

N'3046 mAh',
N'Sạc nhanh 18W, sạc không dây Qi',
N'Lightning',

N'4G LTE',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính nhám',
N'Khung thép không gỉ',
N'188g',
N'144 x 71.4 x 8.1 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế',
N'Face ID bảo mật cao, chụp ảnh linh hoạt với hệ thống 3 camera, Night Mode cải thiện chụp thiếu sáng, quay video 4K ổn định, kháng nước kháng bụi, hiệu năng ổn định từ chip A13 Bionic'
),
(
N'iPhone 11 Pro Max',
N'phone',
N'Apple',

'2019-09-20',
'2019-09-20',

0,
0,

N'iOS 13 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A13 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'4GB',

N'6.5 inch',
N'2688 x 1242 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'HDR10, Dolby Vision, True Tone, độ sáng cao, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (ultra-wide) + 12MP (telephoto), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps',
N'Night Mode, Smart HDR, Deep Fusion, zoom quang học 2x, chụp chân dung, chống rung điện tử',

N'3969 mAh',
N'Sạc nhanh 18W, sạc không dây Qi',
N'Lightning',

N'4G LTE',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính nhám',
N'Khung thép không gỉ',
N'226g',
N'158 x 77.8 x 8.1 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế',
N'Face ID bảo mật cao, chụp ảnh linh hoạt với 3 camera, Night Mode cải thiện chụp thiếu sáng, quay video 4K ổn định, thời lượng pin dài, kháng nước kháng bụi, hiệu năng ổn định từ chip A13 Bionic'
),

(
N'iPhone 12 mini',
N'phone',
N'Apple',

'2020-11-13',
'2020-11-13',

0,
0,

N'iOS 14 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A14 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'4GB',

N'5.4 inch',
N'2340 x 1080 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'HDR10, Dolby Vision, True Tone, Ceramic Shield, độ sáng cao, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (ultra-wide), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR',
N'Night Mode, Deep Fusion, Smart HDR 3, chụp chân dung, chống rung điện tử',

N'2227 mAh',
N'Sạc nhanh 20W, MagSafe, sạc không dây Qi',
N'Lightning',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'135g',
N'131.5 x 64.2 x 7.4 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Hỗ trợ 5G tốc độ cao, MagSafe tương thích phụ kiện, Face ID bảo mật cao, thiết kế nhỏ gọn dễ cầm nắm, quay video Dolby Vision, chụp ảnh ổn định, kháng nước kháng bụi, hiệu năng mạnh mẽ từ chip A14 Bionic'
),

(
N'iPhone 12',
N'phone',
N'Apple',

'2020-10-23',
'2020-10-23',

0,
0,

N'iOS 14 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A14 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'4GB',

N'6.1 inch',
N'2532 x 1170 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'HDR10, Dolby Vision, True Tone, Ceramic Shield, độ sáng cao, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (ultra-wide), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR',
N'Night Mode, Deep Fusion, Smart HDR 3, chụp chân dung, chống rung điện tử',

N'2815 mAh',
N'Sạc nhanh 20W, MagSafe, sạc không dây Qi',
N'Lightning',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'164g',
N'146.7 x 71.5 x 7.4 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Hỗ trợ 5G tốc độ cao, MagSafe tương thích phụ kiện, Face ID bảo mật cao, quay video Dolby Vision, chụp ảnh ổn định, kháng nước kháng bụi, hiệu năng mạnh mẽ từ chip A14 Bionic'
),

(
N'iPhone 12 Pro',
N'phone',
N'Apple',

'2020-10-23',
'2020-10-23',

0,
0,

N'iOS 14 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A14 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'6GB',

N'6.1 inch',
N'2532 x 1170 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'HDR10, Dolby Vision, True Tone, độ sáng cao, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (ultra-wide) + 12MP (telephoto) + LiDAR, chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR',
N'Night Mode, Deep Fusion, Smart HDR 3, chụp chân dung, ProRAW, zoom quang học 2x, hỗ trợ LiDAR',

N'2815 mAh',
N'Sạc nhanh 20W, MagSafe, sạc không dây Qi',
N'Lightning',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính nhám',
N'Khung thép không gỉ',
N'189g',
N'146.7 x 71.5 x 7.4 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế',
N'Hỗ trợ 5G, Face ID bảo mật cao, chụp ảnh chuyên nghiệp với LiDAR, quay video Dolby Vision, zoom quang học 2x, hiệu năng ổn định từ chip A14 Bionic, kháng nước kháng bụi'
),

(
N'iPhone 12 Pro Max',
N'phone',
N'Apple',

'2020-11-13',
'2020-11-13',

0,
0,

N'iOS 14 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A14 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'6GB',

N'6.7 inch',
N'2778 x 1284 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'HDR10, Dolby Vision, True Tone, độ sáng cao, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (ultra-wide) + 12MP (telephoto) + LiDAR, chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR',
N'Zoom quang học 2.5x, Night Mode, Deep Fusion, Smart HDR 3, chụp chân dung, ProRAW, hỗ trợ LiDAR',

N'3687 mAh',
N'Sạc nhanh 20W, MagSafe, sạc không dây Qi',
N'Lightning',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính nhám',
N'Khung thép không gỉ',
N'228g',
N'160.8 x 78.1 x 7.4 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế',
N'Hỗ trợ 5G, Face ID bảo mật cao, chụp ảnh chuyên nghiệp với LiDAR, quay video Dolby Vision, zoom quang học 2.5x, hiệu năng ổn định từ chip A14 Bionic, kháng nước kháng bụi, thời lượng pin tốt'
),

(
N'iPhone 13',
N'phone',
N'Apple',

'2021-09-24',
'2021-09-24',

0,
0,

N'iOS 15 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A15 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'4GB',

N'6.1 inch',
N'2532 x 1170 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'460 ppi, HDR10, Dolby Vision, True Tone, độ sáng cao, hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (ultra-wide), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, Cinematic Mode',
N'Night Mode, Smart HDR 4, Deep Fusion, chụp chân dung, chống rung điện tử',

N'3240 mAh',
N'Sạc nhanh 20W, MagSafe, sạc không dây Qi',
N'Lightning',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'174g',
N'146.7 x 71.5 x 7.7 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Hỗ trợ 5G, Face ID bảo mật cao, quay video Dolby Vision, chụp ảnh ổn định với nhiều chế độ, Cinematic Mode quay video xóa phông, kháng nước kháng bụi, hiệu năng ổn định từ chip A15 Bionic'
),

(
N'iPhone 13 Pro',
N'phone',
N'Apple',

'2021-09-24',
'2021-09-24',

0,
0,

N'iOS 15 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A15 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 5 nhân',
N'6GB',

N'6.1 inch',
N'2532 x 1170 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, HDR10, Dolby Vision, True Tone, độ sáng cao, hỗ trợ hiển thị màu sắc chính xác',

N'12MP (wide) + 12MP (ultra-wide) + 12MP (telephoto) + LiDAR, chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, ProRes, Cinematic Mode',
N'Night Mode, Deep Fusion, Smart HDR, chụp macro, chụp chân dung, zoom quang học 3x, ProRAW',

N'3095 mAh',
N'Sạc nhanh 20W, MagSafe, sạc không dây Qi',
N'Lightning',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung thép không gỉ',
N'204g',
N'146.7 x 71.5 x 7.7 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế',
N'Hỗ trợ 5G, Face ID bảo mật cao, ProMotion 120Hz cho trải nghiệm mượt mà, quay video ProRes chuyên nghiệp, chụp ảnh chất lượng cao với nhiều chế độ, macro photography, zoom quang học 3x, kháng nước kháng bụi, hiệu năng ổn định từ chip A15 Bionic'
),

(
N'iPhone 13 Pro Max',
N'phone',
N'Apple',

'2021-09-24',
'2021-09-24',

0,
0,

N'iOS 15 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A15 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 5 nhân',
N'6GB',

N'6.7 inch',
N'2778 x 1284 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, HDR10, Dolby Vision, True Tone, độ sáng cao',

N'12MP (wide) + 12MP (ultra-wide) + 12MP (telephoto) + LiDAR, chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, ProRes, Cinematic Mode',
N'Night Mode, Deep Fusion, Smart HDR, chụp macro, chụp chân dung, ProRAW',

N'4352 mAh',
N'Sạc nhanh 27W, MagSafe, sạc không dây Qi',
N'Lightning',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.0',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung thép không gỉ',
N'240g',
N'160.8 x 78.1 x 7.7 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế',
N'Hỗ trợ 5G, Face ID bảo mật cao, ProMotion 120Hz, quay video ProRes, chụp ảnh chuyên nghiệp, macro photography, pin dung lượng lớn cho thời gian sử dụng dài, kháng nước kháng bụi'
),

(
N'iPhone 14',
N'phone',
N'Apple',

'2022-09-16',
'2022-09-16',

0,
0,

N'iOS 16 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A15 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 5 nhân',
N'6GB',

N'6.1 inch',
N'2532 x 1170 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'HDR10, Dolby Vision, True Tone, độ sáng cao',

N'12MP (wide) + 12MP (ultra-wide), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/1.9',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, Cinematic Mode',
N'Photonic Engine, Smart HDR, Deep Fusion, Night Mode, chụp chân dung',

N'3279 mAh',
N'Sạc nhanh 20W, MagSafe, sạc không dây Qi',
N'Lightning',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.3',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'172g',
N'146.7 x 71.5 x 7.8 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Hỗ trợ 5G, Face ID bảo mật cao, chụp ảnh ổn định, quay video Dolby Vision, Emergency SOS via Satellite, phát hiện va chạm (Crash Detection), kháng nước kháng bụi'
),

(
N'iPhone 14 Pro',
N'phone',
N'Apple',

'2022-09-16',
'2022-09-16',

0,
0,

N'iOS 16 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A16 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 5 nhân',
N'6GB',

N'6.1 inch',
N'2556 x 1179 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, Always-on Display, HDR10, Dolby Vision, True Tone, độ sáng cao',

N'48MP (wide) + 12MP (ultra-wide) + 12MP (telephoto) + LiDAR, chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/1.9',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, ProRes, Cinematic Mode',
N'Photonic Engine, Smart HDR, Deep Fusion, Night Mode, chụp chân dung, ProRAW',

N'3200 mAh',
N'Sạc nhanh 20W, MagSafe, sạc không dây Qi',
N'Lightning',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.3',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung thép không gỉ',
N'206g',
N'147.5 x 71.5 x 7.85 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế',
N'Hỗ trợ 5G, Dynamic Island, Always-on Display, Face ID bảo mật cao, chụp ảnh chuyên nghiệp, quay video ProRes, hiệu năng mạnh mẽ từ chip A16 Bionic, kháng nước kháng bụi'
),

(
N'iPhone 14 Pro Max',
N'phone',
N'Apple',

'2022-09-16',
'2022-09-16',

0,
0,

N'iOS 16 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A16 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 5 nhân',
N'6GB',

N'6.7 inch',
N'2796 x 1290 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, Always-on Display, HDR10, Dolby Vision, True Tone, độ sáng cao',

N'48MP (wide) + 12MP (ultra-wide) + 12MP (telephoto) + LiDAR, chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/1.9',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, ProRes, Cinematic Mode',
N'Photonic Engine, Smart HDR, Deep Fusion, Night Mode, chụp chân dung, ProRAW',

N'4323 mAh',
N'Sạc nhanh 27W, MagSafe, sạc không dây Qi',
N'Lightning',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.3',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung thép không gỉ',
N'240g',
N'160.7 x 77.6 x 7.85 mm',
N'IP68 (kháng nước và bụi)',

N'Face ID, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế',
N'Hỗ trợ 5G, Face ID bảo mật cao, Always-on Display, Dynamic Island, chụp ảnh chuyên nghiệp, quay video ProRes, pin dung lượng lớn cho thời gian sử dụng dài, kháng nước kháng bụi'
),

(
N'iPhone 15',
N'phone',
N'Apple',

'2023-09-22',
'2023-09-22',

0,
0,

N'iOS 17 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A16 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 5 nhân',
N'6GB',

N'6.1 inch',
N'2556 x 1179 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'Dynamic Island, HDR10, Dolby Vision, True Tone, độ sáng cao',

N'48MP (wide) + 12MP (ultra-wide), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/1.9',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, Cinematic Mode',
N'Photonic Engine, Smart HDR, Deep Fusion, Night Mode, chụp chân dung',

N'3349 mAh',
N'Sạc nhanh 20W, MagSafe, sạc không dây Qi',
N'USB-C (USB 2)',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.3',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'171g',
N'147.6 x 71.6 x 7.8 mm',
N'IP68 (kháng nước và bụi)',

N'Cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Hỗ trợ 5G, Dynamic Island, Face ID, chụp ảnh tốt, kết nối USB-C'
),

(
N'iPhone 15 Plus',
N'phone',
N'Apple',

'2023-09-22',
'2023-09-22',

0,
0,

N'iOS 17 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A16 Bionic',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 5 nhân',
N'6GB',

N'6.7 inch',
N'2796 x 1290 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'Dynamic Island, HDR10, Dolby Vision, True Tone, độ sáng cao',

N'48MP (wide) + 12MP (ultra-wide), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/1.9',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, Cinematic Mode',
N'Photonic Engine, Smart HDR, Deep Fusion, Night Mode, chụp chân dung',

N'4383 mAh',
N'Sạc nhanh 20W, MagSafe, sạc không dây Qi',
N'USB-C (USB 2)',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.3',
1,
N'1 Nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'201g',
N'160.9 x 77.8 x 7.8 mm',
N'IP68 (kháng nước và bụi)',

N'Cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Hỗ trợ 5G, Dynamic Island, Face ID, pin lớn, chụp ảnh tốt, kết nối USB-C'
),

(
N'iPhone 15 Pro',
N'phone',
N'Apple',

'2023-09-22',
'2023-09-22',

0,
0,

N'iOS 17 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A17 Pro',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 6 nhân',
N'8GB',

N'6.1 inch',
N'2556 x 1179 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, Always-on Display, HDR10, Dolby Vision, True Tone, độ sáng cao',

N'48MP (wide) + 12MP (ultra-wide) + 12MP (telephoto), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/1.9',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, ProRes, Cinematic Mode',
N'Zoom quang học 3x, Smart HDR, Deep Fusion, Night Mode, chụp chân dung, ProRAW',

N'3274 mAh',
N'Sạc nhanh 27W, MagSafe, sạc không dây Qi',
N'USB-C (USB 3)',

N'5G',
N'Wi-Fi 6E (802.11ax)',
N'Bluetooth 5.3',
1,
N'eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính nhám cao cấp',
N'Khung Titan',
N'187g',
N'146.6 x 70.6 x 8.25 mm',
N'IP68 (kháng nước và bụi)',

N'Cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế',
N'Hỗ trợ 5G, sạc không dây, Face ID, kháng nước kháng bụi, quay video chuyên nghiệp, hiệu năng cao từ chip A17 Pro'
),

(
N'iPhone 15 Pro Max',
N'phone',
N'Apple',

'2023-09-22',
'2023-09-22',

0,
0,

N'iOS 17 (có thể nâng cấp lên iOS mới nhất)',
N'Apple A17 Pro',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 6 nhân',
N'8GB',

N'6.7 inch',
N'2796 x 1290 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, Always-on Display, HDR10, Dolby Vision, True Tone, độ sáng cao',

N'48MP (wide) + 12MP (ultra-wide) + 12MP (telephoto), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/1.9',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, ProRes, Cinematic Mode',
N'Zoom quang học 5x, Smart HDR, Deep Fusion, Night Mode, chụp chân dung, ProRAW',

N'4422 mAh',
N'Sạc nhanh 27W, MagSafe, sạc không dây Qi',
N'USB-C (USB 3)',

N'5G',
N'Wi-Fi 6E (802.11ax)',
N'Bluetooth 5.3',
1,
N'eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính nhám cao cấp',
N'Khung Titan',
N'221g',
N'159.9 x 76.7 x 8.25 mm',
N'IP68 (kháng nước và bụi)',

N'Cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế',
N'Hỗ trợ 5G, sạc không dây, Face ID, kháng nước kháng bụi, quay video chuyên nghiệp, hiệu năng cao từ chip A17 Pro'
),

(
N'iPhone 16',
N'phone',
N'Apple',

'2024-09-20',
'2024-09-20',

0,
0,

N'iOS 18',
N'Apple A18',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 5 nhân',
N'8GB',

N'6.1 inch',
N'2556 x 1179 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'HDR10, Dolby Vision, True Tone, độ sáng cao',

N'48MP (wide) + 12MP (ultra-wide), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/1.9',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR',
N'Smart HDR, Deep Fusion, Night Mode, chụp chân dung',

N'3561 mAh',
N'Sạc nhanh 30W, MagSafe, sạc không dây Qi',
N'USB-C',

N'5G',
N'Wi-Fi 7 (802.11be)',
N'Bluetooth 5.3',
1,
N'eSIM',
N'GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'170g',
N'147.6 x 71.6 x 7.8 mm',
N'IP68 (kháng nước và bụi)',

N'Cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Hiệu năng ổn định, camera nâng cấp, hỗ trợ Face ID và sạc không dây'
),

(
N'iPhone 16e',
N'phone',
N'Apple',

'2024-09-20',
'2024-09-20',

0,
0,

N'iOS 18',
N'Apple A18',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 4 nhân',
N'8GB',

N'6.1 inch',
N'2556 x 1179 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'HDR10, True Tone, độ sáng cao, hiển thị màu sắc chính xác',

N'Camera 48MP (wide), hỗ trợ chống rung điện tử',
N'Camera trước 12MP, khẩu độ f/1.9',
N'Quay video 4K@24/30/60fps',
N'Smart HDR, Deep Fusion, Night Mode, chụp chân dung',

N'3300 mAh',
N'Sạc nhanh 25W, MagSafe, sạc không dây Qi',
N'USB-C',

N'5G',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.3',
1,
N'eSIM',
N'GPS, GLONASS, Galileo',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'175g',
N'147 x 72 x 7.8 mm',
N'IP68 (kháng nước và bụi)',

N'Cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, con quay hồi chuyển',
N'Hiệu năng ổn định, tiết kiệm pin, hỗ trợ Face ID, phù hợp người dùng phổ thông'
),

(
N'iPhone 16 Plus',
N'phone',
N'Apple',

'2024-09-20',
'2024-09-20',

0,
0,

N'iOS 18',
N'Apple A18',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 5 nhân',
N'8GB',

N'6.7 inch',
N'2796 x 1290 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'HDR10, Dolby Vision, True Tone, độ sáng cao',

N'48MP (wide) + 12MP (ultra-wide), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/1.9',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR',
N'Smart HDR, Deep Fusion, Night Mode, chụp chân dung',

N'4674 mAh',
N'Sạc nhanh 30W, MagSafe, sạc không dây Qi',
N'USB-C',

N'5G',
N'Wi-Fi 7 (802.11be)',
N'Bluetooth 5.3',
1,
N'eSIM',
N'GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'199g',
N'160.9 x 77.8 x 7.8 mm',
N'IP68 (kháng nước và bụi)',

N'Cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển',
N'Màn hình lớn, pin dung lượng cao, hỗ trợ sạc không dây, Face ID'
),

(
N'iPhone 16 Pro',
N'phone',
N'Apple',

'2024-09-20',
'2024-09-20',

0,
0,

N'iOS 18',
N'Apple A18 Pro',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 6 nhân',
N'8GB',

N'6.3 inch',
N'2622 x 1206 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, Always-on Display, HDR10, Dolby Vision, True Tone, độ sáng cao',

N'48MP (wide) + 48MP (ultra-wide) + 12MP (telephoto), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.0',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, ProRes',
N'Zoom quang học 5x, Smart HDR, Deep Fusion, Night Mode, chụp chân dung, ProRAW',

N'3582 mAh',
N'Sạc nhanh 30W, MagSafe, sạc không dây Qi, sạc ngược không dây',
N'USB-C',

N'5G',
N'Wi-Fi 7 (802.11be)',
N'Bluetooth 5.3',
1,
N'eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính nhám cao cấp',
N'Khung Titan',
N'199g',
N'149.6 x 71.5 x 8.25 mm',
N'IP68 (kháng nước và bụi)',

N'Cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế, cảm biến trọng lực',
N'Hỗ trợ 5G, sạc không dây, Face ID, kháng nước kháng bụi, quay video chuyên nghiệp, xử lý AI thông minh'
),

(
N'iPhone 16 Pro Max',
N'phone',
N'Apple',

'2024-09-20',
'2024-09-20',

0,
0,

N'iOS 18',
N'Apple A18 Pro',
N'Hexa-core (2 nhân hiệu năng + 4 nhân tiết kiệm điện)',
N'Apple GPU 6 nhân',
N'8GB',

N'6.9 inch',
N'2868 x 1320 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, Always-on Display, HDR10, Dolby Vision, độ sáng cao, True Tone',

N'48MP (wide) + 48MP (ultra-wide) + 12MP (telephoto), chống rung quang học OIS',
N'Camera trước 12MP, khẩu độ f/2.0',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR, ProRes',
N'Zoom quang học 5x, Smart HDR, Deep Fusion, Night Mode, chụp chân dung, ProRAW',

N'4685 mAh',
N'Sạc nhanh 30W, MagSafe, sạc không dây Qi, sạc ngược không dây',
N'USB-C',

N'5G',
N'Wi-Fi 7 (802.11be)',
N'Bluetooth 5.3',
1,
N'eSIM',
N'GPS, GLONASS, Galileo, QZSS, BeiDou',

N'Không hỗ trợ',

N'Mặt lưng kính nhám cao cấp',
N'Khung Titan',
N'227g',
N'163.0 x 77.6 x 8.25 mm',
N'IP68 (kháng nước và bụi)',

N'Cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển, cảm biến áp kế, cảm biến trọng lực',
N'Hỗ trợ 5G, sạc không dây, Face ID, kháng nước kháng bụi, quay video chuyên nghiệp, xử lý AI thông minh'
),

(
N'iPhone 17',
N'phone',
N'Apple',

'2025-09-19',
'2025-09-19',

0,
0,

N'iOS 19',
N'Apple A19',
N'Hexa-core (2 hiệu năng + 4 tiết kiệm)',
N'Apple GPU 5 nhân',
N'8GB',

N'6.3 inch',
N'2622 x 1206 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, HDR10, Dolby Vision, độ sáng cao',

N'Camera kép 48MP (wide) + 48MP (ultra-wide), chống rung OIS',
N'Camera trước 24MP, khẩu độ f/1.9',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR',
N'Smart HDR, Deep Fusion, Night Mode, chụp chân dung',

N'4000 mAh',
N'Sạc nhanh 30W, MagSafe, sạc không dây Qi',
N'USB-C',

N'5G',
N'Wi-Fi 7 (802.11be)',
N'Bluetooth 5.3',
1,
N'eSIM',
N'GPS, GLONASS, Galileo',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'177g',
N'149.6 x 71.5 x 8 mm',
N'IP68',

N'Face ID, gia tốc, con quay hồi chuyển',
N'Hiệu năng cao, tiết kiệm pin, hỗ trợ AI'
),

(
N'iPhone 17 Pro',
N'phone',
N'Apple',

'2026-04-28',
'2026-04-28',

0,
0,

N'iOS 26',
N'Apple A19 Pro',
N'Hexa-core (2 hiệu năng + 4 tiết kiệm)',
N'Apple GPU 6 nhân',
N'8GB',

N'6.3 inch',
N'2622 x 1206 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, Always-on Display, HDR10, Dolby Vision',

N'Camera 48MP (wide) + 12MP (ultra-wide) + 12MP (telephoto), OIS',
N'Camera trước 12MP, khẩu độ f/2.0',
N'Quay video 4K@24/30/60fps, ProRes, Dolby Vision',
N'Zoom quang học, Night Mode, Deep Fusion, ProRAW',

N'3300–3500 mAh',
N'Sạc nhanh 35W, MagSafe, sạc không dây',
N'USB-C',

N'5G',
N'Wi-Fi 7 (802.11be)',
N'Bluetooth 6',
1,
N'eSIM',
N'GPS, GLONASS, Galileo',

N'Không hỗ trợ',

N'Mặt lưng kính nhám',
N'Khung nhôm cao cấp',
N'204g',
N'147 x 71 x 7.8 mm',
N'IP68',

N'Face ID, cảm biến đầy đủ',
N'Camera chuyên nghiệp, quay video cao cấp'
),

(
N'iPhone 17 Pro Max',
N'phone',
N'Apple',

'2026-04-28',
'2026-04-28',

0,
0,

N'iOS 26',
N'Apple A19 Pro',
N'Hexa-core (2 hiệu năng + 4 tiết kiệm)',
N'Apple GPU 6 nhân',
N'8GB',

N'6.9 inch',
N'2868 x 1320 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, Always-on Display, HDR10, Dolby Vision, độ sáng cao ~2500 nits',

N'Camera 48MP (wide) + 48MP (ultra-wide) + 48MP (telephoto), chống rung quang học OIS',
N'Camera trước 18MP, khẩu độ f/2.0',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR',
N'Zoom quang học 5x, Smart HDR, Deep Fusion, chụp đêm Night Mode, ProRAW',

N'4800 mAh',
N'Sạc nhanh 40W, MagSafe, sạc không dây Qi',
N'USB-C',

N'5G',
N'Wi-Fi 7 (802.11be)',
N'Bluetooth 6',
1,
N'eSIM',
N'GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính nhám',
N'Khung Titan',
N'231g',
N'163.4 x 78 x 8.75 mm',
N'IP68',

N'Face ID, gia tốc, con quay hồi chuyển, cảm biến ánh sáng, tiệm cận',
N'Hiệu năng cao cấp, camera chuyên nghiệp, pin lớn'
),

(
N'iPhone 17e',
N'phone',
N'Apple',

'2026-03-01',
'2026-03-01',

0,
0,

N'iOS 19 - cập nhật mới nhất',
N'Apple A19',
N'Hexa-core (2 hiệu năng + 4 tiết kiệm)',
N'Apple GPU 5 nhân',
N'8GB',

N'6.1 inch',
N'2556 x 1179 pixels',
N'Super Retina XDR OLED',
N'60Hz',
N'HDR10, Dolby Vision, độ sáng cao ~2000 nits, True Tone',

N'Camera 48MP (wide), khẩu độ f/1.8, hỗ trợ chống rung điện tử',
N'Camera trước 12MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps',
N'Smart HDR, Deep Fusion, AI tối ưu ảnh, chụp đêm Night Mode',

N'3500 mAh',
N'Sạc nhanh 25W, MagSafe, sạc không dây Qi',
N'USB-C',

N'5G',
N'Wi-Fi 6E (802.11ax)',
N'Bluetooth 5.3',
1,
N'eSIM',
N'GPS, GLONASS, Galileo',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'170g',
N'147 x 72 x 8 mm',
N'IP68',

N'Face ID, gia tốc, con quay hồi chuyển, cảm biến ánh sáng, tiệm cận',
N'Giá tốt, hiệu năng mạnh, thiết kế gọn nhẹ'
),

(
N'iPhone 17 Air',
N'phone',
N'Apple',

'2025-09-19',
'2025-09-19',

0,
0,

N'iOS 19 - cập nhật mới nhất',
N'Apple A19',
N'Hexa-core (2 hiệu năng + 4 tiết kiệm)',
N'Apple GPU 6 nhân',
N'8GB',

N'6.5 inch',
N'2688 x 1242 pixels',
N'Super Retina XDR OLED',
N'120Hz',
N'ProMotion, Always-on Display, HDR10, Dolby Vision, độ sáng cao ~2000 nits',

N'Camera 48MP (wide), khẩu độ f/1.6, chống rung quang học OIS',
N'Camera trước 18MP, khẩu độ f/2.0',
N'Quay video 4K@24/30/60fps, Dolby Vision HDR',
N'Night Mode, Smart HDR, Deep Fusion, AI xử lý hình ảnh',

N'3200 mAh',
N'Sạc nhanh 25W, MagSafe, sạc không dây Qi',
N'USB-C',

N'5G',
N'Wi-Fi 7 (802.11be)',
N'Bluetooth 5.3',
1,
N'eSIM',
N'GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung Titan',
N'165g',
N'156.2 x 74.7 x 5.6 mm',
N'IP68',

N'Face ID, gia tốc, con quay hồi chuyển, cảm biến tiệm cận, cảm biến ánh sáng',
N'Thiết kế siêu mỏng, nhẹ, hiệu năng cao, tiết kiệm pin'
),

(
N'iPhone SE (2020)',
N'phone',
N'Apple',

'2020-04-24',
'2020-04-24',

0,
0,

N'iOS 13 - cập nhật mới nhất',
N'Apple A13 Bionic',
N'Hexa-core (2 nhân Lightning + 4 nhân Thunder)',
N'Apple GPU 4 nhân',
N'3GB',

N'4.7 inch',
N'1334 x 750 pixels',
N'Retina IPS LCD',
N'60Hz',
N'326 ppi, True Tone, độ sáng 625 nits, dải màu rộng (P3)',

N'Camera 12MP (wide), khẩu độ f/1.8',
N'Camera trước 7MP, khẩu độ f/2.2',
N'Quay video 4K@24/30/60fps, FullHD 1080p@30/60/120fps',
N'HDR, Smart HDR, chống rung quang học OIS, nhận diện khuôn mặt',

N'1821 mAh',
N'Sạc nhanh 18W, sạc không dây Qi',
N'Lightning',

N'4G LTE',
N'Wi-Fi 6 (802.11ax)',
N'Bluetooth 5.0',
1,
N'1 nano-SIM + eSIM',
N'GPS, GLONASS, Galileo, QZSS',

N'Không hỗ trợ',

N'Mặt lưng kính',
N'Khung nhôm',
N'148g',
N'138.4 x 67.3 x 7.3 mm',
N'IP67',

N'Cảm biến vân tay (Touch ID), gia tốc, con quay hồi chuyển, cảm biến tiệm cận',
N'Kháng nước, sạc không dây, hiệu năng mạnh trong thân máy nhỏ gọn'
);




--Tạo màu cho máy


INSERT INTO product_colors_phone (product_id, color_name)
VALUES
(1, N'Bạc'),
(1, N'Đen'),
(1, N'Vàng đồng'),
(1, N'Vàng hồng');


INSERT INTO product_images_phone (
    product_id,
    color_id,
    image_url,
    display_order,
    is_primary
)
VALUES

-- ================= BẠC (color_id = 1) =================
(1,1,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-silver-750x500.png',1,1),
(1,1,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-bac-1-11-750x500.jpg',2,0),
(1,1,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-bac-2-3-750x500.jpg',3,0),
(1,1,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-bac-3-2-750x500.jpg',4,0),
(1,1,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-bac-4-2-750x500.jpg',5,0),
(1,1,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-bac-5-2-750x500.jpg',6,0),
(1,1,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-bac-6-1-750x500.jpg',7,0),
(1,1,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-bac-7-1-750x500.jpg',8,0),
(1,1,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-bac-8-1-750x500.jpg',9,0),

-- ================= ĐEN (color_id = 2) =================
(1,2,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den-750x500.png',1,1),
(1,2,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den-1-2-750x500.jpg',2,0),
(1,2,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den1-2-750x500.jpg',3,0),
(1,2,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den1-3-750x500.jpg',4,0),
(1,2,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den1-4-750x500.jpg',5,0),
(1,2,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den1-5-750x500.jpg',6,0),
(1,2,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den1-6-750x500.jpg',7,0),
(1,2,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den1-7-750x500.jpg',8,0),
(1,2,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den1-8-750x500.jpg',9,0),

-- ================= VÀNG ĐỒNG (color_id = 3) =================
(1,3,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-400x400-1-600x600.jpg',1,1),
(1,3,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vangdong-1-5-750x500.jpg',2,0),
(1,3,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vangdong1-2-750x500.jpg',3,0),
(1,3,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vangdong1-3-750x500.jpg',4,0),
(1,3,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vangdong1-4-750x500.jpg',5,0),
(1,3,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vangdong1-5-750x500.jpg',6,0),
(1,3,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vangdong1-6-750x500.jpg',7,0),
(1,3,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vangdong1-7-750x500.jpg',8,0),
(1,3,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vangdong1-8-750x500.jpg',9,0),

-- ================= VÀNG HỒNG (color_id = 4) =================
(1,4,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-hong-750x500.png',1,1),
(1,4,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vanghong-1-2-750x500.jpg',2,0),
(1,4,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vanghong1-2-750x500.jpg',3,0),
(1,4,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vanghong1-3-750x500.jpg',4,0),
(1,4,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vanghong1-4-750x500.jpg',5,0),
(1,4,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vanghong1-5-750x500.jpg',6,0),
(1,4,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vanghong1-6-750x500.jpg',7,0),
(1,4,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vanghong1-7-750x500.jpg',8,0),
(1,4,N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-vanghong1-8-750x500.jpg',9,0);



INSERT INTO product_variants_phone (
    product_id,
    color_id,
    storage,
    price,
    old_price,
    stock,
    image_main
)
VALUES

-- ===== BẠC =====
(1,1,N'32GB', 3500000, 4000000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-silver-750x500.png'),
(1,1,N'128GB',4000000, 4500000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-silver-750x500.png'),
(1,1,N'256GB',4500000, 5000000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-silver-750x500.png'),

-- ===== ĐEN =====
(1,2,N'32GB', 3500000, 4000000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den-750x500.png'),
(1,2,N'128GB',4000000, 4500000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den-750x500.png'),
(1,2,N'256GB',4500000, 5000000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-den-750x500.png'),

-- ===== VÀNG =====
(1,3,N'32GB', 3500000, 4000000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-400x400-1-600x600.jpg'),
(1,3,N'128GB',4000000, 4500000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-400x400-1-600x600.jpg'),
(1,3,N'256GB',4500000, 5000000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-400x400-1-600x600.jpg'),

-- ===== VÀNG HỒNG =====
(1,4,N'32GB', 3500000, 4000000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-hong-750x500.png'),
(1,4,N'128GB',4000000, 4500000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-hong-750x500.png'),
(1,4,N'256GB',4500000, 5000000, 10, N'https://cdn.tgdd.vn/Products/Images/42/87838/iphone-7-256gb-hong-750x500.png');




DROP TABLE product_variants_phone;
DROP TABLE product_images_phone;
DROP TABLE product_colors_phone;
DROP TABLE products_phone;
DROP TABLE product_reviews