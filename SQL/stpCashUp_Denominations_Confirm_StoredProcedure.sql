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
CREATE PROCEDURE [dbo].[stpCashUp_Denominations_Confirm]
	-- PARAMETERS
	
	@ShiftId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @HeaderId INT

			SELECT	@HeaderId = Id
			FROM	CashUp A
			WHERE	ShiftId = @ShiftId

			IF EXISTS	(
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
			ELSE
			IF NOT EXISTS	(
								SELECT	1
								FROM	CashUpLines
								WHERE	HeaderId = @HeaderId
							)
			BEGIN
				RAISERROR('Please create and update the denominations first.', 11, 1)
			END
			ELSE
			BEGIN
				UPDATE	CashUp
				SET		StatusId =  1 --Completed
				WHERE	ShiftId = @ShiftId
				
				DECLARE @CashUpTotal DECIMAL(19,6) = 0
				SELECT	@CashUpTotal = SUM(A.DenominationCount * B.Value)
				FROM	CashUpLines A
				JOIN	Denominations B ON B.Id = A.DenominationId
				WHERE	HeaderId = @HeaderId

				UPDATE	Shifts
				SET		CashUpStatus = 1, --Completed
						CashUpOut = @CashUpTotal
				WHERE	Id = @ShiftId

				
				
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
