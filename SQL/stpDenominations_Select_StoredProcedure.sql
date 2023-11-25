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
CREATE PROCEDURE [dbo].[stpDenominations_Select]	
	

AS
BEGIN	
	SET NOCOUNT ON;  
	
	DECLARE @CurrencySign NVARCHAR(10) = NULL
	SELECT	@CurrencySign = CurrencySign
	FROM	CompanyInformation
	
	SELECT	A.Id,
			@CurrencySign AS CurrencySign,
			B.[Type],
			A.[Name],
			A.[Value]
	FROM	Denominations A
	JOIN	DenominationTypes B ON B.Id = A.TypeId
	


	
		
END
GO
