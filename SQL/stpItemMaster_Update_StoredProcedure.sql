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
CREATE PROCEDURE [dbo].[stpItemMaster_Update]
	-- PARAMETERS
	
		@Id INT,
		@ItemCode NVARCHAR(50),
		@ItemName NVARCHAR(50),		
		@PriceSellExclVat DECIMAL(19,2),		
		@DiscountPercentage DECIMAL(19,6),
		@DiscountedPriceIncl DECIMAL(19,6),		
		@Active BIT,
		@Barcode NVARCHAR(100) = NULL,
		@SupplierId INT = NULL,
		@TaxCode INT,
		@LoggedInUserId NVARCHAR(50),
		@UoM INT,
		@ItemGroupId INT,
		@QuantityRequestMin DECIMAL(19,6) = NULL,
		@QuantityRequestMax DECIMAL(19,6) = NULL

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
						
			
			IF(ISNULL(@SupplierId,0) = 0)
			BEGIN
				SET @SupplierId = NULL
			END		

			UPDATE	 A
					 SET [ItemCode]				 = @ItemCode					
						,[ItemName]				 = @ItemName						
						,[PriceSellExclVat]		 = @PriceSellExclVat						
						,[DiscountPercentage]	 = @DiscountPercentage
						,[DiscountedPriceIncl]	 = @DiscountedPriceIncl						
						,[Active]				 = @Active
						,[Barcode]				 = @Barcode
						,[SupplierId]			 = @SupplierId
						,[TaxCode] 				 = @TaxCode
						,[UoMId]				 = @UoM
						,[ItemGroupId]			 = @ItemGroupId
						,QuantityRequestMin		 = @QuantityRequestMin
						,QuantityRequestMax		 = @QuantityRequestMax
						,TimeStampChange		 = GETDATE()

			FROM     ItemMaster A
			WHERE	 A.Id = @Id
			
			
				---------------------------------------
				-------History Log---------------------
				---------------------------------------

				DECLARE @To NVARCHAR(MAX) = 'Item Code: '+ISNULL(@ItemCode,'')
				DECLARE @Des NVARCHAR(MAX) = 'Stock Management: Item updated '+ISNULL(@ItemCode,'')

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
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
