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
CREATE PROCEDURE [dbo].[stpStockTake_Temp_Select]
		
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT		B.Id,
				B.GroupName,
				CASE WHEN D.Id IS NULL THEN 'Completed' ELSE 'Incomplete' END AS Status
	FROM		StockTake_Temp A
	JOIN		ItemGroups B ON B.Id = A.ItemGroupId
	JOIN		StockTakeLines_Temp C ON C.ItemId = B.Id
	LEFT JOIN	(
					SELECT	DISTINCT D.Id							
					FROM	StockTakeLines_Temp A
					JOIN	ItemMaster B ON B.Id = A.ItemId
					JOIN	ItemGroups C ON C.Id = B.ItemGroupId
					JOIN	StockTake_Temp D ON D.ItemGroupId = C.Id
					WHERE	A.Quantity IS NULL
				) D ON D.Id = A.Id


	--SELECT		B.Id,
	--			B.GroupName
	--FROM		StockTake_Temp A
	--JOIN		ItemGroups B ON B.Id = A.ItemGroupId
	--JOIN		StockTakeLines_Temp C ON C.ItemId = B.Id
	----LEFT JOIN	ItemMaster D ON D.ItemGroupId = A.ItemGroupId
	----LEFT JOIN	ItemMaster E ON E.ItemGroupId = A.ItemGroupId
		
END
GO
