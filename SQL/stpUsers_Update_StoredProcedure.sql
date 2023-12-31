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
CREATE PROCEDURE [dbo].[stpUsers_Update]
	-- PARAMETERS
	
	@UserId UNIQUEIDENTIFIER,	
	@Name NVARCHAR(100),
	@Surname NVARCHAR(100),
	@Phone NVARCHAR(50),
	@Email NVARCHAR(250),
	@LoggedInUserId NVARCHAR(50),
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

			---History Log Params
			DECLARE @NameOld NVARCHAR(100),
					@SurnameOld NVARCHAR(100),
					@PhoneOld NVARCHAR(50),
					@EmailOld NVARCHAR(250),
					@LoginName NVARCHAR(100)
			
			SELECT	@NameOld = [Name],
					@SurnameOld = Surname,
					@PhoneOld = Phone,
					@EmailOld = Email,
					@LoginName = LoginName
			FROM	Users
			WHERE	Id = @UserId
			----------------------------

			IF(@Phone = '')
			BEGIN
				SET @Phone = NULL				
			END
			IF(@Email = '')
			BEGIN
				SET @Email = NULL
			END
			---------------------------------
			IF(ISNULL(@Name,'') = '')
			BEGIN
				RAISERROR('Name cannot be empty.',11,1)
			END
			ELSE IF(ISNULL(@Surname,'') = '')
			BEGIN
				RAISERROR('Surname cannot be empty.',11,1)
			END
			ELSE
			BEGIN
				UPDATE		A
				SET			[Name] = @Name,
							[Surname] = @Surname,
							Phone = @Phone,
							Email = @Email,
							Pin	= @Pin
				FROM		Users A
				WHERE		Id = @UserId
			END
			
			

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = '',
					@From NVARCHAR(MAX) = '',
					@Desc NVARCHAR(MAX) = ''

			IF(ISNULL(@Name,'') <> ISNULL(@NameOld,''))
			BEGIN
				SET @From = 'Name: '+@NameOld
				SET @To = 'Name: '+@Name
				SET @Desc = 'User Management: User '+@LoginName+' Updated'

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
											@Description = @Desc,
											@FromValue = @From,
											@ToValue = @To
			END					
			IF(ISNULL(@Surname,'') <> ISNULL(@SurnameOld,''))
			BEGIN
				SET @From = 'Surname: '+@SurnameOld
				SET @To = 'Surname: '+@Surname
				SET @Desc = 'User Management: User '+@LoginName+' Updated'

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
											@Description = @Desc,
											@FromValue = @From,
											@ToValue = @To
			END	
			IF(ISNULL(@Phone,'') <> ISNULL(@PhoneOld,''))
			BEGIN
				SET @From = 'Phone: '+@PhoneOld
				SET @To = 'Phone: '+@Phone
				SET @Desc = 'User Management: User '+@LoginName+' Updated'

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
											@Description = @Desc,
											@FromValue = @From,
											@ToValue = @To
			END	
			IF(ISNULL(@Email,'') <> ISNULL(@EmailOld,''))
			BEGIN
				SET @From = 'Email: '+@EmailOld
				SET @To = 'Email: '+@Email
				SET @Desc = 'User Management: User '+@LoginName+' Updated'

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
											@Description = @Desc,
											@FromValue = @From,
											@ToValue = @To
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
