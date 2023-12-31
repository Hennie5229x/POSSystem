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
CREATE PROCEDURE [dbo].[calcReturns_ValidDocNum]
	
	@DocNum NVARCHAR(50)
	
AS
BEGIN	
	SET NOCOUNT ON;


	IF EXISTS	(
					SELECT	1
					FROM	DocumentTransactionsHeader
					WHERE	DocumentNumber = @DocNum
					AND		DocumentStatusId = 3 --Finalized
					AND		DocumentTypeId = 1 --Sale

				)
	BEGIN
		SELECT CAST(1 AS BIT) AS ValidDocNum
	END
	ELSE
	BEGIN
		SELECT CAST(0 AS BIT) AS ValidDocNum
	END
	
		

END
GO
