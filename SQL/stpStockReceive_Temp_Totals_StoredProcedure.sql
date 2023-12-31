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
CREATE PROCEDURE [dbo].[stpStockReceive_Temp_Totals]
	-- PARAMETERS
		
AS
BEGIN
	SET NOCOUNT ON; 
			
		SELECT	CAST(SUM(PricePurchaseIncl) AS DECIMAL(19,2)) AS PricePurchaseIncl,
				CAST(SUM(PricePurchaseExcl) AS DECIMAL(19,2)) AS PricePurchaseExcl,
				CAST(SUM(PricePurchaseIncl) - SUM(PricePurchaseExcl) AS DECIMAL(19,2)) AS VAT 
		FROM	StockReceive_Temp
		
END
GO
