USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnPasswordHash]
(
	-- Add the parameters for the function here
	@Password NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	
	DECLARE @HashPass varbinary(64)
	SET @HashPass = HASHBYTES('SHA2_256', @Password)

	RETURN CONVERT(VARCHAR(1000), @HashPass, 1)

END
GO
