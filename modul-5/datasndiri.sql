CREATE DATABASE db_invenap2;

USE db_invenap2;

CREATE TABLE pabrik (
    id_pabrik INT PRIMARY KEY AUTO_INCREMENT,
    nama_pabrik VARCHAR(100) NOT NULL,
    kontak VARCHAR(100),
    telepon VARCHAR(12),
    email VARCHAR(100) UNIQUE,
    alamat TEXT
);

CREATE TABLE kategori_obat (
    id_kategori INT PRIMARY KEY AUTO_INCREMENT,
    nama_kategori VARCHAR(100) NOT NULL,
    deskripsi TEXT
);

CREATE TABLE obat (
    id_obat INT PRIMARY KEY AUTO_INCREMENT,
    nama_obat VARCHAR(100) NOT NULL,
    id_kategori INT,
    id_pabrik INT,
    stok INT NOT NULL DEFAULT 0,
    harga_satuan DECIMAL(10,2) NOT NULL,
    tanggal_kadaluarsa DATE NOT NULL,
    min_pesanan INT NOT NULL,
    FOREIGN KEY (id_kategori) REFERENCES kategori_obat(id_kategori) ON DELETE SET NULL,
    FOREIGN KEY (id_pabrik) REFERENCES pabrik(id_pabrik) ON DELETE SET NULL
);

CREATE TABLE pelanggan (
    id_pelanggan INT PRIMARY KEY AUTO_INCREMENT,
    nama_pelanggan VARCHAR(100) NOT NULL,
    telepon VARCHAR(20),
    email VARCHAR(100),
    member ENUM('Reguler', 'Premium', 'VIP') NOT NULL DEFAULT 'Reguler',
    diskon_member DECIMAL(5,2) NOT NULL DEFAULT 0.00
);

CREATE TABLE transaksi_penjualan (
    id_transaksi INT PRIMARY KEY AUTO_INCREMENT,
    id_pelanggan INT,
    total_harga DECIMAL(10,2) NOT NULL,
    diskon DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    tanggal_transaksi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pelanggan) REFERENCES pelanggan(id_pelanggan) ON DELETE SET NULL
);

CREATE TABLE detail_penjualan (
    id_detail INT PRIMARY KEY AUTO_INCREMENT,
    id_transaksi INT,
    id_obat INT,
    jumlah INT NOT NULL CHECK (jumlah > 0),
    harga_total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_transaksi) REFERENCES transaksi_penjualan(id_transaksi) ON DELETE CASCADE,
    FOREIGN KEY (id_obat) REFERENCES obat(id_obat) ON DELETE SET NULL
);
-- Pabrik
INSERT INTO pabrik (nama_pabrik, kontak, telepon, email, alamat) VALUES
('Pabrik Sehat', 'Andi', '081234567890', 'sehat@pabrik.com', 'Jl. Kesehatan No. 1'),
('Pabrik Prima', 'Budi', '089876543210', 'prima@pabrik.com', 'Jl. Kebugaran No. 2'),
('Pabrik Jaya', 'Citra', '081212121212', 'jaya@pabrik.com', 'Jl. Industri No. 3'),
('Pabrik Makmur', 'Dedi', '082222222222', 'makmur@pabrik.com', 'Jl. Produksi No. 4'),
('Pabrik Hebat', 'Eka', '083333333333', 'hebat@pabrik.com', 'Jl. Ekspor No. 5');

-- Kategori Obat
INSERT INTO kategori_obat (nama_kategori, deskripsi) VALUES
('Antibiotik', 'Obat untuk infeksi bakteri'),
('Vitamin', 'Suplemen untuk kesehatan'),
('Analgesik', 'Obat pereda nyeri'),
('Antiseptik', 'Obat untuk membunuh kuman'),
('Antasida', 'Obat untuk lambung');

-- Obat
INSERT INTO obat (nama_obat, id_kategori, id_pabrik, stok, harga_satuan, tanggal_kadaluarsa, min_pesanan) VALUES
('Amoxicillin', 1, 1, 100, 5000.00, '2025-12-31', 10),
('Vitamin C', 2, 2, 200, 3000.00, '2025-11-30', 5),
('Paracetamol', 3, 3, 150, 2500.00, '2026-01-15', 10),
('Betadine', 4, 4, 120, 8000.00, '2026-02-28', 2),
('Promag', 5, 5, 180, 4000.00, '2025-10-20', 3);

-- Pelanggan
INSERT INTO pelanggan (nama_pelanggan, telepon, email, member, diskon_member) VALUES
('Alice', '081111111111', 'alice@mail.com', 'Reguler', 0.00),
('Bob', '082222222222', 'bob@mail.com', 'Premium', 5.00),
('Charlie', '083333333333', 'charlie@mail.com', 'VIP', 10.00),
('Diana', '084444444444', 'diana@mail.com', 'Reguler', 0.00),
('Edward', '085555555555', 'edward@mail.com', 'Premium', 5.00);

-- Transaksi Penjualan
INSERT INTO transaksi_penjualan (id_pelanggan, total_harga, diskon, tanggal_transaksi) VALUES
(1, 50000.00, 0.00, '2025-05-06 12:28:11'),   
(2, 75000.00, 3750.00, '2025-04-12 09:15:00'),  
(3, 30000.00, 3000.00, '2025-04-15 14:45:00'),  
(4, 60000.00, 0.00, '2025-04-25 17:30:00'), 
(5, 100000.00, 5000.00, '2025-04-26 11:00:00');  

