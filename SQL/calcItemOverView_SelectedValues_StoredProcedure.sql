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
CREATE PROCEDURE [dbo].[calcItemOverView_SelectedValues]
		
		@DocId INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	/*
		Selected values by Lines Id
	*/

	SELECT	ISNULL(MIN(Id),0) AS Id_Min,
			ISNULL(MAX(Id),0) AS Id_Max
	FROM	DocumentTransactionsLines
	WHERE	HeaderId = @DocId
	AND		LineStatus = 1 --Open

	/*
	SELECT	MIN(Id) AS Id_Min,
			MAX(Id) AS Id_Max
	FROM	DocumentTransactionsLines
	WHERE	HeaderId = @DocId
	AND		LineStatus = 1 --Open
	*/


END
GO
