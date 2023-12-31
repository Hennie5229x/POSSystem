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
CREATE PROCEDURE [dbo].[stpUsers_Select]
	
	@LoginName NVARCHAR(100),
	@Name NVARCHAR(100),
	@Surname NVARCHAR(100)

AS
BEGIN
	
	SET NOCOUNT ON;  

	SET @LoginName = ISNULL(@LoginName,'')
	SET	@Name = ISNULL(@Name,'')
	SET @Surname = ISNULL(@Surname,'')

	IF(@LoginName = '' AND @Name = '' AND @Surname = '')
	BEGIN
		
		SELECT		Id, 
					LoginName, 					
					[Name], 
					Surname, 
					Phone, 
					Email,
					CASE WHEN Active = 1 THEN 'Active' ELSE 'Inactive' END AS Active,
					Pin
		FROM        Users
		ORDER BY	LoginName
	END
	ELSE
	BEGIN
		
		SELECT		Id, 
					LoginName, 					
					[Name], 
					Surname, 
					Phone, 
					Email,
					CASE WHEN Active = 1 THEN 'Active' ELSE 'Inactive' END AS Active,
					Pin
		FROM        Users 
		WHERE		ISNULL(LoginName,'') LIKE '%'+@LoginName+'%'
		AND			ISNULL([Name],'') LIKE '%'+@Name+'%'
		AND			ISNULL([Surname],'') LIKE '%'+@Surname+'%'
		ORDER BY	LoginName
	END
		
END
GO
