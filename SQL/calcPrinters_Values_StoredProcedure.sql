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
CREATE PROCEDURE [dbo].[calcPrinters_Values]	
	
	@Id INT
AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT      PrinterName, 
				PrinterDescription
	FROM        Printers
	WHERE		Id = @Id
	
		
END
GO
