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
CREATE PROCEDURE [dbo].[stpItemGroups_Delete]
	-- PARAMETERS	
	@Id INT,
	@UserId NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF EXISTS	(
							SELECT	1
							FROM	ItemMaster
							WHERE	ItemGroupId = @Id
						)
			BEGIN
				RAISERROR('Cannot remove Group because it is in use',11,1)
			END
			ELSE
			BEGIN
				DECLARE @GroupName NVARCHAR(50)

				SELECT	@GroupName = GroupName
				FROM	ItemGroups
				WHERE	Id = @Id

				

				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @From NVARCHAR(MAX) = 'Group Name: '+ISNULL(@GroupName,'')			

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Delete',
											@Description = 'Item Groups: Item Group removed',
											@FromValue = @From,
											@ToValue = '',
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
