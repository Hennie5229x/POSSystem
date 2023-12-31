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
CREATE PROCEDURE [dbo].[stpUoM_Insert]
	-- PARAMETERS	
	@UserId NVARCHAR(50),
	@UoM NVARCHAR(50),
	@Description NVARCHAR(250)	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF EXISTS	(
						SELECT	1
						FROM	UoM
						WHERE	UoM = @UoM
					)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX) = ISNULL(@UoM,'') + ' already exists.'
			RAISERROR(@Msg,11,1)
		END
		ELSE
		BEGIN

			DECLARE @Id INT

			INSERT INTO UoM(UoM, [Description])
			VALUES(@UoM, @Description)
			SET @Id = SCOPE_IDENTITY()

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = 'UoM: '+ISNULL(@UoM,'')+', Description: '+ISNULL(@Description,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = 'UoM: UoM created',
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
