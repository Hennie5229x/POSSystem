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
CREATE PROCEDURE [dbo].[stpStockTake_Temp_CreateHeader]
	
	@UserId NVARCHAR(50)

AS
BEGIN
	
	SET NOCOUNT ON;  

	IF NOT EXISTS(SELECT 1 FROM StockTake_Temp)
	BEGIN
		INSERT INTO StockTake_Temp(ItemGroupId, UserId)
		SELECT	A.Id, @UserId
		FROM	ItemGroups A
		WHERE	A.Id IN (SELECT ItemGroupId FROM ItemMaster)

		INSERT INTO StockTakeLines_Temp(ItemId, Quantity)
		SELECT Id, NULL AS Qty FROM ItemMaster
	END	
	
END
GO
