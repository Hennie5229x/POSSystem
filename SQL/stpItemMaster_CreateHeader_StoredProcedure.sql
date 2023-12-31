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
CREATE PROCEDURE [dbo].[stpItemMaster_CreateHeader]
	-- PARAMETERS	
	--@Id INT
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION
			
			--DELETE Old Empty Headers
			DELETE
			FROM	ItemMaster
			WHERE	ItemCode IS NULL
			AND		CAST(TimeStampCreate AS DATE) < CAST(GETDATE() AS DATE)
			-------------------------------------------------------------------
			
			DECLARE @Id INT

			INSERT INTO ItemMaster (ItemCode, TimeStampCreate) VALUES (NULL, GETDATE())
			SET @Id = SCOPE_IDENTITY()

			SELECT @Id AS Id
			
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
