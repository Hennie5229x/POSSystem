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
CREATE PROCEDURE [dbo].[lkpItemGroups]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	Id, GroupName
	FROM	ItemGroups
	
		
END
GO
