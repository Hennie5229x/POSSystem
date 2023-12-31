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
CREATE PROCEDURE [dbo].[stpPOS_Doc_QtyChange]
	-- PARAMETERS
	@LineId INT,
	@Quantity DECIMAL(19,6),
	@DocId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF(@Quantity <= 0)
		BEGIN
			RAISERROR('Quantity cannot be smaller than or equal to 0.',11,1)
		END
		ELSE
		BEGIN

			DECLARE @LineTotal DECIMAL(19,2)
			DECLARE @DocTotal DECIMAL(19,6)
			

			SELECT	@LineTotal = (@Quantity * PriceUnitVatIncl)				
			FROM	DocumentTransactionsLines
			WHERE	HeaderId = @DocId
			AND		Id = @LineId

			UPDATE	A
			SET		A.Quantity = @Quantity,
					A.LineTotal = @LineTotal
			FROM	DocumentTransactionsLines A
			WHERE	HeaderId = @DocId
			AND		Id = @LineId

			SELECT	@DocTotal = SUM(LineTotal)
			FROM	DocumentTransactionsLines
			WHERE	HeaderId = @DocId
			AND		LineStatus = 1 --Open

			UPDATE	DocumentTransactionsHeader
			SET		DocumentTotal = @DocTotal
			WHERE	Id = @DocId	

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
