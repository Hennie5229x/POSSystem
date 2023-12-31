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
CREATE FUNCTION [dbo].[fnItemMasterCompoundQuantity]
(	
	@ItemMasterId INT
)

RETURNS
@Table TABLE 
(
	ItemMasterId INT, 
	ItemCode NVARCHAR(50), 
	ItemName NVARCHAR(50),
	ItemIdCompound INT,
	ItemCodeCompound NVARCHAR(50), 
	ItemNameCompound NVARCHAR(50), 
	CompoundQty DECIMAL(19, 6)
)
AS
BEGIN 
	
	DECLARE @Items TABLE	(
								ItemCode NVARCHAR(50), 
								BaseCode NVARCHAR(50), 
								CompoundQty DECIMAL(19,6)
							)
	
	;WITH
	  cte (ItemId, Qty, [Level], CompoundQty, BaseItem)
	  AS
	  (
		SELECT  Id, QuantityAvailable, 1, CAST(1.00 AS DECIMAL(19,6)), Id
		FROM	ItemMaster    
		UNION ALL
		SELECT	A.HeaderId, A.Quantity, Level + 1, CAST(A.Quantity * B.CompoundQty AS DECIMAL(19,6)), B.BaseItem
		FROM	ItemMasterCompounds A
		JOIN	cte B ON B.ItemId = A.ItemMasterItemId
	  )
	
	INSERT INTO @Items
	SELECT	ItemId, BaseItem, CompoundQty
	FROM	cte
	WHERE	BaseItem NOT IN (SELECT HeaderId FROM ItemMasterCompounds)
	
	INSERT INTO @Table
	SELECT		B.Id AS ItemMasterId, B.ItemCode, B.ItemName, C.Id, C.ItemCode, C.ItemName, A.CompoundQty
	FROM		@Items A
	JOIN		ItemMaster B ON B.Id = A.ItemCode
	JOIN		ItemMaster C ON C.Id = A.BaseCode
	WHERE		A.ItemCode = @ItemMasterId
	ORDER BY	B.Id

	RETURN
END

GO
