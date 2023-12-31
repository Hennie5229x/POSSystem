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
CREATE PROCEDURE [dbo].[stpSalesHistory_Select]	
	
	@ShiftId INT = NULL,
	@DocNum NVARCHAR(50) = NULL,
	@Date DATE = NULL,
	@User NVARCHAR(50) = NULL,
	@Terminal NVARCHAR(50) = NULL

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		A.Id,
				A.DocumentNumber,
				B.[Name] AS [Status],
				C.[Type],
				[Date],
				D.FullName AS [User],
				E.TerminalName,
				A.ShiftId,
				'Items ('+CAST(ISNULL(F.Cnt,0) AS NVARCHAR(10))+')' AS Items,
				TenderedCashTotal,
				TenderedCardTotal,
				TenderedTotal,
				DocumentTotal
	FROM		DocumentTransactionsHeader A
	JOIN		DocumentTransactionsHeaderStatus B ON B.Id = A.DocumentStatusId
	JOIN		DocumentType C ON C.Id = A.DocumentTypeId
	JOIN		viwUsers D ON D.Id = A.UserId
	JOIN		Terminals E ON E.Id = A.TerminalId
	LEFT JOIN	(
					SELECT		HeaderId, COUNT(Id) AS Cnt
					FROM		DocumentTransactionsLines
					WHERE		LineStatus = 1--Open
					GROUP BY	HeaderId
				) F ON F.HeaderId = A.Id
	WHERE		A.DocumentStatusId = 3--Finalized
	AND			A.DocumentTypeId = 1--Sale
	AND			(@ShiftId IS NULL OR A.ShiftId = @ShiftId)
	AND			(@DocNum IS NULL OR A.DocumentNumber LIKE '%'+@DocNum+'%')
	AND			(@Date IS NULL OR CAST(A.[Date] AS DATE) = @Date)
	AND			(@User IS NULL OR D.FullName LIKE '%'+@User+'%')
	AND			(@Terminal IS NULL OR E.TerminalName LIKE '%'+@Terminal+'%')
	ORDER BY	A.Id DESC
			
END
GO
