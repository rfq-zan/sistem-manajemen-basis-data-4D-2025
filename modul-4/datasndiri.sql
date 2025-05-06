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

-- NO 1
ALTER TABLE kategori_obat ADD COLUMN keterangan TEXT;
SELECT * FROM kategori_obat;

-- NO 2
SELECT t.id_transaksi, p.nama_pelanggan, t.total_harga
FROM transaksi_penjualan t
JOIN pelanggan p ON t.id_pelanggan = p.id_pelanggan;

-- NO 3
SELECT * FROM obat ORDER BY harga_satuan ASC;
SELECT * FROM pelanggan ORDER BY nama_pelanggan DESC;
SELECT * FROM transaksi_penjualan ORDER BY tanggal_transaksi;

-- NO 4
ALTER TABLE pabrik MODIFY COLUMN telepon VARCHAR(20);
SELECT * FROM pabrik;

-- NO 5
-- left
SELECT o.nama_obat, k.nama_kategori
FROM obat o
LEFT JOIN kategori_obat k ON o.id_kategori = k.id_kategori;

-- right
SELECT o.nama_obat, p.nama_pabrik
FROM obat o
RIGHT JOIN pabrik p ON o.id_pabrik = p.id_pabrik;

-- self
ALTER TABLE pelanggan ADD COLUMN referensi_id INT;
SELECT a.nama_pelanggan AS Referen, b.nama_pelanggan AS pereferensi
FROM pelanggan a
JOIN pelanggan b ON a.id_pelanggan = b.referensi_id;

-- kategori e podo
SELECT 
a.nama_obat AS Obat1, 
b.nama_obat AS Obat2
FROM obat a
JOIN obat b ON a.id_kategori = b.id_kategori
WHERE a.id_obat < b.id_obat;

-- NO 6
SELECT * FROM obat WHERE harga_satuan > 10000;
SELECT * FROM obat WHERE stok < 100;
SELECT * FROM pelanggan WHERE member = 'VIP';
SELECT * FROM obat WHERE min_pesanan >= 20;
SELECT * FROM pelanggan WHERE member <> 'Reguler';