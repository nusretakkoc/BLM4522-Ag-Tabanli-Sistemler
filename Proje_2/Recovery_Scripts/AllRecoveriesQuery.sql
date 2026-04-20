-- Full Backup
-- Veritabanının o anki eksiksiz bir kopyasını alır.
BACKUP DATABASE [AdventureWorksLT2022] 
TO DISK = 'C:\BackupDB\AW_Full.bak' 
WITH INIT, NAME = 'AdventureWorksLT2022-Full Backup';

-- Differential Backup
-- Son Tam Yedeklemeden itibaren değişen veirleri kaydeder.
BACKUP DATABASE [AdventureWorksLT2022]
TO DISK = 'C:\BackupDB\AW_Differential.bak'
WITH DIFFERENTIAL, NAME = 'AdventureWorksLT2022-Differential Backup';

-- Log Backup
-- Yapılan işlemleri (insert, update, delete) anlık olarak tutar.
BACKUP LOG [AdventureWorksLT2022]
TO DISK = 'C:\BackupDB\AW_Log.trn'
WITH NAME = 'AdventureWorksLT2022-Transaction Log Backup';