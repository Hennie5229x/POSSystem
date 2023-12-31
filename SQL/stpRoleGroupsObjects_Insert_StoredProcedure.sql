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
CREATE PROCEDURE [dbo].[stpRoleGroupsObjects_Insert]
	-- PARAMETERS
	
	@RoleGroupId INT,
	@ObjectId NVARCHAR(50),
	@LoggedInUserId NVARCHAR(50)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @ObjectName NVARCHAR(250),
				@RoleGroupName NVARCHAR(50)

		SELECT	@RoleGroupName = [Name]
		FROM	RoleGroups
		WHERE	Id = @RoleGroupId

		SELECT	@ObjectName = ISNULL(ObjectName,'')
		FROM	[Objects]
		WHERE	Id = @ObjectId


		IF(ISNULL(@ObjectId,'') = '')
		BEGIN
			RAISERROR('Must select a user',11,1)
		END
		ELSE IF EXISTS	(
							SELECT	1
							FROM	RoleGroupObjects
							WHERE	ObjectId = @ObjectId
							AND		RoleGroupId = @RoleGroupId
						)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX) = @ObjectName + ' already in role group'
			RAISERROR(@Msg,11,1)
		END
		ELSE
		BEGIN

			INSERT INTO RoleGroupObjects(ObjectId, RoleGroupId)
			VALUES (@ObjectId, @RoleGroupId)

			---------------------------------------
			-------History Log---------------------
			---------------------------------------

			DECLARE @To NVARCHAR(MAX) = 'Object Name: '+ISNULL(@ObjectName,'')
			DECLARE @Des NVARCHAR(MAX) = 'Role Group Objects: '+@ObjectName+' added to Role Group: '+ISNULL(@RoleGroupName,'')

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
