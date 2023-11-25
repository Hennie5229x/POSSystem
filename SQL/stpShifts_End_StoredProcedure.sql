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
CREATE PROCEDURE [dbo].[stpShifts_End]
	-- PARAMETERS
		@Id INT	
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF NOT EXISTS	(
								SELECT	1
								FROM	CashUp
								WHERE	ShiftId = @Id
								AND		StatusId = 1 --InComplete
							)
			BEGIN
				RAISERROR('Please complete Cash Up first.',11,1)
			END
			ELSE IF EXISTS	(
								SELECT	1
								FROM	DocumentTransactionsHeader
								WHERE	ShiftId = @Id
								AND		DocumentTypeId = 1 --Sale
								AND		(
											DocumentStatusId = 1 --Open
										OR	DocumentStatusId = 2 --Suspended
										)
							)
			BEGIN
				RAISERROR('Please complete the Open / Suspended Sale(s)',11,1)				
			END
			ELSE
			BEGIN
				UPDATE	Shifts
				SET		ShiftStatusId = 2, --Closed
						EndDate = GETDATE()
				WHERE	Id = @Id
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
