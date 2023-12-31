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
CREATE PROCEDURE [dbo].[stpSuppliers_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@CompanyName NVARCHAR(100),
	@SupplierName NVARCHAR(100),
	@BillToAddress NVARCHAR(MAX),
	@ShipToAddress NVARCHAR(MAX),
	@BillingInformation NVARCHAR(MAX),
	@ContactPerson NVARCHAR(100),
	@Telephone NVARCHAR(250),
	@CellPhone NVARCHAR(50),
	@Email NVARCHAR(250),
	@VATNumber NVARCHAR(50)


AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF EXISTS	(
						SELECT	1
						FROM	Suppliers
						WHERE	SupplierName = @SupplierName
						OR		CompanyName = @CompanyName
					)
		BEGIN
			DECLARE @msg NVARCHAR(MAX) = ISNULL(@SupplierName,'')+' / '+ISNULL(@CompanyName,'')+' already exists.'
			RAISERROR(@msg,11,1)
		END
		ELSE
		BEGIN
		
			DECLARE @Id INT	

			INSERT INTO [dbo].[Suppliers]
		   (
			[SupplierName]
		   ,[BillToAddress]
		   ,[ShipToAddress]
		   ,[BillingInformation]
		   ,[ContactPerson]
		   ,[Telephone]
		   ,[CellPhone]
		   ,[Email]
		   ,[VATNumber]
		   ,CompanyName
		   )
			VALUES
		   (
		    @SupplierName
		   ,@BillToAddress
		   ,@ShipToAddress
		   ,@BillingInformation
		   ,@ContactPerson
		   ,@Telephone
		   ,@CellPhone
		   ,@Email
		   ,@VATNumber
		   ,@CompanyName
		   )			
			SET @Id = SCOPE_IDENTITY()

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = 'Supplier: '+ISNULL(@SupplierName,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = 'Suppliers: New Supplier created',
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
