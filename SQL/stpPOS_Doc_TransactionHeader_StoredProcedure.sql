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
CREATE PROCEDURE [dbo].[stpPOS_Doc_TransactionHeader]
	@Id INT	
AS
BEGIN	
	SET NOCOUNT ON;  

	/*Open*/
	SELECT		Id,
				DocumentNumber, 
				DocumentStatusId, 
				[Date], 
				UserId, 
				ShiftId, 
				TerminalId, 
				TenderedCashTotal, 
				TenderedCardTotal, 
				TenderedTotal,
				ISNULL(DocumentTotal,0.0),
				(SELECT ISNULL(CurrencySign,'') FROM CompanyInformation) +''+ FORMAT(ROUND(ISNULL(DocumentTotal,0.0),2),'N2') AS DocumentTotal_Formatted
	FROM        DocumentTransactionsHeader
	WHERE       Id = @Id
	--DocumentStatusId = 1

	
	
	


END
GO
