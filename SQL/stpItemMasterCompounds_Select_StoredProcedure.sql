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
CREATE PROCEDURE [dbo].[stpItemMasterCompounds_Select]
	
		@Id INT

AS
BEGIN
	
	SET NOCOUNT ON;  

		SELECT	A.Id,
				C.ItemCode,
				C.ItemName,
				A.Quantity
		FROM	ItemMasterCompounds A
		JOIN	ItemMaster B ON B.Id = A.HeaderId
		JOIN	ItemMaster C ON C.Id = A.ItemMasterItemId
		WHERE	B.Id = @Id	
		
END
GO
