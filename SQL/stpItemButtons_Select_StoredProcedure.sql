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
CREATE PROCEDURE [dbo].[stpItemButtons_Select]

	@GroupId INT,
	@RowNum INT = 0

AS
BEGIN	
	SET NOCOUNT ON;  

	IF(@RowNum = 0)
	BEGIN
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
		AND			ItemGroupId = @GroupId	
	END
	ELSE
	BEGIN
		SELECT	RowNum, ItemGroupId, ItemId, ButtonText, Font, FontSize, Hex
		FROM	(
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
					AND			ItemGroupId = @GroupId
				) A
		WHERE	RowNum = @RowNum
	END
		
END
GO
