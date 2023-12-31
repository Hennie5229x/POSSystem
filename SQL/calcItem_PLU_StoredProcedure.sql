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
CREATE PROCEDURE [dbo].[calcItem_PLU]
	
	
AS
BEGIN
	
	SET NOCOUNT ON;  

	DECLARE @Code NVARCHAR(10)
	DECLARE @PLU NVARCHAR(50)

	SELECT		TOP 1 @Code = ItemCode
	FROM		ItemMaster
	WHERE		ItemCode IS NOT NULL
	AND			ISNUMERIC(ItemCode) = 1
	ORDER BY	ItemCode DESC	
	
	DECLARE @Number INT = CAST(@Code AS NVARCHAR(50)) +1 
	SET @Number = ISNULL(@Number,1)	
	SET @PLU = RIGHT ('0000'+ CAST(@Number AS NVARCHAR), 5) 	

	WHILE EXISTS (SELECT 1 FROM ItemMaster WHERE ItemCode = @PLU)
	BEGIN
		SET @Number  = CAST(@PLU AS NVARCHAR(50)) +1 
		SET @Number = ISNULL(@Number,1)	
		SET @PLU = RIGHT ('0000'+ CAST(@Number AS NVARCHAR), 5) 		
	END

	SELECT @PLU AS PLU

	----------------
	--Old Code
	----------------
	--DECLARE @Code NVARCHAR(10)

	--SELECT		TOP 1 @Code = ItemCode
	--FROM		ItemMaster
	--WHERE		ItemCode IS NOT NULL
	--AND			ISNUMERIC(ItemCode) = 1
	--ORDER BY	ItemCode DESC
	
	--DECLARE @Number INT = CAST(@Code AS NVARCHAR(50)) +1 
	
	--SELECT RIGHT ('0000'+ CAST(@Number AS NVARCHAR), 5) AS PLU


END
GO
