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
CREATE PROCEDURE [dbo].[stpUsers_Login_Pin]
	-- Add the parameters for the stored procedure here
	@Pin NVARCHAR(10)	--10 Chars to determin invalid pins
AS
BEGIN
	
	SET NOCOUNT ON;  

	IF EXISTS	(
					SELECT	1
					FROM	Users
					WHERE	Pin = @Pin					
					AND		Active = 0
				)
	BEGIN
		RAISERROR('User is inactive.',11,1)
	END
	ELSE IF EXISTS	(
						SELECT	1
						FROM	Users
						WHERE	Pin = @Pin						
					)
	BEGIN
		SELECT	1 AS Result,
				Id
		FROM	Users
		WHERE	Pin = @Pin	

		--History Log
		-------------
		DECLARE @UserId NVARCHAR(50)
		SELECT	@UserId = Id
		FROM	Users
		WHERE	Pin = @Pin
		
		EXEC stpHistoryLog_Insert	@UserId = @UserId,
									@Action = 'POS Login',
									@Description = 'Successfully loggend in',
									@FromValue = NULL,
									@ToValue = NULL								

	END	
	ELSE
	BEGIN
		SELECT 0 AS Result, NULL AS Id
	END
	
	


END
GO
