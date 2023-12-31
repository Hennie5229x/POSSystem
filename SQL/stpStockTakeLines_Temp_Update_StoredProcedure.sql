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
CREATE PROCEDURE [dbo].[stpStockTakeLines_Temp_Update]
	-- PARAMETERS
	@Id INT,
	@Quantity DECIMAL(19,6) = NULL

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @ItemId INT
		DECLARE @OnHand DECIMAL(19,6)

		SELECT	@ItemId = ItemId
		FROM	StockTakeLines_Temp
		WHERE	Id = @Id

		SELECT	@OnHand = QuantityAvailable
		FROM	ItemMaster
		WHERE	Id = @ItemId


		UPDATE	StockTakeLines_Temp
		SET		Quantity = @Quantity,
				Variance = (ISNULL(@OnHand,0.0) - @Quantity)
		WHERE	Id = @Id

		
			
			
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
