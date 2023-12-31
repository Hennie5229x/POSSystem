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
CREATE PROCEDURE [dbo].[calcChangePrice_Values]
	
	@DocId INT,
	@LineId INT,
	@ItemId INT,
	@Action NVARCHAR(50) --SearchChange/PriceChange
AS
BEGIN	
	SET NOCOUNT ON;  

	IF(@Action = 'SearchChange') --From Search Item Action
	BEGIN
		SELECT	ItemName, QuantityAvailable AS Quantity, DiscountPriceSellIncl AS Price
		FROM	viwItemMaster
		WHERE	Id = @ItemId
	END
	ELSE IF(@Action = 'PriceChange') --From Price Change Action
	BEGIN
		SELECT	B.ItemName, A.Quantity, CAST(A.PriceUnitVatIncl AS DECIMAL(19,2)) AS Price
		FROM	DocumentTransactionsLines A
		JOIN	ItemMaster B ON B.Id = A.ItemId
		WHERE	A.HeaderId = @DocId
		AND		A.Id = @LineId
	END
		

END
GO
