USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[viwItemGroups_Buttons]  AS
	
	SELECT	ROW_NUMBER() OVER(ORDER BY GroupName ASC) AS RowNum,
			Id,
			GroupName 
	FROM	ItemGroups
GO
