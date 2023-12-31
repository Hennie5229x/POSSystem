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
CREATE PROCEDURE [dbo].[stpUsers_Login]
	-- Add the parameters for the stored procedure here
	@LoginName NVARCHAR(100),
	@Password NVARCHAR(MAX)

AS
BEGIN
	
	SET NOCOUNT ON;  

	IF EXISTS	(
					SELECT	1
					FROM	Users
					WHERE	LoginName = @LoginName
					--AND		[Password] = dbo.fnPasswordHash(@Password)
					AND		Active = 0
				)
	BEGIN
		RAISERROR('User is inactive.',11,1)
	END
	ELSE IF EXISTS	(
						SELECT	1
						FROM	Users
						WHERE	LoginName = @LoginName
						AND		[Password] = dbo.fnPasswordHash(@Password)
					)
	BEGIN
		SELECT	1 AS Result,
				Id
		FROM	Users
		WHERE	LoginName = @LoginName
		AND		[Password] = dbo.fnPasswordHash(@Password)
	END	
	ELSE
	BEGIN
		SELECT 0 AS Result, NULL AS Id
	END
	
	


END
GO
