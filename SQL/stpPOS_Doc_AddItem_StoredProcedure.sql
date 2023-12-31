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
CREATE PROCEDURE [dbo].[stpPOS_Doc_AddItem]
	-- PARAMETERS	
	@BarCodeEntry NVARCHAR(MAX),
	@UserId NVARCHAR(50),
	@TerminalId INT,
	@SearchAddItem_Price DECIMAL(19,6) = NULL
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION
		
		--DECLARE @A NVARCHAR(MAX)
		--SET @A = CAST(@TerminalId AS NVARCHAR(50))
		
		/*------------------------
			Item Add to Overview
		---------------------------*/
		DECLARE @ItemId INT = NULL
		DECLARE @DocId INT = NULL
		DECLARE @ValidItem BIT = 0;
		-------------------
		-----If Barcode----
		-------------------
		IF EXISTS (
					SELECT	1 
					FROM	ItemMaster 
					WHERE	ISNULL(Barcode,'') = ISNULL(@BarCodeEntry,'') 
					AND		ISNULL(@BarCodeEntry,'') <> ''
					AND		ISNULL(Active,0) = 1)
		BEGIN
			SELECT	@ItemId = Id
			FROM	ItemMaster
			WHERE	Barcode = @BarCodeEntry
			AND		ISNULL(@BarCodeEntry,'') <> ''
			AND		ISNULL(Active,0) = 1
		END
		-------------------
		----If ItemCode----
		-------------------
		ELSE IF EXISTS(SELECT 1 FROM ItemMaster WHERE ISNULL(ItemCode,'') = ISNULL(@BarCodeEntry,'') AND ISNULL(Active,0) = 1)
		BEGIN
			SELECT	@ItemId = Id
			FROM	ItemMaster
			WHERE	ItemCode = @BarCodeEntry
			AND		ISNULL(Active,0) = 1
		END		

		IF(@ItemId IS NOT NULL)
		BEGIN
			
			SET @ValidItem = 1;

			-- Check for Open Shift
			IF NOT EXISTS (
						  	SELECT	1
							FROM	Shifts
							WHERE	UserId = @UserId
							AND		ShiftStatusId = 1 --Open
						  )
			BEGIN				
				DECLARE @Msg NVARCHAR(MAX) = 'No active shift for '+(SELECT FullName FROM viwUsers WHERE Id = @UserId)
				RAISERROR(@Msg,11,1)
			END
			--Check for Cash Up Completed
			IF NOT EXISTS (
					  		SELECT	1
							FROM	Shifts
							WHERE	UserId = @UserId
							AND		ShiftStatusId = 1 --Open
							AND		CashUpStatus = 2 --Incomplete
						  )
			BEGIN				
				RAISERROR('Cash Up for the current shift has already been completed, please end the Shift.',11,1)
			END

			/*-------------------
				Create Doc Header
			----------------------*/
			IF NOT EXISTS	(
									SELECT	1
									FROM	DocumentTransactionsHeader A
									JOIN	Shifts B ON B.Id = A.ShiftId		
									WHERE	A.DocumentStatusId = 1 --Open
									AND		B.UserId = @UserId
									AND		B.ShiftStatusId = 1 -- Open
									AND		B.CashUpStatus = 2 --Incomplete
									AND		A.TerminalId = @TerminalId								
							)
							--SELECT	1 
							--FROM	DocumentTransactionsHeader 
							--WHERE	DocumentStatusId = 1
							--AND		TerminalId = @TerminalId
							--AND		UserId = @UserId
						   --)--Open
			BEGIN
			
				--Document Number
				DECLARE @DocNum NVARCHAR(50) = NULL
				DECLARE @NewDocNum NVARCHAR(50) = ''

				SELECT		TOP 1 @DocNum = DocumentNumber
				FROM		DocumentTransactionsHeader
				ORDER BY	Id DESC
								
				IF(@DocNum IS NULL)
				BEGIN
					SET @NewDocNum = 'DOC-1'
				END
				ELSE
				BEGIN					
					DECLARE @Num INT = CAST(RIGHT(@DocNum, LEN(@DocNum)-4) AS INT)+1
					SET @NewDocNum = 'DOC-'+CAST(@Num AS NVARCHAR(50))					
				END				
				
				--Shift
				DECLARE @ShiftId INT
				SELECT	@ShiftId = Id 
				FROM	Shifts
				WHERE	ShiftStatusId = 1 --Open
				AND		UserId = @UserId	
		
				--Create Header
				INSERT INTO DocumentTransactionsHeader(DocumentNumber, DocumentStatusId, [Date], UserId, ShiftId, TerminalId, DocumentTypeId)
												VALUES(@NewDocNum, 1, GETDATE(), @UserId, @ShiftId, @TerminalId, 1)
				SET @DocId = SCOPE_IDENTITY()

			END				
				/*-----------
				-- Add Line
				-----------*/
				
				IF(@DocId IS NULL)
				BEGIN
					DECLARE @TableDocId TABLE (Id INT)
					INSERT INTO @TableDocId
					EXEC stpPOS_DocId_Selection @UserId = @UserId ,	@TerminalId = @TerminalId

					SELECT	@DocId = Id
					FROM	@TableDocId					
				END
				---------------
				IF(@DocId > 0)
				BEGIN

					DECLARE @ItemUnitPrice DECIMAL(19,6)
					DECLARE @LineTotal DECIMAL(19,6)

					IF(@SearchAddItem_Price IS NULL)
					BEGIN
						SELECT	@ItemUnitPrice = DiscountPriceSellIncl,
								@LineTotal = DiscountPriceSellIncl --Because default qty is 1 (untill updated)
						FROM	viwItemMaster
						WHERE	Id = @ItemId
					END
					ELSE
					BEGIN
						SET @ItemUnitPrice = @SearchAddItem_Price
						SET @LineTotal = @SearchAddItem_Price --Because default qty is 1 (untill updated)
					END
					
					DECLARE @LineId INT

					INSERT INTO DocumentTransactionsLines(HeaderId, ItemId, Quantity, PriceUnitVatIncl, LineStatus, LineTotal)
					VALUES(@DocId, @ItemId, 1, @ItemUnitPrice, 1, @LineTotal)
					SET @LineId = SCOPE_IDENTITY()

					
					/*--------------------------*/
					--Price Change (Special Price)
					DECLARE @ItemMasterPrice DECIMAL(19,6),
							@ItemMasterDiscountPercentage DECIMAL(19,6)

					SELECT	@ItemMasterPrice = DiscountPriceSellIncl,
							@ItemMasterDiscountPercentage = B.DiscountPercentage
					FROM	DocumentTransactionsLines A
					JOIN	viwItemMaster B ON B.Id = A.ItemId
					WHERE	A.Id = @LineId

					IF(@ItemMasterPrice <> @SearchAddItem_Price)
					BEGIN
						UPDATE	A
						SET		ItemMaster_Price = @ItemMasterPrice,
								ItemMasterDiscountPercentage = @ItemMasterDiscountPercentage,
								PriceChange_Price = @SearchAddItem_Price
						FROM	DocumentTransactionsLines A
						WHERE	HeaderId = @DocId
						AND		Id = @LineId
					END
					/*--------------------------*/

					DECLARE @DocTotal DECIMAL(19,2)
					SELECT	@DocTotal = SUM(B.LineTotal)
					FROM	DocumentTransactionsHeader A
					JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
					WHERE	A.Id = @DocId
					AND		B.LineStatus = 1 --Open
					
					UPDATE	A
					SET		A.DocumentTotal = @DocTotal
					FROM	DocumentTransactionsHeader A
					JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
					WHERE	A.Id = @DocId
					AND		B.LineStatus = 1 --Open

				END
		END

		

		SELECT @ValidItem AS ValidItem
		

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
