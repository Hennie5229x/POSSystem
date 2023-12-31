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
CREATE PROCEDURE [dbo].[stpCompanyInformation_Update]
	-- PARAMETERS	
		@CompanyName		NVARCHAR(250),
		@BranchName			NVARCHAR(250),
		@BillToAddress		NVARCHAR(MAX),
		@ShipToAddress		NVARCHAR(MAX),
		@ContactPersonName	NVARCHAR(100),
		@Telephone			NVARCHAR(50) ,
		@CellPhone			NVARCHAR(50) ,
		@Email				NVARCHAR(250),
		@VATNumber			NVARCHAR(50) ,
		@CompanyLogo		NVARCHAR(MAX),--IMAGE
		@CurrencySign		NVARCHAR(10),
		@LogoImageName		NVARCHAR(250),
		@ClearImage			BIT,
		@NewImage			BIT = 0
		

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
				
				IF(@ClearImage = 1)
				BEGIN
						UPDATE CompanyInformation
						SET [CompanyName]			= @CompanyName		
						   ,[BranchName] 			= @BranchName			
						   ,[BillToAddress] 		= @BillToAddress		
						   ,[ShipToAddress] 		= @ShipToAddress		
						   ,[ContactPersonName] 	= @ContactPersonName	
						   ,[Telephone] 			= @Telephone			
						   ,[CellPhone]				= @CellPhone			
						   ,[Email] 				= @Email				
						   ,[VATNumber] 			= @VATNumber
						   ,[CurrencySign] 			= @CurrencySign
						   ,Logo					= NULL
						   ,LogoImageName			= NULL
				END
				ELSE IF(@NewImage = 1)
				BEGIN
					UPDATE CompanyInformation
							SET [CompanyName]			= @CompanyName		
							   ,[BranchName] 			= @BranchName			
							   ,[BillToAddress] 		= @BillToAddress		
							   ,[ShipToAddress] 		= @ShipToAddress		
							   ,[ContactPersonName] 	= @ContactPersonName	
							   ,[Telephone] 			= @Telephone			
							   ,[CellPhone]				= @CellPhone			
							   ,[Email] 				= @Email				
							   ,[VATNumber] 			= @VATNumber
							   ,[CurrencySign] 			= @CurrencySign
							   ,Logo					= @CompanyLogo
							   ,LogoImageName			= @LogoImageName
				END
				ELSE
				BEGIN
				BEGIN
					UPDATE CompanyInformation
							SET [CompanyName]			= @CompanyName		
							   ,[BranchName] 			= @BranchName			
							   ,[BillToAddress] 		= @BillToAddress		
							   ,[ShipToAddress] 		= @ShipToAddress		
							   ,[ContactPersonName] 	= @ContactPersonName	
							   ,[Telephone] 			= @Telephone			
							   ,[CellPhone]				= @CellPhone			
							   ,[Email] 				= @Email				
							   ,[VATNumber] 			= @VATNumber
							   ,[CurrencySign] 			= @CurrencySign
							   --,Logo					= @CompanyLogo
							   --,LogoImageName			= @LogoImageName
				END
				END

				-----------------------------------------
				---------History Log---------------------
				-----------------------------------------

				--DECLARE @To NVARCHAR(MAX) = 'Item Code: '+ISNULL(@ItemCode,'')
				--DECLARE @Des NVARCHAR(MAX) = 'Stock Management: New item added '+ISNULL(@ItemCode,'')

				--EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
				--							@Action = 'Insert',
				--							@Description = @Des,
				--							@FromValue = '',
				--							@ToValue = @To,											
				--							@FieldId = @Id
				
			
			
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
