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
CREATE PROCEDURE [dbo].[lkpItemMaster_Suppliers]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT 'All' AS [Supplier]
	UNION ALL
	SELECT		DISTINCT B.SupplierName AS [Supplier]
	FROM		ItemMaster A
	LEFT JOIN	Suppliers B ON B.Id = A.SupplierId
	WHERE		ISNULL(SupplierName,'') <> ''
	
	
		
END
GO
