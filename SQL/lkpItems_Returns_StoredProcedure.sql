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
CREATE PROCEDURE [dbo].[lkpItems_Returns]
	
	@DocNum NVARCHAR(50)

AS
BEGIN
	
	SET NOCOUNT ON;  

	
	DECLARE @OringinalDocId INT
	SELECT	@OringinalDocId = Id
	FROM	DocumentTransactionsHeader
	WHERE	DocumentNumber = @DocNum

	SELECT	A.Id,
			B.ItemName,
			A.QuantityOpen,
			A.PriceUnitVatIncl AS PriceSell
	FROM	DocumentTransactionsLines A
	JOIN	ItemMaster B ON B.Id = A.ItemId
	WHERE	A.HeaderId = @OringinalDocId
	
		
END

GO
