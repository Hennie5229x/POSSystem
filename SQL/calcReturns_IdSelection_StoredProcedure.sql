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
CREATE PROCEDURE [dbo].[calcReturns_IdSelection]	
	
	
AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		TOP 1
				Id,
				ReturnType,
				OriginalDocNum,
				ISNULL(OriginalDocId, 0) AS OriginalDocId,
				ISNULL(UnlinkedHeaderId, 0) AS UnlinkedHeaderId
	FROM		[Returns]
	WHERE		[Status] = 2 --InComplete
	ORDER BY	Id ASC

	
		
END
GO
