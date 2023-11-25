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
CREATE PROCEDURE [dbo].[calcUserName]
	
	@UserId NVARCHAR(50)

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	FullName AS UserName
	FROM	viwUsers
	WHERE	Id = @UserId

	--SELECT	ISNULL([Name],'') + ' ' + ISNULL([Surname],'') AS UserName
	--FROM	Users
	--WHERE	Id = @UserId


END
GO
