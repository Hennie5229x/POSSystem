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
CREATE PROCEDURE [dbo].[stpStockReceive_Insert]
	-- PARAMETERS
		@ItemId INT, 
		@QuantityReceived DECIMAL(19,6), 
		@PricePurchaseExcl DECIMAL(19,2), 
		@PricePurchaseIncl DECIMAL(19,2), 
		@SupplierId INT, 
		@ReceivedByUserId NVARCHAR(50),
		@InvoiceNum NVARCHAR(50)


AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			DECLARE @ItemName NVARCHAR(50)
			SELECT	@ItemName = ItemName
			FROM	ItemMaster
			WHERE	Id = @ItemId

			DECLARE @Id INT
			
			INSERT INTO StockReceive(ItemId, ReceiveDate, QuantityReceived, PricePurchaseExcl, PricePurchaseIncl, SupplierId, ReceivedByUserId)
			VALUES(@ItemId, GETDATE(), @QuantityReceived, @PricePurchaseExcl, @PricePurchaseIncl, @SupplierId, @ReceivedByUserId)
			SET @Id = SCOPE_IDENTITY()

			--DECLARE @QtyAvail DECIMAL(19,6)
			--SELECT	@QtyAvail = QuantityAvailable
			--FROM	ItemMaster
			--WHERE	Id = @Id

			UPDATE	A
			SET		A.QuantityAvailable = (ISNULL(A.QuantityAvailable, 0) + @QuantityReceived)
			FROM	ItemMaster A
			WHERE	Id = @ItemId

			---------------------------------------
			-------History Log---------------------
			---------------------------------------

			DECLARE @To NVARCHAR(MAX) = 'Quantity: '+ISNULL(CAST(@QuantityReceived AS NVARCHAR(50)),'')
			DECLARE @Des NVARCHAR(MAX) = 'Stock Received for item: '+ISNULL(@ItemName,'')

			EXEC stpHistoryLog_Insert	@UserId = @ReceivedByUserId,	
										@Action = 'Insert',
										@Description = @Des,
										@FromValue = '',
										@ToValue = @To,
										@FieldId = @Id			
		
			
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
