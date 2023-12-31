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
CREATE PROCEDURE [dbo].[stpItemMasterCompounds_Update]
	-- PARAMETERS
	
		@Id INT,
		@Quantity DECIMAL(19,6)	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF(@Quantity IS NULL)
		BEGIN
			RAISERROR('Quantity cannot be empty.',11,1)
		END
		IF(@Quantity < 0)
		BEGIN
			RAISERROR('Quantity cannot be negative.',11,1)
		END

		UPDATE	ItemMasterCompounds
		SET		Quantity = @Quantity
		WHERE	Id = @Id
			
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
