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
CREATE PROCEDURE [dbo].[lkpObjects]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	Id,
			ObjectName AS [Name]
	FROM	[Objects]
	
	
		
END
GO
