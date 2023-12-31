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
CREATE PROCEDURE [dbo].[stpDenomiations_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@Name NVARCHAR(50),
	@Value DECIMAL(19,6),
	@TypeId INT	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF EXISTS	(
						SELECT	1
						FROM	Denominations
						WHERE	[Name] = @Name
					)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX) = ISNULL(@Name,'') + ' already exists.'
			RAISERROR(@Msg,11,1)
		END
		ELSE
		BEGIN

			DECLARE @Id INT

			INSERT INTO Denominations([Name], [Value], TypeId)
			VALUES(@Name, @Value, @TypeId)
			SET @Id = SCOPE_IDENTITY()

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = 'Name: '+ISNULL(@Name,'')+', Value: '+ISNULL(CAST(@Value AS NVARCHAR(50)),'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = 'Denominations: New Denomination created',
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
