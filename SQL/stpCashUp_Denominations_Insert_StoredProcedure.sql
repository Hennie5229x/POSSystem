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
CREATE PROCEDURE [dbo].[stpCashUp_Denominations_Insert]
	-- PARAMETERS
	
	@ShiftId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION

			
			IF NOT EXISTS (SELECT 1 FROM Denominations)
			BEGIN
				RAISERROR('Cannot Cash Up, because the Denominations are not set up.',11,1)
			END
			ELSE IF EXISTS	(
								SELECT	1
								FROM	DocumentTransactionsHeader
								WHERE	ShiftId = @ShiftId
								AND		DocumentTypeId = 1 --Sale
								AND		(
											DocumentStatusId = 1 --Open
										OR	DocumentStatusId = 2 --Suspended
										)
							)
			BEGIN
				RAISERROR('Please complete the Open / Suspended Sale(s)',11,1)				
			END
			ELSE IF NOT EXISTS (
									SELECT	1
									FROM	CashUp
									WHERE	ShiftId = @ShiftId
								)
			BEGIN
				DECLARE @Id INT

				INSERT INTO CashUp ([Date], StatusId, ShiftId)
				VALUES (GETDATE(), 2, @ShiftId) --StatusId: 2 - Incomplete
				SET @Id = SCOPE_IDENTITY()

				INSERT INTO CashUpLines(HeaderId, DenominationId, DenominationCount)
				SELECT	@Id,
						Id,
						0
				FROM	Denominations
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
