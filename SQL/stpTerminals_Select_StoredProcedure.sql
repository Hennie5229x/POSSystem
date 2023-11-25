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
CREATE PROCEDURE [dbo].[stpTerminals_Select]	
	

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT	A.Id,
			A.TerminalName,
			A.Terminal_IP,
			A.PrinterId,
			B.PrinterName
	FROM	Terminals A
	JOIN	Printers B ON B.Id = A.PrinterId
	
		
END
GO
