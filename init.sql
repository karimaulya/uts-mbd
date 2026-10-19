-- 1. Skema SALAM
CREATE SCHEMA IF NOT EXISTS SALAM;

-- 2. Tabel mahasiswas
CREATE TABLE SALAM.mahasiswas (
    id SERIAL PRIMARY KEY,
    nim VARCHAR(15) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    ipk DECIMAL(3,2) CHECK (ipk >= 0.00 AND ipk <= 4.00),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. User Baru
CREATE USER backend_dev WITH PASSWORD 'password123';
CREATE USER bi_dev WITH PASSWORD 'password123';
CREATE USER data_engineer WITH PASSWORD 'password123';

-- 4. Hak Akses

-- A. backend_dev
GRANT USAGE ON SCHEMA SALAM TO backend_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA SALAM TO backend_dev;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA SALAM TO backend_dev;

-- B. bi_dev
GRANT USAGE ON SCHEMA SALAM TO bi_dev;
GRANT SELECT ON ALL TABLES IN SCHEMA SALAM TO bi_dev;
ALTER DEFAULT PRIVILEGES IN SCHEMA SALAM GRANT SELECT ON TABLES TO bi_dev;

-- C. data_engineer
GRANT ALL PRIVILEGES ON SCHEMA SALAM TO data_engineer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SALAM TO data_engineer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA SALAM TO data_engineer;


-- FITUR TAMBAHAN 1: VIEW
CREATE VIEW salam.v_mhs_berprestasi AS 
SELECT nim, nama, ipk 
FROM salam.mahasiswas 
WHERE ipk >= 3.50;

GRANT SELECT ON salam.v_mhs_berprestasi TO bi_dev;

-- FITUR TAMBAHAN 2: TRIGGER
-- 1. tabel untuk menyimpan log
CREATE TABLE salam.log_aktivitas (
    id SERIAL PRIMARY KEY,
    keterangan TEXT,
    waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. fungsi trigger
CREATE OR REPLACE FUNCTION catat_log_update() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO salam.log_aktivitas (keterangan) 
    VALUES ('Data mahasiswa dengan NIM ' || OLD.nim || ' telah di-update.');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Pasang trigger ke tabel mahasiswas
CREATE TRIGGER trg_update_mhs
AFTER UPDATE ON salam.mahasiswas
FOR EACH ROW EXECUTE FUNCTION catat_log_update();