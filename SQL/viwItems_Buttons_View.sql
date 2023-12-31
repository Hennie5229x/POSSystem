USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[viwItems_Buttons]  AS


	SELECT		ROW_NUMBER() OVER(ORDER BY ISNULL(B.ButtonText, A.ItemName) ASC) AS RowNum,
				A.ItemGroupId,
				ISNULL(B.ItemId, A.Id) AS ItemId,
				ISNULL(B.ButtonText, A.ItemName) AS ButtonText,
				ISNULL(B.Font, 'Segoe UI') AS Font,
				ISNULL(B.FontSize, 20) AS FontSize,
				ISNULL(B.Hex, '#DDDDDD') AS Hex
	FROM		ItemMaster A
	LEFT JOIN	ItemButtons B ON B.ItemId = A.Id
	WHERE		A.Active = 1

GO
