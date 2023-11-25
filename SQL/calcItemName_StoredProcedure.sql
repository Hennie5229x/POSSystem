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
CREATE PROCEDURE [dbo].[calcItemName]
	
	@ItemId INT

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	ISNULL(ItemName,'') AS ItemName
	FROM	ItemMaster
	WHERE	Id = @ItemId


END
GO
