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
CREATE PROCEDURE [dbo].[rptPOS_TillSlip_Header]
	-- PARAMETERS
	@DocId INT	
AS
BEGIN
	SET NOCOUNT ON; 
		
	SELECT		B.CompanyName,
				B.ShipToAddress,
				CASE WHEN Telephone LIKE '% %' THEN Telephone ELSE STUFF(STUFF(Telephone, 4, 0, ' '), 8, 0, ' ') END AS Telephone,
				B.VATNumber,
				A.DocumentNumber,
				CONVERT(VARCHAR, A.[Date], 23) + ' ' + SUBSTRING(CONVERT(VARCHAR, A.[Date],108),1,5) AS [Date],
				--CONVERT(VARCHAR, A.[Date], 113) AS [Date],
				'TOTAL: ' + B.CurrencySign + FORMAT(ROUND(ISNULL(A.DocumentTotal,0),2),'N2') AS SalesTotal,
				B.CurrencySign + FORMAT(ROUND(ISNULL(A.TenderedCardTotal,0),2),'N2') AS TenderedCardTotal,
				B.CurrencySign + FORMAT(ROUND(ISNULL(A.TenderedCashTotal,0),2),'N2') AS TenderedCashTotal,
				B.CurrencySign + FORMAT(ROUND(CASE 
				WHEN (ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) > 0
				THEN CEILING((ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) * 10) / 10 
				ELSE 0.0
				END,1),'N2') AS Change,			
				C.FullName AS Cashier,
				D.TerminalName,
				FORMAT(E.VAT, 'N2') AS Vat,
				B.CurrencySign + FORMAT(ROUND(ISNULL(E.VatTotal,0),2),'N2') AS VatTotal
	FROM		DocumentTransactionsHeader A
	CROSS JOIN	CompanyInformation B
	JOIN		viwUsers C ON C.Id = A.UserId
	JOIN		Terminals D ON D.Id =A.TerminalId
	JOIN		(
					SELECT		A.HeaderId,							
								SUM(C.VAT/100 * (A.PriceUnitVatIncl * A.Quantity)) AS VatTotal,
								C.VAT
					FROM		DocumentTransactionsLines A
					JOIN		ItemMaster B ON B.Id = A.ItemId
					JOIN		TaxCodes C ON C.Id = B.TaxCode
					WHERE		A.LineStatus = 1--Open
					AND			C.Id = 2--Tax					
					GROUP BY	A.HeaderId, C.VAT
				) E ON E.HeaderId = A.Id
	WHERE		A.Id = @DocId


		
END
GO
