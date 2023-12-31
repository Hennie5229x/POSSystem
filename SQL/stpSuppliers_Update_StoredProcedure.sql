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
CREATE PROCEDURE [dbo].[stpSuppliers_Update]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	
	@Id INT,
	@BillToAddress NVARCHAR(MAX),
	@ShipToAddress NVARCHAR(MAX),
	@BillingInformation NVARCHAR(MAX),
	@ContactPerson NVARCHAR(100),
	@Telephone NVARCHAR(250),
	@CellPhone NVARCHAR(50),
	@Email NVARCHAR(250),
	@VATNumber NVARCHAR(50),
	@SupplierName NVARCHAR(100)


AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION
		
		--RAISERROR(@SupplierName,11,1)

		/*-- History Log Params --*/
		DECLARE @Old_SupplierName NVARCHAR(100),
				@Old_BillToAddress NVARCHAR(MAX),
				@Old_ShipToAddress NVARCHAR(MAX),
				@Old_BillingInformation NVARCHAR(MAX),
				@Old_ContactPerson NVARCHAR(100),
				@Old_Telephone NVARCHAR(250),
				@Old_CellPhone NVARCHAR(50),
				@Old_Email NVARCHAR(250),
				@Old_VATNumber NVARCHAR(50)

		SELECT	@Old_SupplierName = SupplierName,
				@Old_BillToAddress = BillToAddress,
				@Old_ShipToAddress = ShipToAddress,
				@Old_BillingInformation = BillingInformation,
				@Old_ContactPerson = ContactPerson,
				@Old_Telephone = Telephone,
				@Old_CellPhone = CellPhone,
				@Old_Email = Email,
				@Old_VATNumber = VATNumber
		FROM	Suppliers
		WHERE	Id = @Id
		/*	---------------------	*/

		

		UPDATE	[dbo].[Suppliers]		
		SET		 [BillToAddress] = 			@BillToAddress
				,[ShipToAddress] = 			@ShipToAddress
				,[BillingInformation] = 	@BillingInformation
				,[ContactPerson] = 			@ContactPerson
				,[Telephone] = 				@Telephone
				,[CellPhone] = 				@CellPhone
				,[Email] = 					@Email
				,[VATNumber] = 				@VATNumber
				,SupplierName =				@SupplierName
		WHERE	Id = @Id		   
		  
		---------------------------------------
		-------History Log---------------------
		---------------------------------------
		DECLARE @Description NVARCHAR(MAX) = 'Suppliers: '+ISNULL(@SupplierName,'')+' updated'
		DECLARE @To NVARCHAR(MAX) = ''
		DECLARE @From NVARCHAR(MAX) = ''

		IF(ISNULL(@BillToAddress,'') <> ISNULL(@Old_BillToAddress,''))
		BEGIN
			SET @To = 'Bill To Address: '+ISNULL(@BillToAddress,'')
			SET @From = 'Bill To Address: '+ISNULL(@Old_BillToAddress,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@ShipToAddress,'') <> ISNULL(@Old_ShipToAddress,''))
		BEGIN
			SET @To = 'Ship To Address: '+ISNULL(@ShipToAddress,'')
			SET @From = 'Ship To Address: '+ISNULL(@Old_ShipToAddress,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@BillingInformation,'') <> ISNULL(@Old_BillingInformation,''))
		BEGIN
			SET @To = 'Billing Information: '+ISNULL(@BillingInformation,'')
			SET @From = 'Billing Information: '+ISNULL(@Old_BillingInformation,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@ContactPerson,'') <> ISNULL(@Old_ContactPerson,''))
		BEGIN
			SET @To = 'Contact Person: '+ISNULL(@ContactPerson,'')
			SET @From = 'Contact Person: '+ISNULL(@Old_ContactPerson,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@Telephone,'') <> ISNULL(@Old_Telephone,''))
		BEGIN
			SET @To = 'Telephone: '+ISNULL(@Telephone,'')
			SET @From = 'Telephone: '+ISNULL(@Old_Telephone,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@CellPhone,'') <> ISNULL(@Old_CellPhone,''))
		BEGIN
			SET @To = 'Cell Phone: '+ISNULL(@CellPhone,'')
			SET @From = 'Cell Phone: '+ISNULL(@Old_CellPhone,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@Email,'') <> ISNULL(@Old_Email,''))
		BEGIN
			SET @To = 'Email: '+ISNULL(@Email,'')
			SET @From = 'Email: '+ISNULL(@Old_Email,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@VATNumber,'') <> ISNULL(@Old_VATNumber,''))
		BEGIN
			SET @To = 'VAT Number: '+ISNULL(@VATNumber,'')
			SET @From = 'VAT Number: '+ISNULL(@Old_VATNumber,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@SupplierName,'') <> ISNULL(@Old_SupplierName,''))
		BEGIN
			SET @To = 'Supplier Name: '+ISNULL(@SupplierName,'')
			SET @From = 'Supplier Name: '+ISNULL(@Old_SupplierName,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
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
