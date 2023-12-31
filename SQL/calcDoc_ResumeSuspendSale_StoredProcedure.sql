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
CREATE PROCEDURE [dbo].[calcDoc_ResumeSuspendSale]
	
	@UserId NVARCHAR(50),
	@TerminalId INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	IF EXISTS	(
					SELECT	1
					FROM	DocumentTransactionsHeader
					WHERE	UserId = @UserId
					AND		TerminalId = @TerminalId
					AND		DocumentStatusId = 2--Suspended
				)
	BEGIN
		SELECT 'Resume Sale' AS [Type]
	END
	ELSE
	BEGIN
		SELECT 'Suspend Sale' AS [Type]
	END


END
GO
