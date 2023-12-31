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
CREATE PROCEDURE [dbo].[stpStockTake_Select]
	
	@DateFrom DATE = NULL,
	@DateTo DATE = NULL

AS
BEGIN
	
	SET NOCOUNT ON;  

	IF(@DateFrom IS NULL OR @DateTo IS NULL)
	BEGIN
		SELECT	A.Id,
				A.[Date],				
				B.FullName
		FROM	StockTake A
		JOIN	viwUsers B ON B.Id = A.UserId
	END
	ELSE
	BEGIN
		SELECT	A.Id,
				A.[Date],				
				B.FullName
		FROM	StockTake A
		JOIN	viwUsers B ON B.Id = A.UserId
		WHERE	@DateFrom <= CAST(A.[Date] AS DATE) AND @DateTo >= CAST(A.[Date] AS DATE)
		--WHERE	CAST(A.[Date] AS DATE) BETWEEN @DateFrom AND @DateTo
	END
		
END
GO
