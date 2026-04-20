-- 1. Test için bir tablo ve veri oluşturmak:
CREATE TABLE FelaketTesti (ID INT, Bilgi VARCHAR(100));
INSERT INTO FelaketTesti VALUES (1, 'Silinmemesi Gereken Veri');

-- Tablodaki veri:
SELECT * FROM FelaketTesti;

-- Güvenli Saat:
SELECT GETDATE() AS [Silinmeden Onceki Zaman];


-- Veriyi Silmek:
DELETE FROM FelaketTesti;

-- Tablonun boş olduğunun teyit edilmesi:
SELECT * FROM FelaketTesti;