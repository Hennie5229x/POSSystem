USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[calcItemMaster_Tax]
	-- PARAMETERS
		@ItemId INT
AS
BEGIN
	SET NOCOUNT ON; 
			
		SELECT	B.VAT
		FROM	ItemMaster A
		JOIN	TaxCodes B ON B.Id = A.TaxCode
		WHERE	A.Id = @ItemId
		
		
END
GO
