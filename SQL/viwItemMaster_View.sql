USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[viwItemMaster]
AS
		SELECT		 A.[Id]
					,[ItemCode]
					,[ItemName]
					,QuantityAvailable AS QuantityAvailable
					,[QuantityRequestMin]
					,[QuantityRequestMax]
					,[QuantityRequested]					
					,FORMAT(ROUND([PriceSellExclVat],2),'N2') AS [PriceSellExclVat]
					,FORMAT(ROUND((PriceSellExclVat + C.VAT/100.00 * PriceSellExclVat),2),'N2') AS PriceSellInclVat
					,FORMAT(ROUND([PricePurchaseExclVat],2),'N2') AS [PricePurchaseExclVat]
					,FORMAT(ROUND(DiscountedPriceIncl - DiscountPercentage/100.00 * DiscountedPriceIncl, 2),'N2') AS DiscountPriceSellIncl
					--,FORMAT(ROUND((PriceSellExclVat - DiscountPercentage/100.00 * PriceSellExclVat),2),'N2') AS DiscountPriceSellExcl
					--,FORMAT(ROUND((PriceSellExclVat - DiscountPercentage/100.00 * PriceSellExclVat) + (C.VAT/100.00 * (PriceSellExclVat - DiscountPercentage/100.00 * PriceSellExclVat)),2),'N2') AS DiscountPriceSellIncl
					,FORMAT(ROUND((DiscountedPriceIncl - C.VAT/100.00 * DiscountedPriceIncl),2),'N2') AS DiscountPriceSellExcl					
					,[DiscountPercentage]
					,ProfitMargin
					,CASE WHEN [Active] = 1 THEN 'Active' ELSE 'Inactive' END AS [Active]
					,[Barcode]
					,B.SupplierName AS Supplier
					,FORMAT(ROUND(C.VAT,2),'N2') AS Vat
					,E.UoM
					,F.GroupName AS ItemGroup
					,CASE WHEN G.HeaderId IS NULL THEN 'No' ELSE 'Yes' END AS CompoundItem
		FROM		[ItemMaster] A
		LEFT JOIN	Suppliers B ON B.Id = A.SupplierId
		LEFT JOIN	TaxCodes C ON C.Id = A.TaxCode		
		LEFT JOIN	UoM E ON E.Id = A.UoMId
		LEFT JOIN	ItemGroups F ON F.Id = A.ItemGroupId
		LEFT JOIN	(SELECT DISTINCT HeaderId FROM ItemMasterCompounds) G ON G.HeaderId = A.Id
		
GO
