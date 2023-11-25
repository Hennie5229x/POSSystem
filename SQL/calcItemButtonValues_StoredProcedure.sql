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
CREATE PROCEDURE [dbo].[calcItemButtonValues]
	-- PARAMETERS
	
		@ItemId INT		

AS
BEGIN
	SET NOCOUNT ON;
    
	SELECT	ButtonText,
			Font,
			FontSize,
			Hex
	FROM	ItemButtons
	WHERE	ItemId = @ItemId

END
GO
