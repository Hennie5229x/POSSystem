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
CREATE PROCEDURE [dbo].[calcItemName_Value]
	
	@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;  


	SELECT	B.ItemName, A.Quantity
	FROM	ItemMasterCompounds A
	JOIN	ItemMaster B ON B.Id = A.ItemMasterItemId
	WHERE	A.Id = @Id


END
GO
