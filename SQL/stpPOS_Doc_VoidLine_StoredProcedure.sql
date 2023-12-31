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
CREATE PROCEDURE [dbo].[stpPOS_Doc_VoidLine]
	-- PARAMETERS
	@DocId INT,
	@LineId INT	
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION	
		
		DECLARE @DocTotal DECIMAL(19,6) = 0.0		
		
		
		UPDATE	DocumentTransactionsLines
		SET		LineStatus = 2 --Closed
		WHERE	HeaderId = @DocId
		AND		Id = @LineId

		SELECT	@DocTotal = SUM(LineTotal)
		FROM	DocumentTransactionsLines
		WHERE	HeaderId = @DocId
		AND		LineStatus = 1 --Open		

		--DECLARE @A NVARCHAR(MAX) = ''
		--SET @A = CAST(@DocTotal AS NVARCHAR(50))
		--SET @A = ISNULL(@A,'NULL')
		--RAISERROR(@A,11,1)		
		
		UPDATE	DocumentTransactionsHeader
		SET		DocumentTotal = ISNULL(@DocTotal,0.0)
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
