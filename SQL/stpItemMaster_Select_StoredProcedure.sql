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
CREATE PROCEDURE [dbo].[stpItemMaster_Select]
	
	@ItemCode NVARCHAR(50),
	@ItemName NVARCHAR(50),	
	@Barcode NVARCHAR(100),
	@Supplier NVARCHAR(100),
	@Vat NVARCHAR(50),
	@ItemGroup NVARCHAR(50)

AS
BEGIN
	
	SET NOCOUNT ON;  

	/*
	Active: All, Active, Inactive
	*/

	SELECT	@ItemCode = ISNULL(@ItemCode,''),
			@ItemName = ISNULL(@ItemName,''),			
			@Barcode = ISNULL(@Barcode,''),
			@Supplier = ISNULL(@Supplier,''),
			@Vat = ISNULL(@Vat,''),
			@ItemGroup = ISNULL(@ItemGroup,'')
	

	IF(@ItemCode = '' AND @ItemName = '' AND @Barcode = '' AND @Supplier = '' AND @Vat = '' AND @ItemGroup = '')
	BEGIN	
		
		SELECT		Id, 
					ItemCode, 
					ItemName, 
					QuantityAvailable, 
					QuantityRequestMin, 
					QuantityRequestMax, 
					QuantityRequested, 
					PriceSellExclVat,
					PriceSellInclVat,
					PricePurchaseExclVat, 
					DiscountPriceSellExcl,
					DiscountPriceSellIncl,
					ProfitMargin,
					DiscountPercentage, 
					Active, 
					Barcode, 
					Supplier, 
                    Vat,
					UoM,
					ItemGroup,
					CompoundItem
		FROM        viwItemMaster
		WHERE		ItemCode IS NOT NULL

	END
	ELSE
	BEGIN
		
		SELECT		Id, 
					ItemCode, 
					ItemName, 
					QuantityAvailable, 
					QuantityRequestMin, 
					QuantityRequestMax, 
					QuantityRequested, 
					PriceSellExclVat,
					PriceSellInclVat,
					PricePurchaseExclVat, 
					DiscountPriceSellExcl,
					DiscountPriceSellIncl,
					ProfitMargin,
					DiscountPercentage, 
					Active, 
					Barcode, 
					Supplier, 
                    Vat,
					UoM,
					ItemGroup,
					CompoundItem
		FROM        viwItemMaster
		WHERE		ISNULL(ItemCode,'') LIKE '%'+@ItemCode+'%'
		AND			ISNULL(ItemName,'') LIKE '%'+@ItemName+'%'
		AND			ISNULL(Barcode,'') LIKE '%'+@Barcode+'%'
		AND			ISNULL(Supplier,'') LIKE '%'+@Supplier+'%'
		AND			ISNULL(VAT,'') LIKE '%'+@Vat+'%'
		AND			ISNULL(ItemGroup,'') LIKE '%'+@ItemGroup+'%'
		AND			ItemCode IS NOT NULL

	END
		
END
GO
