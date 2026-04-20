-- Full Recovery dosyası testi:
RESTORE VERIFYONLY 
FROM DISK = 'C:\BackupDB\AW_Otomatik_Full.bak';

-- Diff Recovery dosyası testi:
RESTORE VERIFYONLY 
FROM DISK = 'C:\BackupDB\AW_Differential.bak';

-- TransactionLog dosyası testi:
RESTORE VERIFYONLY 
FROM DISK = 'C:\BackupDB\AW_Log.trn';