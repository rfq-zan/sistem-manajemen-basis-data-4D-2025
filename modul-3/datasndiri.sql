CREATE DATABASE db_invenap;

USE db_invenap;

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

INSERT INTO kategori_obat (nama_kategori, deskripsi) VALUES
('Antibiotik', 'Obat melawan infeksi bakteri'),
('Analgesik', 'Obat pereda nyeri'),
('Antiseptik', 'Obat membunuh kuman pada luka'),
('Vitamin', 'Suplemen kesehatan tubuh');

INSERT INTO pabrik (nama_pabrik, kontak, telepon, email, alamat) VALUES
('Sanbe Farma', 'CS Sanbe', '523-6544', 'info@sanbe.com', 'Jakarta Selatan'),
('Kalbe Farma', 'CS Kalbe', '441-9875', 'kontak@kalbe.com', 'Surabaya'),
('Dexa Medica', 'CS Dexa', '667-9351', 'cs@dexa.com', 'Lamongan'),
('Kimia Farma', 'CS Kimfar', '621-9854', 'support@kimiafarma.com', 'Sumenep');

INSERT INTO obat (nama_obat, id_kategori, id_pabrik, stok, harga_satuan, tanggal_kadaluarsa, min_pesanan) VALUES
('Amoxicillin', 1, 1, 50, 15000, '2026-12-31', 10),
('Paracetamol', 2, 2, 100, 5000, '2025-10-15', 20),
('Betadine', 3, 3, 75, 20000, '2027-05-20', 15),
('Vitamin C', 4, 4, 200, 10000, '2026-08-10', 30),
('Cefadroxil', 1, 1, 40, 17000, '2026-11-30', 10),
('Ibuprofen', 2, 2, 90, 8000, '2025-09-10', 20),
('Dettol', 3, 3, 60, 25000, '2027-06-15', 15),
('Vitamin D', 4, 4, 150, 12000, '2026-07-22', 30),
('Erythromycin', 1, 1, 30, 22000, '2026-10-05', 10),
('Aspirin', 2, 2, 80, 7000, '2025-12-01', 20),
('Rivanol', 3, 3, 50, 18000, '2027-03-18', 15),
('Vitamin B12', 4, 4, 175, 14000, '2026-09-25', 30);

INSERT INTO pelanggan (nama_pelanggan, telepon, email, member, diskon_member) VALUES
('Andi Pratama', '081212341234', 'andi@email.com', 'Reguler', 0.00),
('Siti Aminah', '081312345678', 'siti@email.com', 'Premium', 5.00),
('Budi Santoso', '081456789012', 'budi@email.com', 'VIP', 10.00),
('Dewi Kartika', '081567890123', 'dewi@email.com', 'Reguler', 0.00);

INSERT INTO transaksi_penjualan (id_pelanggan, total_harga, diskon, tanggal_transaksi) VALUES
(1, 30000, 0.00, '2025-03-25 10:30:00'),
(2, 50000, 2.50, '2025-03-25 11:00:00'),
(3, 100000, 10.00, '2025-03-25 12:00:00'),
(4, 25000, 0.00, '2025-03-25 13:15:00');

INSERT INTO detail_penjualan (id_transaksi, id_obat, jumlah, harga_total) VALUES
(1, 1, 2, 30000),
(2, 2, 10, 50000),
(3, 3, 5, 100000),
(4, 4, 2, 25000);


SELECT * FROM pabrik;

-- datamaster
DELIMITER //
CREATE PROCEDURE UpdateDataMaster(
    IN p_id INT,
    IN p_nama_baru VARCHAR(100),
    OUT p_status VARCHAR(50)
)
BEGIN
    UPDATE pabrik SET nama_pabrik = p_nama_baru WHERE id_pabrik = p_id;
    IF ROW_COUNT() > 0 THEN
        SET p_status = 'Update Berhasil';
    ELSE
        SET p_status = 'ID Tidak Ditemukan';
    END IF;
END //
DELIMITER ;
SET @status = 'pabik anyar';
CALL UpdateDataMaster(1, 'pabrik anyar', @status);
SELECT @status;

DROP PROCEDURE UpdateDataMaster;

-- count
DELIMITER //
CREATE PROCEDURE CountTransaksi(OUT jumlah INT)
BEGIN
    SELECT COUNT(*) INTO jumlah FROM transaksi_penjualan;
END //
DELIMITER ;
CALL CountTransaksi(@jumlah);
SELECT @jumlah;

DROP PROCEDURE CountTransaksi;

-- getmaster
DELIMITER //
CREATE PROCEDURE GetDataMasterByID(
    IN p_id INT,
    OUT p_nama VARCHAR(100),
    OUT p_email VARCHAR(100)
)
BEGIN
    SELECT nama_pabrik, email
    INTO p_nama, p_email
    FROM pabrik
    WHERE id_pabrik = p_id;
