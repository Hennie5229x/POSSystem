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
CREATE PROCEDURE [dbo].[stpStockReceive_Tmp_ItemDetail]
	-- PARAMETERS
		@Id INT
AS
BEGIN
	SET NOCOUNT ON; 
			
		SELECT	B.ItemName, A.QuantityReceived, PricePurchaseIncl, PricePurchaseExcl
		FROM	StockReceive_Temp A
		JOIN	ItemMaster B ON B.Id = A.ItemId
		WHERE	A.Id = @Id
		
		
END
GO
