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
CREATE PROCEDURE [dbo].[stpItemButton_Update]
	-- PARAMETERS
	
		@ItemId INT,
		@ButtonText NVARCHAR(50),
		@Font NVARCHAR(50),
		@FontSize INT,
		@Hex NVARCHAR(50)		

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF NOT EXISTS(SELECT 1 FROM ItemButtons WHERE ItemId = @ItemId)
		BEGIN
			INSERT INTO ItemButtons (ItemId, ButtonText, Font, FontSize, Hex) 
					VALUES (@ItemId, @ButtonText, @Font, @FontSize, @Hex)	
		END
		ELSE
		BEGIN
			UPDATE	A
			SET		ButtonText = @ButtonText,
					Font = @Font,
					FontSize = @FontSize,
					Hex = @Hex
			FROM	ItemButtons A
			WHERE	A.ItemId = @ItemId
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
