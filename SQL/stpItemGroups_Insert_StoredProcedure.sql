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
CREATE PROCEDURE [dbo].[stpItemGroups_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@GroupName NVARCHAR(50),
	@Description NVARCHAR(250)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF EXISTS	(
						SELECT	1
						FROM	ItemGroups
						WHERE	GroupName = @GroupName
					)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX) = ISNULL(@GroupName,'') + ' already exists.'
			RAISERROR(@Msg,11,1)
		END
		ELSE
		BEGIN

			DECLARE @Id INT

			INSERT INTO ItemGroups(GroupName, [Description])
			VALUES(@GroupName, @Description)
			SET @Id = SCOPE_IDENTITY()

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = 'Name: '+ISNULL(@GroupName,'')+', Description: '+ISNULL(@Description,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = 'Item Groups: New Item Group created',
										@FromValue = '',
										@ToValue = @To,
										@FieldId = @Id
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
