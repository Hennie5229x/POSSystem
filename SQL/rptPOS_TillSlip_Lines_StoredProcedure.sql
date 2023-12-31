USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[rptPOS_TillSlip_Lines]
	-- PARAMETERS
	@DocId INT	
AS
BEGIN
	SET NOCOUNT ON; 
		
	SELECT		B.ItemName,
				FORMAT(CAST(Quantity AS DECIMAL(19,2)), 'N2') AS Quantity,
				FORMAT(ROUND(ISNULL(A.PriceUnitVatIncl,0),2),'N2') AS UnitPrice,
				FORMAT(ROUND(ISNULL(A.LineTotal,0),2),'N2') AS LineTotal
	FROM		DocumentTransactionsLines A
	JOIN		ItemMaster B ON B.Id = A.ItemId
	CROSS JOIN	CompanyInformation C
	WHERE		A.HeaderId = @DocId
	AND			A.LineStatus = 1
		
END
GO