END //
DELIMITER ;
SET @nama = 'Dexa Medica', @email = 'cs@dexa.com';
CALL GetDataMasterByID(3, @nama, @email);
SELECT @nama, @email;

DROP PROCEDURE GetDataMasterByID;

-- apdettrans
DELIMITER //
CREATE PROCEDURE UpdateFieldTransaksi(
    IN p_id INT,
    INOUT field1 DECIMAL(10,2),
    INOUT field2 DECIMAL(10,2)
)
BEGIN
    DECLARE f1 DECIMAL(10,2);
    DECLARE f2 DECIMAL(10,2);
    SELECT total_harga, diskon INTO f1, f2 FROM transaksi_penjualan WHERE id_transaksi = p_id;
    IF field1 IS NULL THEN SET field1 = f1; END IF;
    IF field2 IS NULL THEN SET field2 = f2; END IF;
    UPDATE transaksi_penjualan
    SET total_harga = field1, diskon = field2
    WHERE id_transaksi = p_id;
END //
DELIMITER ;
SET @total_harga = 40000;
SET @diskon = NULL;
CALL UpdateFieldTransaksi(3, @total_harga, @diskon);
SELECT total_harga, diskon FROM transaksi_penjualan WHERE id_transaksi = 1;

DROP PROCEDURE UpdateFieldTransaksi;

--  delet entry
DELIMITER //
CREATE PROCEDURE DeleteEntriesByIDMaster(IN p_id INT)
BEGIN
    DELETE FROM pabrik WHERE id_pabrik = p_id;
END //
DELIMITER ;
CALL DeleteEntriesByIDMaster(4);
SELECT * FROM pabrik;

DROP PROCEDURE DeleteEntriesBYIDMaster;


-- tugas baru

-- tampilan data
DELIMITER //
CREATE PROCEDURE tampilkan_transaksi(IN hari INT)
BEGIN
    SELECT * FROM transaksi_penjualan
    WHERE tanggal_transaksi >= DATE_SUB(CURDATE(), INTERVAL hari DAY);
END //
DELIMITER ;

-- delet trans 1
DELIMITER //
CREATE PROCEDURE hapus_transaksi()
BEGIN
    DELETE FROM transaksi_penjualan
    WHERE tanggal_transaksi < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    AND id_transaksi NOT IN (
        SELECT id_transaksi FROM detail_penjualan
        WHERE STATUS IN ('belum lunas', 'belum dikembalikan', 'belum dibayar')
    );
END //
DELIMITER ;


-- min 7 trans
DELIMITER //
CREATE PROCEDURE ubah_status_7minimal(IN status_baru VARCHAR(50))
BEGIN
    UPDATE transaksi_penjualan
    SET STATUS = status_baru
    WHERE id_transaksi IN (
        SELECT id_transaksi FROM (
            SELECT id_transaksi
            FROM detail_penjualan
            GROUP BY id_transaksi
            HAVING COUNT(*) >= 7
        ) AS temp);
END //
DELIMITER ;


-- no edit user
DELIMITER //
CREATE PROCEDURE update_user(
    IN id INT,
    IN nama_baru VARCHAR(100),
    IN email_baru VARCHAR(100)
)
BEGIN
    -- Cegah update jika user punya transaksi
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

-- update status 1 bulan branch
DELIMITER //
CREATE PROCEDURE update_status_transaksi()
BEGIN
    DECLARE min_id INT;
    DECLARE max_id INT;
    DECLARE mid_id INT;
    SELECT id_transaksi INTO min_id FROM detail_penjualan
    WHERE tanggal_transaksi >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    ORDER BY jumlah ASC LIMIT 1;
    SELECT id_transaksi INTO mid_id FROM detail_penjualan
    WHERE tanggal_transaksi >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    ORDER BY jumlah DESC LIMIT 1;
    SELECT id_transaksi INTO max_id FROM detail_penjualan
    WHERE tanggal_transaksi >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    ORDER BY harga_total DESC LIMIT 1;
    UPDATE transaksi_penjualan SET STATUS = 'non-aktif' WHERE id_transaksi = min_id;
    UPDATE transaksi_penjualan SET STATUS = 'pasif' WHERE id_transaksi = mid_id;
    UPDATE transaksi_penjualan SET STATUS = 'aktif' WHERE id_transaksi = max_id;
END //
DELIMITER ;

-- jumlah trans 1 bulan
DELIMITER //
CREATE PROCEDURE transaksi_berhasil()
BEGIN
    DECLARE total INT DEFAULT 0;
    DECLARE i INT DEFAULT 1;
    SELECT COUNT(*) INTO total
    FROM transaksi_penjualan
    WHERE tanggal_transaksi >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND STATUS = 'berhasil';
    WHILE i <= total DO
        SELECT CONCAT('Transaksi berhasil ke-', i) AS info;
        SET i = i + 1;
    END WHILE;
    SELECT total AS jumlah_transaksi_berhasil;
END //
DELIMITER ;




