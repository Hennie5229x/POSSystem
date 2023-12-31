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
CREATE PROCEDURE [dbo].[stpStockTakeLines_Temp_Save]
	
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF EXISTS (
					SELECT	1
					FROM	StockTakeLines_Temp
					WHERE	Quantity IS NULL
				  )
		BEGIN
			RAISERROR('All item groups must be completed',11,1)
		END
		ELSE
		BEGIN
			DECLARE @Id INT
			DECLARE @UserId NVARCHAR(50)
			SELECT  @UserId = UserId
			FROM	StockTake_Temp

			/*	Insert Header	*/
			INSERT INTO StockTake([Date], UserId)
			SELECT      GETDATE(), @UserId			
			SET @Id = SCOPE_IDENTITY()

			/*	Insert Lines	*/
			INSERT INTO StockTakeLines(HeaderId, ItemGroupId, ItemId, Quantity, Variance)
			SELECT  @Id AS Id, D.ItemGroupId, A.ItemId, A.Quantity, A.Variance
			FROM	StockTakeLines_Temp A
			JOIN	ItemMaster B ON B.Id = A.ItemId
			JOIN	ItemGroups C ON C.Id = B.ItemGroupId
			JOIN	StockTake_Temp D ON D.ItemGroupId = C.Id

			/*	Clear Temp tables	*/
			EXEC dbo.stpStockTakeLines_Temp_Cancel
			
			---------------------------------------
			-------History Log---------------------
			---------------------------------------			
			DECLARE @Des NVARCHAR(MAX) = 'Stock Take: Stock counted'

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = @Des,
										@FromValue = '',
										@ToValue = '',
										@FieldId = @Id		
			
		
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
