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
CREATE PROCEDURE [dbo].[stpRoleGroupsUsers_Insert]
	-- PARAMETERS
	
	@RoleGroupId INT,
	@UserId NVARCHAR(50),
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


		IF(ISNULL(@UserId,'') = '')
		BEGIN
			RAISERROR('Must select a user',11,1)
		END
		ELSE IF EXISTS	(
							SELECT	1
							FROM	RoleGroupUsers
							WHERE	UserId = @UserId
							AND		RoleGroupId = @RoleGroupId
						)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX) = @UserName + ' already in role group'
			RAISERROR(@Msg,11,1)
		END
		ELSE
		BEGIN

			INSERT INTO RoleGroupUsers (UserId, RoleGroupId)
			VALUES (@UserId, @RoleGroupId)

			---------------------------------------
			-------History Log---------------------
			---------------------------------------

			DECLARE @To NVARCHAR(MAX) = 'User Name: '+ISNULL(@UserName,'')
			DECLARE @Des NVARCHAR(MAX) = 'Role Group Users: '+@UserName+' added to Role Group: '+ISNULL(@RoleGroupName,'')

			EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
										@Action = 'Insert',
										@Description = @Des,
										@FromValue = '',
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
