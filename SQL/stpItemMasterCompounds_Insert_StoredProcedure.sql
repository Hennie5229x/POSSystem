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
CREATE PROCEDURE [dbo].[stpItemMasterCompounds_Insert]
	-- PARAMETERS
	
		@HeaderId INT,
		@ItemMasterItemId INT,
		@Quantity DECIMAL(19,6)
		

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
			IF(@HeaderId = @ItemMasterItemId)
			BEGIN
				RAISERROR('Cannot reference the same item.',11,1)
			END
			ELSE
			BEGIN
				INSERT INTO ItemMasterCompounds (HeaderId, ItemMasterItemId, Quantity)
				VALUES (@HeaderId, @ItemMasterItemId, @Quantity)	
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
