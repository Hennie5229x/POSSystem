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
CREATE PROCEDURE [dbo].[calcUoM_Values]	
	
	@Id INT
AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT      UoM, 
				[Description]
	FROM        UoM
	WHERE		Id = @Id
	
		
END
GO
