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
CREATE PROCEDURE [dbo].[calcStockReceiveUpdate_ItemTax]
	-- PARAMETERS
		@Id INT
AS
BEGIN
	SET NOCOUNT ON; 
			
		SELECT	C.VAT
		FROM	StockReceive_Temp A
		JOIN	ItemMaster B ON B.Id = A.ItemId
		JOIN	TaxCodes C ON C.Id = B.TaxCode
		WHERE	A.Id = @Id	
		
END
GO
