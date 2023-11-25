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
CREATE PROCEDURE [dbo].[stpStockReceive_Tmp_Update]
	-- PARAMETERS
		@Id INT,
		@Quantity DECIMAL(19,6),
		@PriceIncl DECIMAL(19,2),
		@PriceExcl DECIMAL(19,2)
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION	
		
		UPDATE	A
		SET		A.QuantityReceived = @Quantity,
				A.PricePurchaseIncl = @PriceIncl,
				A.PricePurchaseExcl = @PriceExcl
		FROM	StockReceive_Temp A
		WHERE	A.Id = @Id

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
