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
CREATE PROCEDURE [dbo].[stpDenomiations_Reset]
	-- PARAMETERS
	
	@UserId NVARCHAR(50)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
			IF EXISTS	(
							SELECT	1
							FROM	CashUp
						)
			BEGIN
				RAISERROR('Denominations cannot be reset, because it is being used in Cash Ups',11,1)
			END
			ELSE
			BEGIN
				TRUNCATE TABLE Denominations
			
			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			
			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = 'Denominations: Denominations Reset',
										@FromValue = '',
										@ToValue = '',
										@FieldId = NULL
			
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
