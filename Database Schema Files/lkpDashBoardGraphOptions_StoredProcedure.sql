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
CREATE PROCEDURE [dbo].[lkpDashBoardGraphOptions]
	
	

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT 1 AS Id, 'Last 7 Days' AS [Option]
	UNION ALL
	SELECT 2 AS Id, 'Last 30 Days' AS [Option]
	UNION ALL
	SELECT 3 AS Id, 'Custom (Any Date Range)' AS [Option]
	

	

	
		
END
GO
