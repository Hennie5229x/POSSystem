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
CREATE PROCEDURE [dbo].[stpPOS_Doc_TransactionLines]
	@Id INT		
AS
BEGIN	
	SET NOCOUNT ON;  

	/*
	SELECT 1 AS Id, 'Olof Bergh' AS Item, 2 AS Qty, 49.99 AS UnitPrice, 99.98 AS Total
	*/

	/*Open*/
	SELECT		A.Id,
				B.ItemName AS Item,
				FORMAT(ROUND(A.Quantity,3),'N3') AS Qty,
				FORMAT(A.PriceUnitVatIncl,'N2') UnitPrice,
				FORMAT(A.LineTotal,'N2') AS Total,
				A.HeaderId, 
				A.ItemId,
				A.LineStatus				
	FROM        DocumentTransactionsLines A
	JOIN		ItemMaster B ON B.Id = A.ItemId
	WHERE		HeaderId = @Id
	AND			A.LineStatus = 1 --Open Lines
	
	


END
GO
