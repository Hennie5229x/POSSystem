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
CREATE PROCEDURE [dbo].[stpRoleGroups_Select]	
	

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		A.Id,
				A.[Name],
				A.[Description],
				'Users ('+CAST(ISNULL(B.[Count], 0) AS NVARCHAR(50))+')' AS RoleGroupUser,
				'Objects ('+CAST(ISNULL(C.[Count], 0) AS NVARCHAR(50))+')' AS RoleGroupObjects
	FROM		RoleGroups A
	LEFT JOIN	(
					SELECT		COUNT(UserId) AS [Count], RoleGroupId
					FROM		RoleGroupUsers
					GROUP BY	RoleGroupId
				) B ON B.RoleGroupId = A.Id
	LEFT JOIN	(
					SELECT		COUNT(ObjectId) AS [Count], RoleGroupId
					FROM		RoleGroupObjects
					GROUP BY	RoleGroupId
				) C	ON C.RoleGroupId = A.Id




	/*
	SELECT		A.Id,
				A.[Name],
				A.[Description],
				'Users ('+CAST(COUNT(B.UserId) AS NVARCHAR(50))+')' AS RoleGroupUser,
				'Objects ('+CAST(COUNT(C.ObjectId) AS NVARCHAR(50))+')' AS RoleGroupObjects
	FROM		RoleGroups A
	LEFT JOIN	RoleGroupUsers B ON B.RoleGroupId = A.Id
	LEFT JOIN	RoleGroupObjects C ON C.RoleGroupId = A.Id
	GROUP BY	A.Id, A.[Name], A.[Description]	
	*/
		
END
GO
