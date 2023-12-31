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
CREATE PROCEDURE [dbo].[stpStockReceive_Temp_Select]
		

AS
BEGIN	
	SET NOCOUNT ON;  
	/*
	{Binding Id}" Width="160" H
	{Binding ItemCode}" Width="
	{Binding ItemName}" Width="
	{Binding QuantityReceived}"
	{Binding PricePurchaseExcl}
	{Binding PricePurchaseIncl}
	{Binding ReceivedByUser}" 
	*/
	SELECT			 A.Id
					,B.ItemCode
					,B.ItemName					
					,A.QuantityReceived
					,A.PricePurchaseExcl
					,A.PricePurchaseIncl					
					,ISNULL(D.[Name],'') + ' ' + ISNULL(D.Surname,'') AS ReceivedByUser					
	FROM			StockReceive_Temp A
	JOIN			ItemMaster B ON B.Id = A.ItemId
	LEFT JOIN		Suppliers C ON C.Id = A.SupplierId
	LEFT JOIN		Users D ON CAST(D.Id AS NVARCHAR(50)) = A.ReceivedByUserId

		
END
GO
