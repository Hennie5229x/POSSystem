USE [POSSystem]
GO
CREATE USER [POSUser] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [POSUser]
GO
