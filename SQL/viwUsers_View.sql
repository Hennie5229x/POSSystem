USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viwUsers] AS

SELECT      Id, LoginName, Password, Name, Surname, Phone, Email, Active, ISNULL(Name,'')+' '+ISNULL(Surname,'') AS FullName
FROM        Users
GO
