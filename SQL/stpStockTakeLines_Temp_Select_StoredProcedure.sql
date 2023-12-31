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
CREATE PROCEDURE [dbo].[stpStockTakeLines_Temp_Select]
		@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT		A.Id,
				C.GroupName,
				B.ItemName,
				A.Quantity,
				Variance,
				D.UoM
	FROM		StockTakeLines_Temp A
	JOIN		ItemMaster B ON B.Id = A.ItemId
	JOIN		ItemGroups C ON C.Id = B.ItemGroupId
	JOIN		UoM D ON D.Id = B.UoMId
	WHERE		B.ItemGroupId = @Id
	ORDER BY	B.ItemName

	

	
		
END
GO
