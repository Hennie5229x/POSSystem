USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Temp_ItemDetail]
	-- PARAMETERS
	@ItemId INT	
AS
BEGIN
	SET NOCOUNT ON; 
			
	SELECT		B.UoM, A.DiscountedPriceIncl AS PriceSellIncl
	FROM		ItemMaster A
	LEFT JOIN	UoM B ON B.Id = A.UoMId
	WHERE		A.Id = @ItemId
		
		
END
GO
