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
CREATE PROCEDURE [dbo].[calcItemMaster_Values]
	
	@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT		A.ItemCode,
				A.ItemName,
				A.ItemGroupId,
				A.UoMId,
				A.TaxCode,
				A.Active,
				A.SupplierId,
				A.Barcode,
				A.PriceSellExclVat,
				FORMAT(A.DiscountedPriceIncl - (A.DiscountPercentage/100 * A.DiscountedPriceIncl), 'N2') AS PriceSellInclVat,
				--FORMAT(A.PriceSellExclVat + (B.VAT/100.00 * A.PriceSellExclVat),'N2') AS PriceSellInclVat,
				FORMAT(A.DiscountPercentage,'N2') AS DiscountPercentage,
				A.DiscountedPriceIncl AS FinalPrice,
				A.QuantityRequestMin,
				A.QuantityRequestMax
	FROM		ItemMaster A
	JOIN		TaxCodes B ON B.Id = A.TaxCode
	WHERE		A.Id = @Id


END
GO
