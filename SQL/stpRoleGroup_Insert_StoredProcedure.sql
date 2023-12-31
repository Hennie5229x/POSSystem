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
CREATE PROCEDURE [dbo].[stpRoleGroup_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@RoleGroupName NVARCHAR(50),
	@RoleGroupDescription NVARCHAR(100)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @Id INT

		INSERT INTO RoleGroups ([Name], [Description])
		VALUES(@RoleGroupName, @RoleGroupDescription)
		SET @Id = SCOPE_IDENTITY()

		---------------------------------------
		-------History Log---------------------
		---------------------------------------
		DECLARE @To NVARCHAR(MAX) = 'Name: '+ISNULL(@RoleGroupName,'')+', Description: '+ISNULL(@RoleGroupDescription,'')

		EXEC stpHistoryLog_Insert	@UserId = @UserId,	
									@Action = 'Insert',
									@Description = 'Role Groups: New Role Group created',
									@FromValue = '',
									@ToValue = @To,
									@FieldId = @Id
		
			
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
