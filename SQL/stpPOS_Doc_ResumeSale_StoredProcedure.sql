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
CREATE PROCEDURE [dbo].[stpPOS_Doc_ResumeSale]
	-- PARAMETERS
	@UserId NVARCHAR(50),
	@TerminalId INT
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION	
		
		IF EXISTS	(
						SELECT	1
						FROM	DocumentTransactionsHeader
						WHERE	DocumentStatusId = 1 --Open
						AND		UserId = @UserId
						AND		TerminalId = @TerminalId
					)
		BEGIN
			RAISERROR('There is sale in progress, finish the current sale first.',11,1)
		END
		ELSE IF NOT EXISTS	(
								SELECT	1 
								FROM	DocumentTransactionsHeader
								WHERE	DocumentStatusId = 2 --Suspended
								AND		UserId = @UserId
								AND		TerminalId = @TerminalId
							)
		BEGIN
			RAISERROR('There is no sale to resume, first suspend a sale.',11,1)
		END
		ELSE
		BEGIN
				
			UPDATE	DocumentTransactionsHeader
			SET		DocumentStatusId = 1 --Open
			WHERE	DocumentStatusId = 2 --Suspended
			AND		UserId = @UserId
			AND		TerminalId = @TerminalId

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
