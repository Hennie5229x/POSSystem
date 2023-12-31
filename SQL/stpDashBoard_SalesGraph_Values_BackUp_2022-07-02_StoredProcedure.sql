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
CREATE PROCEDURE [dbo].[stpDashBoard_SalesGraph_Values_BackUp_2022-07-02]
	-- PARAMETERS
	@Options INT, -- 1: Last 7 Days; 2: Last 30 Days; 3: Custom Date Range
	@DateFrom DATE,
	@DateTo DATE
		
AS
BEGIN
	SET NOCOUNT ON; 
	

		DECLARE @GraphMaxPoints INT = 15
		DECLARE @Table TABLE (SalesTotal DECIMAL(19,2), [Date] DATE)
		DECLARE @GraphData TABLE (SalesTotal DECIMAL(19,2), [Date] DATE)
		DECLARE @AmountOfRows INT = 90

		DECLARE @Count INT = @AmountOfRows	
		WHILE(@Count > 0)
		BEGIN
			INSERT INTO @Table
			SELECT CAST(RAND()*(50000-10000)+10000 AS DECIMAL(19,2)), GETDATE()-@Count

			SET @Count -= 1
		END

		/*
		/*
		TEST TABLE
		*/
		DELETE FROM @Table

		INSERT INTO @Table
		SELECT * FROM TestTable

		/*------*/
		*/

		DECLARE @Modules INT

		SELECT	@Modules = FLOOR(COUNT([Date]) / @GraphMaxPoints)
		FROM	@Table

		
		SET @Count = @AmountOfRows
		WHILE(@Count > 0)
		BEGIN
			INSERT INTO @GraphData
			SELECT	SalesTotal, [Date]
			FROM	(
						SELECT	ROW_NUMBER() OVER(ORDER BY [Date] DESC) AS RowNum, SalesTotal, [Date] 
						FROM	@Table
						--WHERE	[Date] >= GETDATE()-30
					) A
			WHERE RowNum = @Count

			SET @Count -= @Modules
		END

		DECLARE @Min INT,
				@Max INT

		DECLARE @TotalMIN DECIMAL(19,2),
				@TotalMAX DECIMAL(19,6)
			

		SELECT	@Max = CAST(MAX(SalesTotal) AS INT),
				@Min = CAST(MIN(SalesTotal) AS INT)
		FROM	@GraphData

		
		--MAX
		IF(LEN(@Max) = 2)--Tens
		BEGIN
			SET @TotalMAX = CEILING(@Max / 10.0) * 10.0;
		END
		ELSE IF(LEN(@Max) = 3)--Hunderds
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 100.0) * 100.0;
		END
		ELSE IF(LEN(@Max) = 4)--Thousands
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 1000.0) * 1000.0;
		END
		ELSE IF(LEN(@Max) = 5)--Ten Thousands
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 10000.0) * 10000.0;
		END
		ELSE IF(LEN(@Max) = 6)--Hunder Thousands
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 100000.0) * 100000.0;
		END
		ELSE IF(LEN(@Max) = 7)--Millions
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 1000000.0) * 1000000.0;
		END 
		--MIN
		IF(LEN(@Min) = 2)--Tens
		BEGIN
			SET @TotalMIN = FLOOR(@Min / 10.0) * 10.0;
		END
		ELSE IF(LEN(@Min) = 3)--Hunderds
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 100.0) * 100.0;
		END
		ELSE IF(LEN(@Min) = 4)--Thousands
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 1000.0) * 1000.0;
		END
		ELSE IF(LEN(@Min) = 5)--Ten Thousands
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 10000.0) * 10000.0;
		END
		ELSE IF(LEN(@Min) = 6)--Hunder Thousands
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 100000.0) * 100000.0;
		END
		ELSE IF(LEN(@Min) = 7)--Millions
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 1000000.0) * 1000000.0;
		END	   	

		SELECT		CAST(@TotalMIN AS INT) AS TotalMIN, 
					CAST(@TotalMAX AS INT) AS TotalMAX,
					CAST(((@TotalMAX - @TotalMIN) / 10) AS INT) AS Interval, --10 Marks on Y axis
					SalesTotal, 
					CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		@GraphData	
		ORDER BY	[Date] ASC

		/*
		SELECT		SalesTotal, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		@GraphData
		ORDER BY	[Date] ASC
		*/



	/*
	--SET @DateFrom = '2021-01-01'
	--SET @DateTo = '2021-09-29'	
	
	IF(@Options = 1) --This Week
	BEGIN
		SELECT		COUNT(Id) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		DocumentTransactionsHeader
		WHERE		DocumentStatusId = 3 --Finalized
		AND			DATEPART(WEEK, CAST([Date] AS Date)) = DATEPART(WW, GETDATE())
		AND			DATEPART(YEAR,CAST([Date] AS Date)) = DATEPART(YEAR,GETDATE())
		GROUP BY	CAST([Date] AS Date)
		ORDER BY	CAST([Date] AS Date) ASC
	END
	ELSE IF(@Options = 2) --This Month
	BEGIN
		SELECT		COUNT(Id) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		DocumentTransactionsHeader
		WHERE		DocumentStatusId = 3 --Finalized
		AND			DATEPART(M, CAST([Date] AS Date)) = DATEPART(M, GETDATE())
		AND			DATEPART(YEAR,CAST([Date] AS Date)) = DATEPART(YEAR,GETDATE())
		GROUP BY	CAST([Date] AS Date)
		ORDER BY	CAST([Date] AS Date) ASC
	END
	ELSE
	BEGIN --Custom
		SELECT		COUNT(Id) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]				
		FROM		DocumentTransactionsHeader
		WHERE		DocumentStatusId = 3 --Finalized
		AND			CAST([Date] AS Date) BETWEEN @DateFrom AND @DateTo
		GROUP BY	CAST([Date] AS Date)
		ORDER BY	CAST([Date] AS Date) ASC
	END

	*/


END
GO
