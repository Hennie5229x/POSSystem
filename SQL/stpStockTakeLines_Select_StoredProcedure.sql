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
CREATE PROCEDURE [dbo].[stpStockTakeLines_Select]
	
	@HeaderId INT

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	A.HeaderId,
			B.GroupName,
			C.ItemName,
			A.Quantity,
			A.Variance,
			D.UoM
	FROM	StockTakeLines A
	JOIN	ItemGroups B ON B.Id = A.ItemGroupId
	JOIN	ItemMaster C ON C.Id = A.ItemId
	JOIN	UoM D ON D.Id = C.UoMId
	WHERE	A.HeaderId = @HeaderId
		
END
GO
