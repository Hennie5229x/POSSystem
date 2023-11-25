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
CREATE PROCEDURE [dbo].[stpItemGroupButtons_Select]
	
	@RowNum INT = 0
AS
BEGIN	
	SET NOCOUNT ON;  

	IF(@RowNum = 0)
	BEGIN
		SELECT	RowNum,
				Id,
				GroupName
		FROM	viwItemGroups_Buttons
	END
	ELSE
	BEGIN
		SELECT	RowNum,
				Id,
				GroupName
		FROM	viwItemGroups_Buttons
		WHERE	RowNum = @RowNum
	END
		
END
GO
