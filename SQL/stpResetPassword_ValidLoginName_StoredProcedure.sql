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
CREATE PROCEDURE [dbo].[stpResetPassword_ValidLoginName]
	
	@LoginName NVARCHAR(100)

AS
BEGIN	
	SET NOCOUNT ON;  

	IF EXISTS	(
					SELECT	1
					FROM	Users
					WHERE	LoginName = @LoginName
				)
	BEGIN
		SELECT	CAST(1 AS BIT) AS Result, Id AS UserId		
		FROM	Users
		WHERE	LoginName = @LoginName
	END
	ELSE
	BEGIN
		SELECT CAST(0 AS BIT) AS Result, '' AS UserId		
	END
		
END
GO
