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
CREATE PROCEDURE [dbo].[calcRoleGroupUsersName]
	
	@RoleGroupId INT

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	[Name]
	FROM	RoleGroups
	WHERE	Id = @RoleGroupId


END
GO
