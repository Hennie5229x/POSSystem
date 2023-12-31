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
CREATE PROCEDURE [dbo].[stpShifts_Select]
	
	@UserName NVARCHAR(50) = '',
	@StartDate DATE = NULL,
	@EndDate DATE = NULL

AS
BEGIN
	
	SET NOCOUNT ON;  
	
	

		SELECT		A.Id,
					C.FullName AS UserName,
					B.[Name] AS ShiftStatus,
					A.StartDate,
					A.EndDate,
					CAST(A.StartFloat AS DECIMAL(19,2)) AS StartFloat,
					CAST(A.CashUpOut AS DECIMAL(19,2)) AS CashUpOut,
					CAST(ISNULL(A.CashUpOut,0) - (ISNULL(A.StartFloat,0) ) AS DECIMAL(19,2)) AS Variance,
					D.[Name] AS CashUpStatus,
					'Sales ('+CAST(ISNULL(E.Cnt,0) AS NVARCHAR(10))+')' AS Sales,
					F.TenderedCardTotal AS SalesCardTotal,
					A.CardMachineTotal AS CashUpCardTotal,
					ISNULL(F.TenderedCardTotal,0) - ISNULL(A.CardMachineTotal,0) AS CardTotalVariance
		FROM		Shifts A
		JOIN		ShiftStatus B ON B.Id = A.ShiftStatusId
		JOIN		viwUsers C ON C.Id = A.UserId
		JOIN		CashUpStatus D ON D.Id = A.CashUpStatus
		LEFT JOIN	(
						SELECT		ShiftId, COUNT(Id) AS Cnt
						FROM		DocumentTransactionsHeader
						WHERE		DocumentStatusId = 3--Finalized
						AND			DocumentTypeId = 1--Sale
						GROUP BY	ShiftId, DocumentStatusId, DocumentTypeId
					) E ON E.ShiftId = A.Id
		LEFT JOIN	(
						SELECT		ShiftId, SUM(TenderedCardTotal) AS TenderedCardTotal
						FROM		DocumentTransactionsHeader
						WHERE		DocumentStatusId = 3--Finalized
						AND			DocumentTypeId = 1--Sale
						GROUP BY	ShiftId
					) F ON F.ShiftId = A.Id
		WHERE		(ISNULL(C.FullName,'') LIKE '%'+@UserName+'%')
		AND			(@StartDate IS NULL OR CAST(A.StartDate AS DATE) = @StartDate)
		AND			(@EndDate IS NULL OR CAST(A.EndDate AS DATE) = @EndDate)
		ORDER BY	ShiftStatusId ASC
		
		
		
END
GO
