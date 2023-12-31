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
CREATE PROCEDURE [dbo].[stpPOS_PAY_Values]
	-- PARAMETERS

	@DocId INT
	
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION			
		
		DECLARE @Currency NVARCHAR(10)
		SELECT	@Currency = CurrencySign
		FROM	CompanyInformation

		SELECT	@Currency + FORMAT(ROUND(ISNULL(DocumentTotal,0),2),'N2') AS SalesTotal,
				@Currency + FORMAT(ROUND(CASE WHEN ISNULL(DocumentTotal,0) - ISNULL(TenderedCashTotal,0)+ISNULL(TenderedCardTotal,0) > 0 
				THEN (ISNULL(DocumentTotal,0) - (ISNULL(TenderedCashTotal,0)+ISNULL(TenderedCardTotal,0))) 
				ELSE 0.0 
				END,2),'N2') AS AmountDue,
				@Currency + FORMAT(ROUND(ISNULL(TenderedCashTotal,0),2),'N2') AS CashTendered,
				@Currency + FORMAT(ROUND(ISNULL(TenderedCardTotal,0),2),'N2') AS CardTendered,
				@Currency + FORMAT(ROUND(CASE 
				WHEN (ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) > 0
				THEN CEILING((ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) * 10) / 10 --Round up to nearst 10 cent
				ELSE 0.0
				END,1),'N2') AS Change,
				CAST(ROUND(CASE WHEN ISNULL(DocumentTotal,0) - ISNULL(TenderedCashTotal,0)+ISNULL(TenderedCardTotal,0) > 0 
				THEN (ISNULL(DocumentTotal,0) - (ISNULL(TenderedCashTotal,0)+ISNULL(TenderedCardTotal,0))) 
				ELSE 0.0 END,2) AS DECIMAL(19,2)) AS DocumentTotal
				--CAST(ROUND(DocumentTotal, 2) AS DECIMAL(19,2)) AS DocumentTotal
		FROM	DocumentTransactionsHeader
		WHERE	DocumentStatusId = 1 --Open
		AND		Id = @DocId

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		-- Raise an error with the details of the exception
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		SET @ErrMsg = ERROR_MESSAGE()
		SET @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1) 
	END CATCH 
END
GO
