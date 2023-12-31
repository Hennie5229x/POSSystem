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
CREATE PROCEDURE [dbo].[stpPOS_PAY_TenderTypes]
	-- PARAMETERS
	@DocId INT,
	@TenderType NVARCHAR(10), --Cash/Card
	@TenderedTotal DECIMAL(19,2)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF(@TenderType = 'Cash')
		BEGIN
			UPDATE	A 
			SET		A.TenderedCashTotal = @TenderedTotal
			FROM	DocumentTransactionsHeader A
			WHERE	A.Id = @DocId
		END
		ELSE IF(@TenderType = 'Card')
		BEGIN
			UPDATE	A 
			SET		A.TenderedCardTotal = @TenderedTotal
			FROM	DocumentTransactionsHeader A
			WHERE	A.Id = @DocId
		END

		UPDATE	A
		SET		TenderedTotal = (ISNULL(TenderedCashTotal,0) + ISNULL(TenderedCardTotal,0))
		FROM	DocumentTransactionsHeader A
		WHERE	Id = @DocId

					
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
