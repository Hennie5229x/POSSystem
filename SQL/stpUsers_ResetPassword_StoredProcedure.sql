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
CREATE PROCEDURE [dbo].[stpUsers_ResetPassword]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@LoggendInUserId NVARCHAR(50),
	@Password NVARCHAR(100),
	@PasswordConfirm NVARCHAR(100)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @UserName NVARCHAR(100)

		SELECT	@UserName = LoginName
		FROM	Users
		WHERE	Id = @UserId

		IF(@Password <> @PasswordConfirm COLLATE Latin1_General_CS_AS)
		BEGIN
			RAISERROR('Passwords do not match',11,1)
		END
		ELSE
		BEGIN
			
			UPDATE		A
			SET			[Password] = dbo.fnPasswordHash(@Password)
			FROM		Users A
			WHERE		Id = @UserId

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			
			DECLARE @Des NVARCHAR(MAX) = 'User '+ISNULL(@UserName,'')+ ' password was reset.'

			EXEC stpHistoryLog_Insert	@UserId = @LoggendInUserId,	
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
