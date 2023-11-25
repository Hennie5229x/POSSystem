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
CREATE PROCEDURE [dbo].[lkpItemMaster_Vat]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT 'All' AS Vat
	UNION ALL
	SELECT		DISTINCT FORMAT(ROUND(B.VAT,2),'N2')+'%' AS Vat
	FROM		ItemMaster A
	LEFT JOIN	TaxCodes B ON B.Id = A.TaxCode
	WHERE		A.ItemCode IS NOT NULL
	
	
		
END
GO
