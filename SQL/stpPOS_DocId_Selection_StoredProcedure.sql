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
CREATE PROCEDURE [dbo].[stpPOS_DocId_Selection]
	-- PARAMETERS
	@UserId NVARCHAR(50),
	@TerminalId INT
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION			
		
		/*
			Document Selection
		*/
		
		DECLARE @DocId INT = NULL

		SELECT	@DocId = A.Id
		FROM	DocumentTransactionsHeader A
		JOIN	Shifts B ON B.Id = A.ShiftId		
		WHERE	A.DocumentStatusId = 1 --Open
		AND		B.UserId = @UserId
		AND		B.ShiftStatusId = 1 -- Open
		AND		B.CashUpStatus = 2 --Incomplete
		AND		A.TerminalId = @TerminalId		

		
		SELECT ISNULL(@DocId,0) AS Id

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
