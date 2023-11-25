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
CREATE PROCEDURE [dbo].[calcPOSDocLines_Values]
	
	@DocId INT,
	@LineId INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	B.ItemName, A.Quantity, A.PriceUnitVatIncl AS Price
	FROM	DocumentTransactionsLines A
	JOIN	ItemMaster B ON B.Id = A.ItemId
	WHERE	A.HeaderId = @DocId
	AND		A.Id = @LineId

	

END
GO
