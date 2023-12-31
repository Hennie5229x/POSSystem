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
CREATE PROCEDURE [dbo].[stpPOS_Search_Values]
	-- PARAMETERS
	@ItemId INT	
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION			
		
		DECLARE @Currecny NVARCHAR(50)
		SELECT	@Currecny = CurrencySign
		FROM	CompanyInformation

		SELECT	ItemName,
				@Currecny + CAST(DiscountedPriceIncl AS NVARCHAR(50)) AS Price_Cur,
				DiscountedPriceIncl,
				@Currecny AS Currency
		FROM	ItemMaster
		WHERE	Id = @ItemId

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
