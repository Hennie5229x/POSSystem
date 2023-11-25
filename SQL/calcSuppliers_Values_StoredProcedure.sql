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
CREATE PROCEDURE [dbo].[calcSuppliers_Values]
	
	@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	CompanyName,
			SupplierName, 
			BillToAddress, 
			ShipToAddress, 
			BillingInformation, 
			ContactPerson, 
			Telephone, 
			CellPhone, 
			Email, 
			VATNumber
	FROM    Suppliers
	WHERE	Id = @Id


END
GO
