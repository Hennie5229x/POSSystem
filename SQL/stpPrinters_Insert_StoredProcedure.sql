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
CREATE PROCEDURE [dbo].[stpPrinters_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@PrinterName NVARCHAR(50),
	@PrinterDescription NVARCHAR(100)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF EXISTS(SELECT 1 FROM Printers WHERE PrinterName = @PrinterName)
			BEGIN
				RAISERROR('Printer already exists',11,1)
			END
			ELSE
			BEGIN		

				DECLARE @Id INT

				INSERT INTO Printers(PrinterName, PrinterDescription)
							  VALUES(@PrinterName, @PrinterDescription)
				
				SET @Id = SCOPE_IDENTITY()

				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @To NVARCHAR(MAX) = 'Name: '+ISNULL(@PrinterName,'')+', Description: '+ISNULL(@PrinterDescription,'')

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Insert',
											@Description = 'Printers: New Printer created',
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
