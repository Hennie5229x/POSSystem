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
CREATE PROCEDURE [dbo].[lkpTaxCodes]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	Id, 
			FORMAT(ROUND(VAT,2),'N2')+'%' AS VAT
	FROM	TaxCodes	
		
END
GO
