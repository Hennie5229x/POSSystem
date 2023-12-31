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
CREATE PROCEDURE [dbo].[stpRoleGroupsUsers_Delete]
	-- PARAMETERS
	
	@RoleGroupId INT,
	@UserId UNIQUEIDENTIFIER,
	@LoggedInUserId NVARCHAR(50)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION	

			DECLARE @UserName NVARCHAR(250),
					@RoleGroupName NVARCHAR(50)

			SELECT	@RoleGroupName = [Name]
			FROM	RoleGroups
			WHERE	Id = @RoleGroupId

			SELECT	@UserName = ISNULL([Name],'')+' '+ISNULL(Surname,'')
			FROM	Users
			WHERE	Id = @UserId

			DELETE
			FROM	RoleGroupUsers
			WHERE	RoleGroupId = @RoleGroupId
			AND		UserId = @UserId

			---------------------------------------
			-------History Log---------------------
			---------------------------------------

			DECLARE @Fr NVARCHAR(MAX) = 'User Name: '+ISNULL(@UserName,'')
			DECLARE @Des NVARCHAR(MAX) = 'Role Group Users: '+@UserName+' removed from Role Group: '+ISNULL(@RoleGroupName,'')

			EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
										@Action = 'Delete',
										@Description = @Des,
										@FromValue = @Fr,
										@ToValue = ''
			
		
			
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
