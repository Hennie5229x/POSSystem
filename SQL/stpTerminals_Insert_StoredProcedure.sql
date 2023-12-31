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
CREATE PROCEDURE [dbo].[stpTerminals_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@TerminalName NVARCHAR(50),
	@TerminalIP NVARCHAR(50),
	@PrinterId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF EXISTS(SELECT 1 FROM Terminals WHERE TerminalName = @TerminalName)
			BEGIN
				RAISERROR('Terminal already exists',11,1)
			END
			ELSE IF EXISTS(SELECT 1 FROM Terminals WHERE Terminal_IP = @TerminalIP)
			BEGIN
				RAISERROR('Terminal IP already in use',11,1)
			END
			ELSE
			BEGIN		

				DECLARE @Id INT

				INSERT INTO Terminals (TerminalName, Terminal_IP, PrinterId)
				VALUES(@TerminalName, @TerminalIP, @PrinterId)
								
				SET @Id = SCOPE_IDENTITY()

				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @To NVARCHAR(MAX) = 'Name: '+ISNULL(@TerminalName,'')

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Insert',
											@Description = 'Terminals: New Terminal created',
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
