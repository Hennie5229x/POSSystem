USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpUsers]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	Id,
			ISNULL([Name],'')+' '+ISNULL(Surname,'') AS [Name]
	FROM	Users
	
	
		
END
GO
