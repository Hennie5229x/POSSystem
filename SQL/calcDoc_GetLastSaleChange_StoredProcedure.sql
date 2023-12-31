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
CREATE PROCEDURE [dbo].[calcDoc_GetLastSaleChange]
	
	@UserId NVARCHAR(50),
	@TerminalId INT
	
AS
BEGIN
	
	SET NOCOUNT ON;  		
		
		DECLARE @DocId INT = NULL

		DECLARE @T TABLE ([Value] INT)
		INSERT INTO @T
		EXEC stpPOS_DocId_Selection @UserId, @TerminalId

		IF((SELECT [Value] FROM @T) <> 0)
		BEGIN
			SELECT	@DocId = [Value]
			FROM	@T
		END
		ELSE
		BEGIN
			SELECT		TOP 1 @DocId = Id
			FROM		DocumentTransactionsHeader
			WHERE		UserId = @UserId 
			AND			TerminalId = @TerminalId
			AND			DocumentStatusId = 3 --Finalized
			ORDER BY	Id DESC
		END			


		DECLARE @Currency NVARCHAR(10)
		SELECT	@Currency = CurrencySign
		FROM	CompanyInformation

		IF(@DocId IS NOT NULL)
		BEGIN
			SELECT	@Currency + FORMAT(ROUND(CASE 
					WHEN (ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) > 0
					THEN CEILING((ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) * 10) / 10 --Round up to nearst 10 cent
					ELSE 0.0
					END,1),'N2') AS Change
			FROM	DocumentTransactionsHeader		
			WHERE	Id = @DocId
		END
		ELSE
		BEGIN
			SELECT '' AS Change
		END


END
GO
