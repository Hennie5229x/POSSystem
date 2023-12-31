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
CREATE PROCEDURE [dbo].[stpUsers_ActiveInactive]
	-- PARAMETERS
	
	@UserId UNIQUEIDENTIFIER,	
	@Active BIT,
	@LoggedInUserId NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
				DECLARE @ActiveOld BIT,
						@CurrentLoggedInUser NVARCHAR(100),
						@SelectedUser NVARCHAR(50)

				SELECT	@ActiveOld = Active,
						@SelectedUser = LoginName
				FROM	Users
				WHERE	Id = @UserId

				SELECT	@CurrentLoggedInUser = LoginName
				FROM	Users
				WHERE	Id = @LoggedInUserId

				UPDATE		A
				SET			Active = @Active
				FROM		Users A
				WHERE		Id = @UserId

				-------------------------
				--History Log-------
				-------------------------
				DECLARE @Desc NVARCHAR(MAX) = 'User Management: User '+@SelectedUser+' Active/Inactive updated',
						@From NVARCHAR(MAX) = 'Active: '+ CASE WHEN @ActiveOld = 1 THEN 'Active' ELSE 'Inactive' END,
						@To NVARCHAR(MAX) = 'Active: '+ CASE WHEN @Active = 1 THEN 'Active' ELSE 'Inactive' END

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
											@Description = @Desc,
											@FromValue = @From,
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
