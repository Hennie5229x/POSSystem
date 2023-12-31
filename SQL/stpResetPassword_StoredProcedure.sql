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
CREATE PROCEDURE [dbo].[stpResetPassword]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@CurrentPass NVARCHAR(100),
	@NewPass NVARCHAR(100),
	@ConfirmPass NVARCHAR(100)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @LoginName NVARCHAR(100)
		DECLARE @Pass NVARCHAR(250)

		SELECT	@LoginName = LoginName,
				@Pass = [Password]
		FROM	Users
		WHERE	Id = @UserId

		IF(dbo.fnPasswordHash(@CurrentPass) <> @Pass)
		BEGIN
			RAISERROR('Current password incorrect',11,1)
		END
		ELSE IF(@NewPass <> @ConfirmPass COLLATE Latin1_General_CS_AS)
		BEGIN
			RAISERROR('Passwords do not match',11,1)
		END
		ELSE
		BEGIN
			
			UPDATE	Users
			SET		[Password] = dbo.fnPasswordHash(@NewPass)
			WHERE	Id = @UserId

			---------------------------------------
			-------History Log---------------------
			---------------------------------------		
			DECLARE @Des NVARCHAR(MAX) = 'Users: '+@LoginName+' password changed'

			EXEC stpHistoryLog_Insert	@UserId = @UserId,
										@Action = 'Update',
										@Description = @Des,
										@FromValue = '',
										@ToValue = '',											
										@FieldId = @UserId
		
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
