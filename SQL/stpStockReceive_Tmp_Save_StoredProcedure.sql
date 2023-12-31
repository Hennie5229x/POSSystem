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
CREATE PROCEDURE [dbo].[stpStockReceive_Tmp_Save]
	-- PARAMETERS
			
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION
		
			DECLARE	@ItemId INT, 
					@ReceiveDate DATETIME, 
					@QuantityReceived DECIMAL(19,6), 
					@PricePurchaseExcl DECIMAL(19,2), 
					@PricePurchaseIncl DECIMAL(19,2), 
					@SupplierId INT, 
					@ReceivedByUserId NVARCHAR(50), 
					@InvoiceNum NVARCHAR(50)
			
			--Cursor to loop over tmp table 
			DECLARE StockCursor CURSOR 
			FOR
			----------------
			SELECT  ItemId, ReceiveDate, QuantityReceived, PricePurchaseExcl, PricePurchaseIncl, SupplierId, ReceivedByUserId, InvoiceNum
			FROM    StockReceive_Temp
			-----------------
			OPEN StockCursor
			FETCH NEXT FROM StockCursor INTO @ItemId, @ReceiveDate, @QuantityReceived, @PricePurchaseExcl, @PricePurchaseIncl, @SupplierId, @ReceivedByUserId, @InvoiceNum
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				DECLARE @ItemName NVARCHAR(50)
				SELECT	@ItemName = ItemName
				FROM	ItemMaster
				WHERE	Id = @ItemId
			
				DECLARE @Id INT
			
				INSERT INTO StockReceive(ItemId, ReceiveDate, QuantityReceived, PricePurchaseExcl, PricePurchaseIncl, SupplierId, ReceivedByUserId, InvoiceNum)
				VALUES (@ItemId, @ReceiveDate, @QuantityReceived, @PricePurchaseExcl, @PricePurchaseIncl, @SupplierId, @ReceivedByUserId, @InvoiceNum)
				SET @Id = SCOPE_IDENTITY()
			
				UPDATE	A
				SET		A.QuantityAvailable = (ISNULL(A.QuantityAvailable, 0) + @QuantityReceived)
				FROM	ItemMaster A
				WHERE	Id = @ItemId
			
				---------------------------------------
				-------History Log---------------------
				---------------------------------------
			
				DECLARE @To NVARCHAR(MAX) = 'Quantity Received: '+ISNULL(CAST(@QuantityReceived AS NVARCHAR(50)),'')
				DECLARE @Des NVARCHAR(MAX) = 'Stock Received for item: '+ISNULL(@ItemName,'')
			
				EXEC stpHistoryLog_Insert	@UserId = @ReceivedByUserId,	
											@Action = 'Insert',
											@Description = @Des,
											@FromValue = '',
											@ToValue = @To,
											@FieldId = @Id	
			
			
			FETCH NEXT FROM StockCursor
			INTO @ItemId, @ReceiveDate, @QuantityReceived, @PricePurchaseExcl, @PricePurchaseIncl, @SupplierId, @ReceivedByUserId, @InvoiceNum
			END
			CLOSE StockCursor
			DEALLOCATE StockCursor

			DELETE FROM StockReceive_Temp

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
