USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[viwStockReceive] AS

SELECT			 A.Id
				,B.ItemCode
				,B.ItemName
				,A.ReceiveDate
				,A.QuantityReceived
				,A.PricePurchaseExcl
				,A.PricePurchaseIncl
				,C.SupplierName
				,ISNULL(D.[Name],'') + ' ' + ISNULL(D.Surname,'') AS ReceivedByUser
				,InvoiceNum
  FROM			StockReceive A
  JOIN			ItemMaster B ON B.Id = A.ItemId
  LEFT JOIN		Suppliers C ON C.Id = A.SupplierId
  LEFT JOIN		Users D ON CAST(D.Id AS NVARCHAR(50)) = A.ReceivedByUserId
GO
