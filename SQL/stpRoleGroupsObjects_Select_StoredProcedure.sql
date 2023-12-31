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
CREATE PROCEDURE [dbo].[stpRoleGroupsObjects_Select]
	
	@RoleGroupId INT

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		ObjectId,
				RoleGroupId,
				B.ObjectName AS [Object],
				C.[Name] AS RoleGroup
	FROM		RoleGroupObjects A
	JOIN		[Objects] B ON B.Id = A.ObjectId
	JOIN		RoleGroups C ON C.Id = A.RoleGroupId
	WHERE		RoleGroupId = @RoleGroupId
	
		
END
GO
