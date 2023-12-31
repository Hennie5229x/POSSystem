USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Select]
	
	@ItemCode NVARCHAR(50),
	@ItemName NVARCHAR(50),
	@ReceiveDate DATETIME,
	@SupplierName NVARCHAR(50),
	@ReceivedByUser NVARCHAR(100),
	@InvoiceNum NVARCHAR(50)

AS
BEGIN	
	SET NOCOUNT ON;  

	SET @ItemCode = ISNULL(@ItemCode, '')
	SET @ItemName = ISNULL(@ItemName, '')
	SET @SupplierName = ISNULL(@SupplierName, '')
	SET @ReceivedByUser = ISNULL(@ReceivedByUser, '')
	SET @InvoiceNum = ISNULL(@InvoiceNum,'')

	DECLARE @Date DATETIME = NULL

	IF(@ReceiveDate = '' AND @ItemCode = '' AND @ItemName = '' AND @SupplierName = '' AND @ReceivedByUser = '' AND @InvoiceNum = '')
	BEGIN
		SELECT      Id, 
					ItemCode, 
					ItemName, 
					ReceiveDate, 
					QuantityReceived, 
					PricePurchaseExcl, 
					PricePurchaseIncl, 
					SupplierName,
					ReceivedByUser,
					InvoiceNum
		FROM        viwStockReceive
		ORDER BY	ReceiveDate DESC
	END
	ELSE IF(ISNULL(@ReceiveDate,'') = ISNULL(@Date,''))
	BEGIN
		SELECT      Id, 
					ItemCode, 
					ItemName, 
					ReceiveDate, 
					QuantityReceived, 
					PricePurchaseExcl, 
					PricePurchaseIncl, 
					SupplierName,
					ReceivedByUser,
					InvoiceNum
		FROM        viwStockReceive
		WHERE		ISNULL(ItemCode,'') LIKE '%'+@ItemCode+'%'
		AND			ISNULL(ItemName,'') LIKE '%'+@ItemName+'%'
		AND			ISNULL(SupplierName,'') LIKE '%'+@SupplierName+'%'
		AND			ISNULL(ReceivedByUser,'') LIKE '%'+@ReceivedByUser+'%'
		AND			ISNULL(InvoiceNum,'') LIKE '%'+@InvoiceNum+'%'
		ORDER BY	ReceiveDate DESC
	END
	ELSE
	BEGIN
		SELECT      Id, 
					ItemCode, 
					ItemName, 
					ReceiveDate, 
					QuantityReceived, 
					PricePurchaseExcl, 
					PricePurchaseIncl, 
					SupplierName,
					ReceivedByUser,
					InvoiceNum
		FROM        viwStockReceive
		WHERE		ISNULL(ItemCode,'') LIKE '%'+@ItemCode+'%'
		AND			ISNULL(ItemName,'') LIKE '%'+@ItemName+'%'
		AND			ISNULL(SupplierName,'') LIKE '%'+@SupplierName+'%'
		AND			ISNULL(ReceivedByUser,'') LIKE '%'+@ReceivedByUser+'%'
		AND			ISNULL(InvoiceNum,'') LIKE '%'+@InvoiceNum+'%'
		AND			CAST(ReceiveDate AS DATE) = CAST(@ReceiveDate AS DATE)
		ORDER BY	ReceiveDate DESC
	END

		
END
GO
