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
CREATE PROCEDURE [dbo].[stpRoleGroup_Update]
	-- PARAMETERS
	
	@Id INT,
	@UserId NVARCHAR(50),	
	@RoleGroupDescription NVARCHAR(100)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @RoleGroupDescriptionOld NVARCHAR(100)

		SELECT	@RoleGroupDescriptionOld = [Description]
		FROM	RoleGroups
		WHERE	Id = @Id

		UPDATE		RoleGroups
		SET			[Description] = @RoleGroupDescription
		WHERE		Id = @Id

		---------------------------------------
		-------History Log---------------------
		---------------------------------------
		
		DECLARE @To NVARCHAR(MAX) = ''
		DECLARE @From NVARCHAR(MAX) = ''

		IF(ISNULL(@RoleGroupDescription,'') <> ISNULL(@RoleGroupDescriptionOld,''))
		BEGIN
			SET @To = 'Description: '+ISNULL(@RoleGroupDescription,'')
			SET @From = 'Description: '+ISNULL(@RoleGroupDescriptionOld,'')
		END		 

		EXEC stpHistoryLog_Insert	@UserId = @UserId,	
									@Action = 'Update',
									@Description = 'Role Groups: Role Group updated',
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
