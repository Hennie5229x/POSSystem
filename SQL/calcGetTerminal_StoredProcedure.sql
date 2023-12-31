USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcGetTerminal]
	
	@TerminalIP NVARCHAR(50)

AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION		
		SET NOCOUNT ON;  
			
			IF NOT EXISTS(SELECT 1 FROM Terminals WHERE Terminal_IP = @TerminalIP)
			BEGIN
				RAISERROR('No Terminal Available',11,1)
			END
			ELSE
			BEGIN
				SELECT	Id, TerminalName, Terminal_IP, PrinterId
				FROM	Terminals
				WHERE	Terminal_IP = @TerminalIP
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
