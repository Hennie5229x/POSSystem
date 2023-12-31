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
CREATE PROCEDURE [dbo].[stpUsers_Insert]
	-- PARAMETERS
	@LoginName NVARCHAR(100),
	@Password NVARCHAR(100),
	@Name NVARCHAR(100),
	@Surname NVARCHAR(100),
	@Phone NVARCHAR(50),
	@Email NVARCHAR(250),
	@UserId NVARCHAR(50),
	@Pin NCHAR(4)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION
			
			IF((SELECT ISNUMERIC(@Pin)) = 0)
			BEGIN
				RAISERROR('Pin has to be numeric',11,1)
			END
			IF EXISTS(SELECT 1 FROM Users WHERE Pin = @Pin)
			BEGIN
				RAISERROR('Pin already in use',11,1)
			END


			IF(@Phone = '')
			BEGIN
				SET @Phone = NULL				
			END
			IF(@Email = '')
			BEGIN
				SET @Email = NULL
			END

			------------------------------------------------
			IF(ISNULL(@LoginName,'') = '')
			BEGIN
				RAISERROR('Login Name cannot be empty.',11,1)
			END
			ELSE IF(ISNULL(@Password,'') = '')
			BEGIN
				RAISERROR('Password cannot be empty.',11,1)
			END
			ELSE IF(ISNULL(@Name,'') = '')
			BEGIN
				RAISERROR('Name cannot be empty.',11,1)
			END
			ELSE IF(ISNULL(@Surname,'') = '')
			BEGIN
				RAISERROR('Surname cannot be empty.',11,1)
			END
			ELSE IF EXISTS (
								SELECT	1
								FROM	Users
								WHERE	LoginName = @LoginName
							)
			BEGIN
				DECLARE @Msg NVARCHAR(MAX) = '"'+@LoginName+'" already exists.'
				RAISERROR(@Msg,11,1)
			END
			ELSE
			BEGIN
				INSERT INTO Users (Id, LoginName, [Password], [Name], Surname, Phone, Email, Active, Pin)
				VALUES (NEWID(), @LoginName, dbo.fnPasswordHash(@Password), @Name, @Surname, @Phone, @Email, 1, @Pin)
			END
			
			DECLARE @To NVARCHAR(MAX) = 'Login Name: '+ISNULL(@LoginName,'')

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = 'User Management: New User created',
										@FromValue = '',
										@ToValue = @To


			
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