-- Detail Penjualan
INSERT INTO detail_penjualan (id_transaksi, id_obat, jumlah, harga_total) VALUES
(1, 1, 10, 50000.00),
(2, 2, 25, 75000.00),
(3, 3, 12, 30000.00),
(4, 4, 7, 56000.00),
(5, 5, 25, 100000.00);

ALTER TABLE transaksi_penjualan
ADD COLUMN STATUS VARCHAR(50) DEFAULT 'pending';

DROP DATABASE db_invenap2;
SELECT * FROM pabrik;


-- tampilan data
DELIMITER //
CREATE PROCEDURE tampilkan_transaksi(IN hari INT)
BEGIN
    SELECT * FROM transaksi_penjualan
    WHERE tanggal_transaksi >= DATE_SUB(CURDATE(), INTERVAL hari DAY);
END //
DELIMITER ;
CALL tampilkan_transaksi(30);

-- delet trans 1
DELIMITER //
CREATE PROCEDURE hapus_transaksi()
BEGIN
    DELETE FROM transaksi_penjualan
    WHERE tanggal_transaksi < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    AND id_transaksi NOT IN (
        SELECT DISTINCT id_transaksi FROM detail_penjualan
    );
END //
DELIMITER ;
CALL hapus_transaksi();

-- min 7 trans
DELIMITER //
CREATE PROCEDURE ubah_status_7minimal(IN status_baru VARCHAR(50))
BEGIN
    UPDATE transaksi_penjualan tp
    JOIN detail_penjualan dp ON tp.id_transaksi = dp.id_transaksi
    SET tp.status = status_baru
    WHERE dp.jumlah >= 7;
END //
DELIMITER ;
CALL ubah_status_7minimal('sukses');
SELECT * FROM transaksi_penjualan;


-- no edit user
DELIMITER //
CREATE PROCEDURE update_user(
    IN id INT,
    IN nama_baru VARCHAR(100),
    IN email_baru VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM transaksi_penjualan WHERE id_pelanggan = id
    ) THEN
        UPDATE pelanggan
        SET nama_pelanggan = nama_baru,
            email = email_baru
        WHERE id_pelanggan = id;
    END IF;
END //
DELIMITER ;
CALL update_user(1, 'Zan', 'zan@gmail.com');

-- update status 1 bulan branch
DELIMITER //
CREATE PROCEDURE update_status_transaksi()
BEGIN
    DECLARE min_jumlah INT;
    DECLARE max_jumlah INT;
    DECLARE max_harga_total DECIMAL(10, 2);
    DECLARE min_id INT;
    DECLARE mid_id INT;
    DECLARE max_id INT;
    
    SELECT dp.id_transaksi, dp.jumlah INTO min_id, min_jumlah
    FROM detail_penjualan dp
    JOIN transaksi_penjualan tp ON dp.id_transaksi = tp.id_transaksi
    WHERE tp.tanggal_transaksi >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    ORDER BY dp.jumlah ASC
    LIMIT 1;

    SELECT dp.id_transaksi, dp.jumlah INTO mid_id, max_jumlah
    FROM detail_penjualan dp
    JOIN transaksi_penjualan tp ON dp.id_transaksi = tp.id_transaksi
    WHERE tp.tanggal_transaksi >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    ORDER BY dp.jumlah DESC
    LIMIT 1;

    SELECT dp.id_transaksi, dp.harga_total INTO max_id, max_harga_total
    FROM detail_penjualan dp
    JOIN transaksi_penjualan tp ON dp.id_transaksi = tp.id_transaksi
    WHERE tp.tanggal_transaksi >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    ORDER BY dp.harga_total DESC
    LIMIT 1;

    IF min_id IS NOT NULL THEN
        UPDATE transaksi_penjualan
        SET STATUS = 'non-aktif'
        WHERE id_transaksi = min_id;
    END IF;
    IF mid_id IS NOT NULL THEN
        UPDATE transaksi_penjualan
        SET STATUS = 'pasif'
        WHERE id_transaksi = mid_id;
    END IF;
    IF max_id IS NOT NULL THEN
        UPDATE transaksi_penjualan
        SET STATUS = 'aktif'
        WHERE id_transaksi = max_id;
    END IF;
END //
DELIMITER ;
CALL update_status_transaksi();
SELECT * FROM transaksi_penjualan;

DROP PROCEDURE update_status_transaksi;

-- jumlah trans 1 bulan
DELIMITER //
CREATE PROCEDURE transaksi_berhasil()
BEGIN
    DECLARE total INT DEFAULT 0;
    DECLARE i INT DEFAULT 1;
    SELECT COUNT(*) INTO total
    FROM transaksi_penjualan
    WHERE tanggal_transaksi >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND STATUS = 'sukses';
    WHILE i <= total DO
        SELECT CONCAT('Transaksi berhasil ke-', i) AS infodata;
        SET i = i + 1;
    END WHILE;
    SELECT total AS jumlah_transaksi_berhasil;
END //
DELIMITER ;
CALL transaksi_berhasil();
DROP PROCEDURE transaksi_berhasil;1