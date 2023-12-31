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
CREATE PROCEDURE [dbo].[stpHistoryLog_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),	
	@Action NVARCHAR(50),
	@Description NVARCHAR(MAX),
	@FromValue NVARCHAR(MAX),
	@ToValue NVARCHAR(MAX),
	@FieldId NVARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
		
		INSERT INTO HistoryLog ([Datetime], UserId, [Action], [Description], FromValue, ToValue, FieldId)
						VALUES (GETDATE(), @UserId, @Action, @Description, @FromValue, @ToValue, @FieldId)
			
		
			
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
