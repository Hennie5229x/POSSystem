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
CREATE PROCEDURE [dbo].[stpRoleGroupsObjects_Delete]
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

			SELECT	@ObjectName = ISNULL([ObjectName],'')
			FROM	Objects
			WHERE	Id = @ObjectId

			DELETE
			FROM	RoleGroupObjects
			WHERE	RoleGroupId = @RoleGroupId
			AND		ObjectId = @ObjectId

			---------------------------------------
			-------History Log---------------------
			---------------------------------------

			DECLARE @Fr NVARCHAR(MAX) = 'Object Name: '+ISNULL(@ObjectName,'')
			DECLARE @Des NVARCHAR(MAX) = 'Role Group Objects: '+@ObjectName+' removed from Role Group: '+ISNULL(@RoleGroupName,'')

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
