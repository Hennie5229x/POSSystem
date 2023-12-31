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
CREATE PROCEDURE [dbo].[stpRoleGroupsUsers_Select]
	
	@RoleGroupId INT

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		UserId,
				RoleGroupId,
				ISNULL(B.[Name],'')+' '+ISNULL(B.Surname,'') AS UserName,
				C.[Name] AS RoleGroup
	FROM		RoleGroupUsers A
	JOIN		Users B ON B.Id = A.UserId
	JOIN		RoleGroups C ON C.Id = A.RoleGroupId
	WHERE		RoleGroupId = @RoleGroupId
	
		
END
GO
