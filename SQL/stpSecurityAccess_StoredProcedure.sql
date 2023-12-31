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
CREATE PROCEDURE [dbo].[stpSecurityAccess]
	
	@ObjectId NVARCHAR(50),
	@UserId NVARCHAR(50)

AS
BEGIN	
	SET NOCOUNT ON;  
	
	IF EXISTS	(
					SELECT	1 
					FROM	RoleGroupObjects A
					JOIN	RoleGroupUsers B ON B.RoleGroupId = A.RoleGroupId
					WHERE	UserId = @UserId
					AND		ObjectId = @ObjectId
				)
	BEGIN 
		SELECT CAST(1 AS BIT) AS Result
	END
	ELSE
	BEGIN
		SELECT CAST(0 AS BIT) AS Result
	END
	
	
	
	
	
		
END
GO
