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
CREATE PROCEDURE [dbo].[lkpSuppliers]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	--SELECT  0 AS Id, '' AS SupplierName
	--UNION ALL
	SELECT	Id, SupplierName
	FROM	Suppliers	
		
END
GO
