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
CREATE PROCEDURE [dbo].[stpRoleGroups_Values_Select]
	
	@Id INT

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		[Name],
				[Description]
	FROM        RoleGroups 
	WHERE		Id = @Id
	
		
END
GO
