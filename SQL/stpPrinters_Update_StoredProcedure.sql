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
CREATE PROCEDURE [dbo].[stpPrinters_Update]
	-- PARAMETERS
	
	@Id INT,	
	@PrinterDescription NVARCHAR(100),
	@UserId NVARCHAR(50)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			DECLARE @Old_PrinterDescription NVARCHAR(100)
			SELECT	@Old_PrinterDescription = PrinterDescription
			FROM	Printers
			WHERE	Id = @Id

			UPDATE	Printers
			SET		PrinterDescription = @PrinterDescription
			WHERE	Id = @Id


			IF(ISNULL(@PrinterDescription,'') <> ISNULL(@Old_PrinterDescription,''))
			BEGIN			
				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @From NVARCHAR(MAX) = 'Description: '+ISNULL(@Old_PrinterDescription,'')
				DECLARE @To NVARCHAR(MAX) = 'Description: '+ISNULL(@PrinterDescription,'')

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Update',
											@Description = 'Printers: Printer Description changed',
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
