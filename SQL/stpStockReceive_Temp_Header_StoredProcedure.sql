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
CREATE PROCEDURE [dbo].[stpStockReceive_Temp_Header]
	-- PARAMETERS
		
AS
BEGIN
	SET NOCOUNT ON; 
			
		IF EXISTS	(
						SELECT	1
						FROM	StockReceive_Temp
					)
		BEGIN
			SELECT	TOP 1 SupplierId, InvoiceNum, CAST(ReceiveDate AS DATE) AS ReceiveDate, 1 AS [Exists]
			FROM	StockReceive_Temp
		END
		ELSE
		BEGIN
			SELECT NULL AS SupplierId, NULL AS InvoiceNum, CAST(GETDATE() AS DATE) AS ReceiveDate, 0 AS [Exists]
		END

		
		
		
END
GO
