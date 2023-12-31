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
CREATE PROCEDURE [dbo].[stpSalesHistoryLines_Select]	
	
	@DocId INT

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		B.ItemCode,
				B.ItemName,
				A.Quantity,
				CAST(PriceUnitVatIncl AS DECIMAL(19,2)) AS Price,
				CAST(LineTotal AS DECIMAL(19,2)) AS LineTotal,
				CASE WHEN ISNULL(PriceChange,0) = 1 THEN 'True' ELSE 'False' END AS PriceChanged,
				ItemMaster_Price AS FullSellPrice,
				ItemMasterDiscountPercentage AS FullDiscountPercentage,	
				CASE WHEN ISNULL(Promotion,0) = 1 THEN 'True' ELSE 'False' END AS IsPromotion,
				C.PromoName
	FROM		DocumentTransactionsLines A
	JOIN		viwItemMaster B ON B.Id = A.ItemId
	LEFT JOIN	Promotions C ON C.Id = A.PromotionId
	WHERE		A.HeaderId = @DocId
	AND			A.LineStatus = 1 --Open
			
END
GO
