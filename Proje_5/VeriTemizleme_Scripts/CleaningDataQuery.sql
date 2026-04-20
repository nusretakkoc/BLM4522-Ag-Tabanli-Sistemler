-- Yeni Veritabanımız: --------------------------
CREATE DATABASE  ETL_Projesi;
GO

USE ETL_Projesi;
GO
-------------------------------------------------
-- Import Ettiğimiz Veriyi Görelim:
SELECT * FROM Staging_CustomerRawData;
-------------------------------------------------
-- "Common Table Expression" (CTE) kullanarak verinin temizlenme işlemi:
WITH TemizlenmisVeri AS (
    SELECT 
        MusteriID,
        
        -- 1. İsimlerdeki olası gereksiz boşlukların silinme işlemi:
        LTRIM(RTRIM(AdSoyad)) AS AdSoyad,
        
        -- 2. Telefon formatındaki boşluk ve tirelerin silinme işlemi:
        -- Eğer telefon NULL ise 'Bilinmiyor' atanması:
        ISNULL(REPLACE(REPLACE(Telefon, '-', ''), ' ', ''), 'Bilinmiyor') AS TemizTelefon,
        
        -- 3. E-Mail'de @ veya . yoksa hatalı girelim:
        CASE 
            WHEN Email LIKE '%@%.%' THEN Email 
            ELSE 'Hatalı_Email_Formatı' 
        END AS TemizEmail,
        
        KayitTarihi,
        
        -- 4. Şehir isimlerini  BÜYÜK harf ve NULL ise 'BİLİNMİYOR' atanması:
        UPPER(ISNULL(Sehir, 'BİLİNMİYOR')) AS TemizSehir,

        -- 5. Duplicate kayıtları engellemek için her müşteriye bir sıra numarası:
        ROW_NUMBER() OVER(PARTITION BY MusteriID ORDER BY KayitTarihi DESC) as SatirNo

    FROM Staging_CustomerRawData
)
-- Temizlenmiş havuzdan sadece tekil olanlar (SatirNo = 1):
SELECT 
    MusteriID, 
    AdSoyad, 
    TemizTelefon, 
    TemizEmail, 
    KayitTarihi, 
    TemizSehir
FROM TemizlenmisVeri
WHERE SatirNo = 1;

-----------------------------------------------------------------
-- Temizlenmiş verilerin tutulacağı nihai hedef tablomuz
CREATE TABLE Hedef_Musteri (
    MusteriID INT PRIMARY KEY,
    AdSoyad NVARCHAR(100),
    Telefon NVARCHAR(50),
    Email NVARCHAR(100),
    KayitTarihi DATE,
    Sehir NVARCHAR(50)
);
------------------------------------------------------------------
-- Veriyi Temizleyip Yükleme (INSERT INTO ... SELECT):
WITH TemizlenmisVeri AS (
    SELECT 
        MusteriID,
        LTRIM(RTRIM(AdSoyad)) AS AdSoyad,
        ISNULL(REPLACE(REPLACE(Telefon, '-', ''), ' ', ''), 'Bilinmiyor') AS TemizTelefon,
        CASE WHEN Email LIKE '%@%.%' THEN Email ELSE 'Hatalı_Email_Formatı' END AS TemizEmail,
        KayitTarihi,
        UPPER(ISNULL(Sehir, 'BİLİNMİYOR')) AS TemizSehir,
        ROW_NUMBER() OVER(PARTITION BY MusteriID ORDER BY KayitTarihi DESC) as SatirNo
    FROM Staging_CustomerRawData
)
-- Temizlenmiş ve tekilleştirilmiş verinin Hedef_Musteri tablosuna basılması:
INSERT INTO Hedef_Musteri (MusteriID, AdSoyad, Telefon, Email, KayitTarihi, Sehir)
SELECT 
    MusteriID, 
    AdSoyad, 
    TemizTelefon, 
    TemizEmail, 
    KayitTarihi, 
    TemizSehir
FROM TemizlenmisVeri
WHERE SatirNo = 1;

-- Yüklenen veriyi kontrolü:
SELECT * FROM Hedef_Musteri;
------------------------------------------------------------
-- Veri Kalitesi Raporları:
SELECT 
    (SELECT COUNT(*) FROM Staging_CustomerRawData) AS Toplam_Ham_Kayit,
    (SELECT COUNT(*) FROM Hedef_Musteri) AS Toplam_Temiz_Kayit,
    (SELECT COUNT(*) FROM Staging_CustomerRawData) - (SELECT COUNT(*) FROM Hedef_Musteri) AS Silinen_Cift_Kayit_Sayisi,
    (SELECT COUNT(*) FROM Hedef_Musteri WHERE Telefon = 'Bilinmiyor') AS Eksik_Telefon_Sayisi,
    (SELECT COUNT(*) FROM Hedef_Musteri WHERE Email = 'Hatalı_Email_Formatı') AS Hatali_Email_Sayisi,
    (SELECT COUNT(*) FROM Hedef_Musteri WHERE Sehir = 'BİLİNMİYOR') AS Eksik_Sehir_Sayisi;