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
CREATE PROCEDURE [dbo].[lkpHistoryLog_Actions]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT 'All' AS [Action]
	UNION ALL
	SELECT	DISTINCT [Action]
	FROM	HistoryLog
	
	
		
END
GO
