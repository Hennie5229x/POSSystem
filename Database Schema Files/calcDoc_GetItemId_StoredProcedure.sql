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
CREATE PROCEDURE [dbo].[calcDoc_GetItemId]
	
	@LineId INT
	
AS
BEGIN	
	SET NOCOUNT ON;  

	
	SELECT	ItemId
	FROM	DocumentTransactionsLines
	WHERE	Id = @LineId
		

END
GO
