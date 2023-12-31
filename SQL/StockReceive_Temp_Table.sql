USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockReceive_Temp](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ItemId] [int] NOT NULL,
	[ReceiveDate] [datetime] NOT NULL,
	[QuantityReceived] [decimal](19, 6) NOT NULL,
	[PricePurchaseExcl] [decimal](19, 2) NOT NULL,
	[PricePurchaseIncl] [decimal](19, 2) NOT NULL,
	[SupplierId] [int] NULL,
	[ReceivedByUserId] [nvarchar](50) NOT NULL,
	[InvoiceNum] [nvarchar](50) NULL,
 CONSTRAINT [PK_StockReceive_Temp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
