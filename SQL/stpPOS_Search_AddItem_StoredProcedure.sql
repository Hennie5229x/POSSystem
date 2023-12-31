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
CREATE PROCEDURE [dbo].[stpPOS_Search_AddItem]
	-- PARAMETERS

	@ItemId INT,
	@Price DECIMAL(19,6) = NULL,
	@UserId NVARCHAR(50),
	@TerminalId INT,
	--For Returns--
	@Type NVARCHAR(10) = 'SALE', --SALE / RETURN
	@ReturnType NVARCHAR(50) = '', --LINKED/UNLINKED
	@ReturnAllLines BIT = 0,
	@DocNum NVARCHAR(50) = '',
	@UnlinkedHeaderId INT = NULL

AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION			
		
		--Adding the item with custom price

		

		IF(@Type = 'SALE')
		BEGIN
			DECLARE @ItemCode NVARCHAR(50)
			SELECT	@ItemCode = ItemCode
			FROM	ItemMaster
			WHERE	Id = @ItemId

			EXEC stpPOS_Doc_AddItem		@BarCodeEntry = @ItemCode,
										@UserId = @UserId,
										@TerminalId = @TerminalId,
										@SearchAddItem_Price = @Price
		END
		ELSE IF(@Type = 'RETURN')
		BEGIN			
			EXEC stpReturns_AddItem	@ReturnType = @ReturnType, --LINKED/UNLINKED
									@ReturnAllLines = @ReturnAllLines,
									@DocNum = @DocNum,
									@ItemId = @ItemId,
									@Barcode = '',
									@UnlinkedHeaderId = @UnlinkedHeaderId,
									@Price = @Price
		END

		


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
