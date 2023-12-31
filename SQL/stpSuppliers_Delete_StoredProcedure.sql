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
CREATE PROCEDURE [dbo].[stpSuppliers_Delete]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@Id INT


AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @SupplierName NVARCHAR(100)
		SELECT	@SupplierName = SupplierName
		FROM	Suppliers
		WHERE	Id = @Id

		IF EXISTS	(
						SELECT	1
						FROM	ItemMaster
						WHERE	SupplierId = @Id
					)
		BEGIN			
			RAISERROR('Cannot delete supplier because it is in use',11,1)
		END
		ELSE
		BEGIN		
			
			DELETE
			FROM	Suppliers
			WHERE	Id = @Id

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = 'Supplier: '+ISNULL(@SupplierName,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Delete',
										@Description = 'Suppliers: Supplier removed',
										@FromValue = '',
										@ToValue = @To,
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
