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
CREATE PROCEDURE [dbo].[stpCompanyInformation_Select]
	-- PARAMETERS	
			

AS
BEGIN
	SET NOCOUNT ON;    
				
					
		SELECT	[Id]
				,[CompanyName]
				,[BranchName]
				,[BillToAddress]
				,[ShipToAddress]
				,[ContactPersonName]
				,[Telephone]
				,[CellPhone]
				,[Email]
				,[VATNumber]				
				,[CurrencySign]
				,Logo
				,LogoImageName
		 FROM	 [POSSystem].[dbo].[CompanyInformation]
			
		
END
GO
