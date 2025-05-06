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


-- 1. obat n kategori_obat
CREATE VIEW view_obat_n_kategori AS
SELECT 
o.nama_obat AS "Nama obat",
k.nama_kategori AS "Kategori",
o.stok AS "Stok tersedia",
o.harga_satuan AS "Harga satuan"
FROM obat o
JOIN kategori_obat k ON o.id_kategori = k.id_kategori;

-- 2. detail_penjualan, obat, n transaksi_penjualan
CREATE VIEW view_detail_transaksi_lengkap AS
SELECT 
tp.id_transaksi AS "ID transaksi",
o.nama_obat AS "Nama obat",
dp.jumlah AS "Jumlah",
dp.harga_total AS "Harga total",
tp.tanggal_transaksi AS "Tanggal transaksi"
FROM detail_penjualan dp
JOIN obat o ON dp.id_obat = o.id_obat
JOIN transaksi_penjualan tp ON dp.id_transaksi = tp.id_transaksi;

-- 3. obat stok<50
CREATE VIEW view_obat_stok_low AS
SELECT 
o.nama_obat AS "Nama obat",
o.stok AS "Stok",
k.nama_kategori AS "Kategori"
FROM obat o
JOIN kategori_obat k ON o.id_kategori = k.id_kategori
WHERE o.stok < 50;

-- 4. Agregasi penjualan
CREATE VIEW view_total_penjualan_per_pelanggan AS
SELECT 
p.nama_pelanggan AS "Nama pelanggan",
COUNT(tp.id_transaksi) AS "Jumlah transaksi",
SUM(tp.total_harga) AS "Total belanja"
FROM pelanggan p
JOIN transaksi_penjualan tp ON p.id_pelanggan = tp.id_pelanggan
GROUP BY p.id_pelanggan;

-- 5.1 Custom view pabrik n obat
CREATE VIEW view_obat_dan_pabrik AS
SELECT 
o.nama_obat AS `Nama obat`,
p.nama_pabrik AS `Nama pabrik`,
o.stok AS `Stok tersedia`,
o.harga_satuan AS `Harga satuan`
FROM obat o
JOIN pabrik p ON o.id_pabrik = p.id_pabrik;

-- 5.2 Custom view kadaluarsa
CREATE VIEW view_obat_hampir_exp AS
SELECT 
nama_obat AS "Nama obat",
tanggal_kadaluarsa AS "Tanggal kadaluarsa",
stok AS "Stok"
FROM obat
WHERE tanggal_kadaluarsa <= DATE_ADD(CURDATE(), INTERVAL 6 MONTH); -- CURDATE (Current Date)


-- 5.3 Custom view coba inner
CREATE VIEW view_penjualan_obat AS
SELECT 
tp.id_transaksi,
p.nama_pelanggan,
p.member,
p.diskon_member,
o.nama_obat,
ko.nama_kategori,
dp.jumlah,
dp.harga_total,
o.stok,
(o.stok - dp.jumlah) AS stok_tersisa,
tp.total_harga - tp.diskon AS total_setelah_diskon,
tp.tanggal_transaksi
FROM transaksi_penjualan tp
INNER JOIN pelanggan p ON tp.id_pelanggan = p.id_pelanggan -- tabel digabung tpi klo valid ae 
INNER JOIN detail_penjualan dp ON tp.id_transaksi = dp.id_transaksi
INNER JOIN obat o ON dp.id_obat = o.id_obat
INNER JOIN kategori_obat ko ON o.id_kategori = ko.id_kategori
ORDER BY tp.tanggal_transaksi DESC;
