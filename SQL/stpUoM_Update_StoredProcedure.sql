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
CREATE PROCEDURE [dbo].[stpUoM_Update]
	-- PARAMETERS	
	@Id INT,
	@Description NVARCHAR(250),
	@UserId NVARCHAR(50)	
AS
BEGIN
	SET NOCOUNT ON;    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			DECLARE @Description_Old NVARCHAR(250)

			SELECT	@Description_Old = [Description]
			FROM	UoM
			WHERE	Id = @Id

			UPDATE	A
			SET		A.[Description] = @Description
			FROM	UoM A
			WHERE	A.Id = @Id

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @From NVARCHAR(MAX) = 'Description: '+ISNULL(@Description_Old,'')
			DECLARE @To NVARCHAR(MAX) = 'Description: '+ISNULL(@Description,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = 'UoM: UoM updated',
										@FromValue = @From,
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
