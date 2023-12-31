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
CREATE PROCEDURE [dbo].[stpTerminals_Update]
	-- PARAMETERS
	
	@Id INT,	
	@UserId NVARCHAR(50),
	@TerminalName NVARCHAR(50),
	@TerminalIP NVARCHAR(50),
	@PrinterId INT	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			

			DECLARE @Old_TerminalName NVARCHAR(50)					

			SELECT	@Old_TerminalName = TerminalName
			FROM	Terminals A			
			WHERE	A.Id = @Id

			UPDATE	Terminals
			SET		TerminalName = @TerminalName,
					Terminal_IP = @TerminalIP,
					PrinterId = @PrinterId
			WHERE	Id = @Id


			IF(ISNULL(@TerminalName,'') <> ISNULL(@Old_TerminalName,''))
			BEGIN			
				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @From NVARCHAR(MAX) = 'Terminal Name: '+ISNULL(@Old_TerminalName,'')
				DECLARE @To NVARCHAR(MAX) = 'Terminal Name: '+ISNULL(@TerminalName,'')

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Update',
											@Description = 'Terminals: Terminal Name changed',
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
