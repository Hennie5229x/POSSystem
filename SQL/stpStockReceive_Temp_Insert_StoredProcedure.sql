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
CREATE PROCEDURE [dbo].[stpStockReceive_Temp_Insert]
	-- PARAMETERS
		@ItemId INT, 
		@QuantityReceived DECIMAL(19,6), 
		@PricePurchaseExcl DECIMAL(19,2), 
		@PricePurchaseIncl DECIMAL(19,2), 
		@SupplierId INT, 
		@ReceivedByUserId NVARCHAR(50),
		@InvoiceNum NVARCHAR(50),
		@ReceiveDate DATETIME
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION	
			
			INSERT INTO StockReceive_Temp(ItemId, ReceiveDate, QuantityReceived, PricePurchaseExcl, PricePurchaseIncl, SupplierId, ReceivedByUserId, InvoiceNum)
			VALUES(@ItemId, @ReceiveDate, @QuantityReceived, @PricePurchaseExcl, @PricePurchaseIncl, @SupplierId, @ReceivedByUserId, @InvoiceNum)
			
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		-- Raise an error with the details of the exception
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		SET @ErrMsg = ERROR_MESSAGE()
		SET @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1) 
	END CATCH 
END
GO
