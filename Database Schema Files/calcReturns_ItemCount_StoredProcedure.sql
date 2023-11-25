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
CREATE PROCEDURE [dbo].[calcReturns_ItemCount]	
	
	@DocNum NVARCHAR(50)
AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT	COUNT(Id) AS [Count]
	FROM	[Returns]
	WHERE	OriginalDocNum = @DocNum

	
		
END
GO
