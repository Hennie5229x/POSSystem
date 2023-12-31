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
CREATE PROCEDURE [dbo].[stpPOS_Messages]
	
	
AS
BEGIN
	
	SET NOCOUNT ON;  

	DECLARE @Messages TABLE ([Message] NVARCHAR(MAX))

	--Low Quantity
	INSERT INTO @Messages
	SELECT		ItemName + ' stock running low (Qty: '+CAST(ISNULL(CAST(QuantityAvailable AS DECIMAL(19,2)),0) AS NVARCHAR(50))+' '+B.UoM+')'
	FROM		ItemMaster A
	JOIN		UoM B ON B.Id = A.UoMId
	WHERE		ISNULL(QuantityAvailable,0) <= QuantityRequestMin

	--Open Sales
	INSERT INTO @Messages
	SELECT		CAST(COUNT(A.Id)AS NVARCHAR(50))+ ' Open Sale on Terminal: ' + B.TerminalName
	FROM		DocumentTransactionsHeader A
	JOIN		Terminals B ON B.Id = A.TerminalId
	WHERE		DocumentStatusId = 1 --Open
	GROUP BY	B.TerminalName	
	
	--Suspended Sales
	INSERT INTO @Messages
	SELECT		CAST(COUNT(A.Id)AS NVARCHAR(50))+ ' Suspended Sale on Terminal: ' + B.TerminalName
	FROM		DocumentTransactionsHeader A
	JOIN		Terminals B ON B.Id = A.TerminalId
	WHERE		DocumentStatusId = 2 --Suspended
	GROUP BY	B.TerminalName

	--Promotion Starting Soon (5 Days ahead of time, not on the day or the day before)
	INSERT INTO @Messages
	SELECT	'Promotion: '+ ISNULL(PromoName,'')+' starting soon '+CONVERT(NVARCHAR(10), DateFrom, 23)
	FROM	Promotions
	WHERE	DATEADD(DAY, -5, DateFrom) <= CAST(GETDATE() AS DATE)
	AND		DATEADD(DAY, -1, DateFrom) > CAST(GETDATE() AS DATE)

	--Promotion Starting Tomorrow
	INSERT INTO @Messages
	SELECT	'Promotion: '+ ISNULL(PromoName,'')+' starting tomorrow.'
	FROM	Promotions
	WHERE	DATEADD(DAY, -1, DateFrom) = CAST(GETDATE() AS DATE)

	--Promotion Started Today
	INSERT INTO @Messages
	SELECT	'Promotion: '+ ISNULL(PromoName,'')+' started today.'
	FROM	Promotions
	WHERE	DateFrom = CAST(GETDATE() AS DATE)

	--Promotion Ending Soon (5 Days ahead of time except for on the day and the next day)
	INSERT INTO @Messages
	SELECT	'Promotion: '+ ISNULL(PromoName,'')+' ending soon '+CONVERT(NVARCHAR(10), DateFrom, 23)
	FROM	Promotions
	WHERE	DateFrom <= CAST(GETDATE() AS DATE)
	AND		DATEADD(DAY, -5, DateTo) <= CAST(GETDATE() AS DATE)
	AND		DATEADD(DAY, -1, DateTo) > CAST(GETDATE() AS DATE)
	AND		DateTo > CAST(GETDATE() AS DATE)

	--Promotion Ending Tomorrow
	INSERT INTO @Messages
	SELECT	'Promotion: '+ ISNULL(PromoName,'')+' ending tomorrow.'
	FROM	Promotions
	WHERE	DATEADD(DAY, -1, DateTo) = CAST(GETDATE() AS DATE)

	--Promotion Ending Today
	INSERT INTO @Messages
	SELECT	'Promotion: '+ ISNULL(PromoName,'')+' ending today.'
	FROM	Promotions
	WHERE	DateTo = CAST(GETDATE() AS DATE)

	--System Discount on Item Master
	INSERT INTO @Messages
	SELECT	'WARNING: Item ' + ISNULL(ItemName,'') + ' has a System Discount of '+CAST(CAST(DiscountPercentage AS DECIMAL(19,2)) AS NVARCHAR(10))+'%'
	FROM	ItemMaster
	WHERE	Active = 1 --True
	AND		ISNULL(DiscountPercentage,0) > 0


	-----------------------
	SELECT	[Message]
	FROM	@Messages
	

END
GO
