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
CREATE PROCEDURE [dbo].[stpReturns_Select]	
	
	@ReturnType NVARCHAR(50),
	@DocId INT,
	@UnlinkedHeaderId INT
	
AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		A.Id,
				B.ItemName,
				CAST(A.Qty AS DECIMAL(19,2)) AS Qty,
				CAST(A.PriceSell AS DECIMAL(19,2)) AS UnitPrice,
				CAST(ISNULL(A.PriceSell, 0) * ISNULL(A.Qty, 0) AS DECIMAL(19,2)) AS LineTotal
	FROM		[Returns] A
	JOIN		viwItemMaster B ON B.Id = A.ItemId
	WHERE		A.ReturnType = @ReturnType
	AND			(A.OriginalDocId = @DocId OR A.UnlinkedHeaderId = @UnlinkedHeaderId)
	AND			A.[Status] = 2 --InComplete
	

	
		
END
GO
