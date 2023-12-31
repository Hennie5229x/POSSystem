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
CREATE PROCEDURE [dbo].[lkpItems]
	
	@ItemCode NVARCHAR(50) = NULL,
	@ItemName NVARCHAR(50) = NULL,
	@BarCode NVARCHAR(50) = NULL

AS
BEGIN
	
	SET NOCOUNT ON;  

	SET @ItemCode = ISNULL(@ItemCode,'')
	SET @ItemName = ISNULL(@ItemName,'')
	SET @BarCode = ISNULL(@BarCode,'')

	IF(@ItemCode = '' AND @ItemName = '' AND @BarCode = '')
	BEGIN		
		SELECT	Id, ItemCode ,ItemName, Barcode
		FROM	ItemMaster
		WHERE	ItemCode IS NOT NULL
	END
	ELSE
	BEGIN
		SELECT	Id, ItemCode ,ItemName, Barcode
		FROM	ItemMaster
		WHERE	ItemCode IS NOT NULL
		AND		ISNULL(ItemCode,'') LIKE '%'+@ItemCode+'%'
		AND		ISNULL(ItemName,'') LIKE '%'+@ItemName+'%'
		AND		ISNULL(Barcode,'') LIKE '%'+@BarCode+'%'
	END

	
		
END
GO
