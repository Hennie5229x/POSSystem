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
CREATE PROCEDURE [dbo].[stpCashUp_Denominations_Select]	
	
	@ShiftId INT

AS
BEGIN	
	SET NOCOUNT ON;  
		
	SELECT		B.Id AS LineId,
				C.[Name] AS DenominationName,
				C.[Value] AS DenominationValue,
				B.DenominationCount			
	FROM		CashUp A
	JOIN		CashUpLines B ON B.HeaderId = A.Id
	JOIN		Denominations C ON C.Id = B.DenominationId
	WHERE		A.ShiftId = @ShiftId
	ORDER BY	C.[Value] ASC	
		
END
GO
