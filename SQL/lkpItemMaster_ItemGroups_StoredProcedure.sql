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
CREATE PROCEDURE [dbo].[lkpItemMaster_ItemGroups]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT 'All' AS GroupName
	UNION ALL
	SELECT	GroupName
	FROM	ItemGroups
	
		
END
GO
