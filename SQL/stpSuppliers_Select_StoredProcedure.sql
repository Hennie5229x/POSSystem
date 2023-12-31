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
CREATE PROCEDURE [dbo].[stpSuppliers_Select]
	
	@SupplierName NVARCHAR(100),
	@CompanyName NVARCHAR(100)

AS
BEGIN
	
	SET NOCOUNT ON;  

	/*
	Active: All, Active, Inactive
	*/

	SET	@SupplierName = ISNULL(@SupplierName,'')			
	SET @CompanyName = ISNULL(@CompanyName,'')

	IF(@SupplierName = '' AND @CompanyName = '')
	BEGIN	
		
		SELECT	 [Id]
				,CompanyName
				,[SupplierName]
				,REPLACE(REPLACE([BillToAddress],CHAR(10),' '), CHAR(13), '') AS [BillToAddress]
				,REPLACE(REPLACE([ShipToAddress],CHAR(10),' '), CHAR(13), '') AS [ShipToAddress]
				,REPLACE(REPLACE([BillingInformation],CHAR(10),' '), CHAR(13), '') AS [BillingInformation]
				,[ContactPerson]
				,[Telephone]
				,[CellPhone]
				,[Email]
				,[VATNumber]
		FROM	[POSSystem].[dbo].[Suppliers]

	END
	ELSE
	BEGIN
		
		SELECT	 [Id]
				,CompanyName
				,[SupplierName]
				,REPLACE(REPLACE([BillToAddress],CHAR(10),' '), CHAR(13), '') AS [BillToAddress]
				,REPLACE(REPLACE([ShipToAddress],CHAR(10),' '), CHAR(13), '') AS [ShipToAddress]
				,REPLACE(REPLACE([BillingInformation],CHAR(10),' '), CHAR(13), '') AS [BillingInformation]
				,[ContactPerson]
				,[Telephone]
				,[CellPhone]
				,[Email]
				,[VATNumber]
		FROM	[POSSystem].[dbo].[Suppliers]
		WHERE	ISNULL([SupplierName],'') LIKE '%'+@SupplierName+'%'
		AND		ISNULL(CompanyName,'') LIKE '%'+@CompanyName+'%' 

	END
		
END
GO
