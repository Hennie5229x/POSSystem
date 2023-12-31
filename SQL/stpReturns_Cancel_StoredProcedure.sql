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
CREATE PROCEDURE [dbo].[stpReturns_Cancel]
	-- PARAMETERS	
	
	@ReturnType NVARCHAR(50), --LINKED/UNLINKED	
	@OrignalDocId INT,	
	@UnlinkedHeaderId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF(@ReturnType = 'LINKED' AND ISNULL(@OrignalDocId, 0) > 0)
			BEGIN
				DELETE
				FROM	[Returns]
				WHERE	OriginalDocId = @OrignalDocId
			END
			ELSE IF(@ReturnType = 'UNLINKED' AND ISNULL(@UnlinkedHeaderId,0) > 0)
			BEGIN
				DELETE
				FROM	[Returns]
				WHERE	UnlinkedHeaderId = @UnlinkedHeaderId
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
