USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_PAY_Finalize]
	-- PARAMETERS
	@DocId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		UPDATE	A
		SET		DocumentStatusId = 3 --Finalized
		FROM	DocumentTransactionsHeader A
		WHERE	Id = @DocId

		UPDATE		C
		SET			C.QuantityAvailable = (ISNULL(C.QuantityAvailable,0) - (ISNULL(A.Quantity,0) * ISNULL(B.CompoundQty,0)))
		FROM		DocumentTransactionsLines A
		CROSS APPLY	dbo.fnItemMasterCompoundQuantity(A.ItemId) B
		JOIN		ItemMaster C ON C.Id = B.ItemIdCompound
		WHERE		A.HeaderId = @DocId
				
					
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		-- Raise an error with the details of the exception
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		SET @ErrMsg = ERROR_MESSAGE()
		SET @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1) 
	END CATCH 
END
GO
