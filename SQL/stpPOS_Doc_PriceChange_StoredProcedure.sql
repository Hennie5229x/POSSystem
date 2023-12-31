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
CREATE PROCEDURE [dbo].[stpPOS_Doc_PriceChange]
	-- PARAMETERS
	@LineId INT,
	@Price DECIMAL(19,6),
	@DocId INT
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF(ISNULL(@Price, 0) <= 0)
		BEGIN
			RAISERROR('Price cannot be smaller than or equal to 0.',11,1)
		END
		ELSE
		BEGIN

			DECLARE @LineTotal DECIMAL(19,2)
			DECLARE @DocTotal DECIMAL(19,6)
						
			UPDATE	A
			SET		PriceUnitVatIncl = @Price,
					LineTotal = (ISNULL(@Price, 0) * ISNULL(Quantity, 0))
			FROM	DocumentTransactionsLines A
			WHERE	HeaderId = @DocId
			AND		Id = @LineId				

			SELECT	@DocTotal = SUM(B.LineTotal)
			FROM	DocumentTransactionsHeader A
			JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
			WHERE	A.Id = @DocId
			AND		B.LineStatus = 1
			
			UPDATE	A
			SET		A.DocumentTotal = @DocTotal
			FROM	DocumentTransactionsHeader A
			JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
			WHERE	A.Id = @DocId
			AND		B.LineStatus = 1
			
			/*--------------------------*/
			DECLARE @ItemMasterPrice DECIMAL(19,6),
					@ItemMasterDiscountPercentage DECIMAL(19,6)
			
			SELECT	@ItemMasterPrice = DiscountPriceSellIncl,
					@ItemMasterDiscountPercentage = B.DiscountPercentage
			FROM	DocumentTransactionsLines A
			JOIN	viwItemMaster B ON B.Id = A.ItemId
			WHERE	A.Id = @LineId
			
			IF(@ItemMasterPrice <> @Price)
			BEGIN
				UPDATE	A
				SET		ItemMaster_Price = @ItemMasterPrice,
						ItemMasterDiscountPercentage = @ItemMasterDiscountPercentage,
						PriceChange_Price = @Price,
						PriceChange = 1 --True
				FROM	DocumentTransactionsLines A
				WHERE	HeaderId = @DocId
				AND		Id = @LineId
			END					

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
