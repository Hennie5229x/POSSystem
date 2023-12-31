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
CREATE PROCEDURE [dbo].[stpItemMaster_Insert]
	-- PARAMETERS
	
		@Id INT,
		@ItemCode NVARCHAR(50),
		@ItemName NVARCHAR(50),
		--@QuantityAvailable DECIMAL(19,6),
		@QuantityRequestMin DECIMAL(19,6) = NULL,
		@QuantityRequestMax DECIMAL(19,6) = NULL,
		--@QuantityRequested DECIMAL(19,6) = NULL,
		@PriceSellExclVat DECIMAL(19,2),
		--@PricePurchaseExclVat DECIMAL(19,2),
		@DiscountPercentage DECIMAL(19,6),
		@DiscountedPriceIncl DECIMAL(19,6),
		--@ProfitMargin DECIMAL(19,6),
		@Active BIT,
		@Barcode NVARCHAR(100) = NULL,
		@SupplierId INT = NULL,
		@TaxCode INT,
		@LoggedInUserId NVARCHAR(50),
		@UoM INT,
		@ItemGroupId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
						
			IF EXISTS	(
							SELECT	1
							FROM	ItemMaster
							WHERE	ItemCode = @ItemCode
						)
			BEGIN
				RAISERROR('Item Code (PLU) already exists',11,1)
			END

			IF(ISNULL(@SupplierId,0) = 0)
			BEGIN
				SET @SupplierId = NULL
			END
			
			IF EXISTS	(
							SELECT	1	
							FROM	ItemMaster
							WHERE	ItemCode = @ItemCode
						)
			BEGIN	
				DECLARE @Msg NVARCHAR(MAX) = 'Item Code '+@ItemCode+' already exists.'
				RAISERROR(@Msg,11,1)
			END
			ELSE
			BEGIN			

			UPDATE	 A
					 SET [ItemCode]				 = @ItemCode					
						,[ItemName]				 = @ItemName
						--,[QuantityAvailable]	 = @QuantityAvailable
						--,[QuantityRequestMin]	 = @QuantityRequestMin
						--,[QuantityRequestMax]	 = @QuantityRequestMax
						--,[QuantityRequested]	 = @QuantityRequested
						,[PriceSellExclVat]		 = @PriceSellExclVat
						--,[PricePurchaseExclVat]	 = @PricePurchaseExclVat
						,[DiscountPercentage]	 = @DiscountPercentage
						,[DiscountedPriceIncl]	 = @DiscountedPriceIncl
						--,[ProfitMargin]			 = @ProfitMargin
						,[Active]				 = @Active
						,[Barcode]				 = @Barcode
						,[SupplierId]			 = @SupplierId
						,[TaxCode] 				 = @TaxCode
						,[UoMId]				 = @UoM
						,[ItemGroupId]			 = @ItemGroupId
			FROM     ItemMaster A
			WHERE	 A.Id = @Id
			
			/*
				INSERT INTO [dbo].[ItemMaster]
				           (
								 [ItemCode]
								,[ItemName]
								,[QuantityAvailable]
								,[QuantityRequestMin]
								,[QuantityRequestMax]
								,[QuantityRequested]
								,[PriceSellExclVat]
								,[PricePurchaseExclVat]
								,[DiscountPercentage]
								,[DiscountedPriceIncl]
								,[ProfitMargin]
								,[Active]
								,[Barcode]
								,[SupplierId]
								,[TaxCode]
						   )
				     VALUES
				           (
								 @ItemCode
								,@ItemName
								,@QuantityAvailable
								,@QuantityRequestMin
								,@QuantityRequestMax
								,@QuantityRequested
								,@PriceSellExclVat
								,@PricePurchaseExclVat
								,@DiscountPercentage
								,@DiscountedPriceIncl
								,@ProfitMargin
								,@Active
								,@Barcode
								,@SupplierId
								,@TaxCode
						   )
				*/

				---------------------------------------
				-------History Log---------------------
				---------------------------------------

				DECLARE @To NVARCHAR(MAX) = 'Item Code: '+ISNULL(@ItemCode,'')
				DECLARE @Des NVARCHAR(MAX) = 'Stock Management: New item added '+ISNULL(@ItemCode,'')

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Insert',
											@Description = @Des,
											@FromValue = '',
											@ToValue = @To,											
											@FieldId = @Id
				
			END
			
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
