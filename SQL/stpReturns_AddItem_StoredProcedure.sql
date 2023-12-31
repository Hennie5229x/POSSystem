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
CREATE PROCEDURE [dbo].[stpReturns_AddItem]
	-- PARAMETERS	
	
	@ReturnType NVARCHAR(50), --LINKED/UNLINKED
	@ReturnAllLines BIT,
	@DocNum NVARCHAR(50),
	@Barcode NVARCHAR(50),
	@UnlinkedHeaderId INT,
	@ItemId INT = NULL,
	@Price DECIMAL(19,6) = NULL

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION				
			
			IF(@ItemId IS NOT NULL)
			AND EXISTS (	
							SELECT	1
							FROM	DocumentTransactionsHeader A
							JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
							WHERE	A.DocumentNumber = @DocNum
							AND		B.Id = @ItemId
					    )
			BEGIN --Convert the line id to the item master id
				SELECT	@ItemId = B.ItemId
				FROM	DocumentTransactionsHeader A
				JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
				WHERE	A.DocumentNumber = @DocNum
				AND		B.Id = @ItemId
			END
			ELSE
			IF(@ItemId IS NULL)
			BEGIN
				SELECT	@ItemId = Id
				FROM	ItemMaster
				WHERE	ItemCode = ISNULL(@Barcode,'')
				OR		ISNULL(Barcode,'') = ISNULL(@Barcode, '')
			END

			IF(@ItemId IS NOT NULL OR @ReturnAllLines = 1)
			BEGIN
				IF(@ReturnType = 'LINKED')
				BEGIN
					--Safty Check
					DECLARE @Tbl TABLE (Valid BIT)
					INSERT INTO @Tbl
					EXEC calcReturns_ValidDocNum @DocNum

					IF((SELECT Valid FROM @Tbl) = 1) --Valid = True
					BEGIN --LINKED
						IF(@ReturnAllLines = 1)
						BEGIN
							-- All Lines
							INSERT INTO [Returns] (ReturnType, OriginalDocNum, OriginalDocId, ItemId, Qty, PriceSell, Status)
							SELECT	@ReturnType, UPPER(@DocNum), B.Id, A.ItemId, A.Quantity, A.PriceUnitVatIncl, 2 --InComplete
							FROM	DocumentTransactionsLines A
							JOIN	DocumentTransactionsHeader B ON B.Id = A.HeaderId
							WHERE	B.DocumentNumber = @DocNum
							AND		A.LineStatus = 1 --Open
						END
						ELSE
						BEGIN
							
							IF NOT EXISTS	( 
												SELECT	1
												FROM	DocumentTransactionsLines A
												JOIN	DocumentTransactionsHeader B ON B.Id = A.HeaderId												
												WHERE	A.ItemId = @ItemId
												AND		B.DocumentNumber = @DocNum
												AND		A.LineStatus = 1 --Open
											)
							BEGIN
							
								DECLARE @Msg NVARCHAR(255) = ''
								SELECT	@Msg = ISNULL(ItemName, '') + ' was not on the orignal invoice.'
								FROM	ItemMaster
								WHERE	Id = @ItemId

								RAISERROR(@Msg, 11, 1)
							END
							ELSE
							BEGIN
								
								-- Single Line
								INSERT INTO [Returns] (ReturnType, OriginalDocNum, OriginalDocId,  ItemId, Qty, PriceSell, Status)
								SELECT	TOP 1 @ReturnType, UPPER(@DocNum), B.Id, @ItemId, 1, A.PriceUnitVatIncl, 2 --InComplete
								FROM	DocumentTransactionsLines A
								JOIN	DocumentTransactionsHeader B ON B.Id = A.HeaderId
								WHERE	A.ItemId = @ItemId
								AND		B.DocumentNumber = @DocNum
								AND		A.LineStatus = 1 --Open
							END
						END
					
					END
				END
				ELSE --UNLINKED
				BEGIN				
					
					DECLARE @NewUnlinkedHeaderId INT = NULL

					IF(ISNULL(@UnlinkedHeaderId,0) > 0)
					BEGIN
						SET @NewUnlinkedHeaderId = @UnlinkedHeaderId
					END
					ELSE
					BEGIN
						SET @NewUnlinkedHeaderId = ISNULL(@NewUnlinkedHeaderId, 0) +1
					END

					-- Single Line
					INSERT INTO [Returns] (ReturnType, OriginalDocNum, UnlinkedHeaderId, ItemId, Qty, PriceSell, Status)
					SELECT	TOP 1 @ReturnType, @DocNum, @NewUnlinkedHeaderId, @ItemId, 1, COALESCE(@Price,DiscountPriceSellIncl), 2 --InComplete
					FROM	viwItemMaster
					WHERE	Id = @ItemId					
				END
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
