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
CREATE PROCEDURE [dbo].[calcVatValue]
	
	@TaxCodeId INT

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	VAT
	FROM	TaxCodes
	WHErE	Id = @TaxCodeId


END
GO
