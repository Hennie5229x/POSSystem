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
CREATE PROCEDURE [dbo].[calcReturnsItemOverView_SelectedValues]
		
		@DocId INT,
		@UnlinkedHeaderId INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	/*
		Selected values by Lines Id
	*/

	SELECT	ISNULL(MIN(Id),0) AS Id_Min,
			ISNULL(MAX(Id),0) AS Id_Max
	FROM	[Returns]
	WHERE	(	
				(ISNULL(OriginalDocId,0) > 0 AND ISNULL(OriginalDocId,0) = ISNULL(@DocId,0)) OR 
				(ISNULL(UnlinkedHeaderId,0) > 0 AND ISNULL(UnlinkedHeaderId,0) = ISNULL(@UnlinkedHeaderId,0))
			)
	AND		[Status] = 2 --Incomplete
		

END
GO
