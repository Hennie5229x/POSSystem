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
CREATE PROCEDURE [dbo].[calcItemGroup_Values]
	
	@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	GroupName, [Description]
	FROM	ItemGroups
	WHERE	Id = @Id


END
GO
