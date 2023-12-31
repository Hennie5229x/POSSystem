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
CREATE PROCEDURE [dbo].[stpShifts_Insert]
	-- PARAMETERS
		@UserId NVARCHAR(50),
		@StartFloat DECIMAL(19,2)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF EXISTS	(
							SELECT	1
							FROM	Shifts
							WHERE	UserId = @UserId
							AND		ShiftStatusId = 1--Open
						)
			BEGIN
				DECLARE @UserName NVARCHAR(50)
				SELECT	@UserName = B.FullName
				FROM	Shifts A
				JOIN	viwUsers B ON B.Id = A.UserId
				WHERE	UserId = @UserId
				AND		ShiftStatusId = 1--Open
				
				DECLARE @Msg NVARCHAR(MAX) = 'An open shift for '+@UserName+' already exists.'

				RAISERROR(@Msg,11,1)
			END
			ELSE
			BEGIN
				INSERT INTO Shifts(UserId, ShiftStatusId, StartDate, StartFloat, CashUpStatus)
				VALUES(@UserId, 1, GETDATE(), @StartFloat, 2)
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
