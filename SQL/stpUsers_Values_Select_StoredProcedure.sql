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
CREATE PROCEDURE [dbo].[stpUsers_Values_Select]
	
	@Id UNIQUEIDENTIFIER

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		LoginName, 					
				[Name], 
				Surname, 
				Phone, 
				Email,
				Active,
				Pin
	FROM        Users 
	WHERE		Id = @Id
	
		
END
GO
