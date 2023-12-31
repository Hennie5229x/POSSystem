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
CREATE PROCEDURE [dbo].[stpPrinters_Delete]
	-- PARAMETERS
	
	@Id INT,
	@UserId NVARCHAR(50)	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF EXISTS(SELECT 1 FROM Terminals WHERE PrinterId = @Id)
			BEGIN
				RAISERROR('Printer in use at a terminal',11,1)
			END
			ELSE
			BEGIN
				
				DECLARE @PrinterName NVARCHAR(50)
				SELECT	@PrinterName = PrinterName
				FROM	Printers
				WHERE	Id = @Id

				DELETE 
				FROM	Printers
				WHERE	Id = @Id
					
				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @From NVARCHAR(MAX) = 'Printer Name: '+ISNULL(@PrinterName,'')
				DECLARE @To NVARCHAR(MAX) = ''

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Insert',
											@Description = 'Printers: Printer Deleted',
											@FromValue = @From,
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
