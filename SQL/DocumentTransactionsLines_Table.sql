USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentTransactionsLines](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[HeaderId] [int] NOT NULL,
	[ItemId] [int] NOT NULL,
	[Quantity] [decimal](19, 6) NOT NULL,
	[QuantityOpen] [decimal](19, 6) NULL,
	[PriceUnitVatIncl] [decimal](19, 6) NOT NULL,
	[LineStatus] [int] NOT NULL,
	[LineType] [int] NULL,
	[LineTotal] [decimal](19, 6) NOT NULL,
	[ItemMaster_Price] [decimal](19, 6) NULL,
	[ItemMasterDiscountPercentage] [decimal](19, 6) NULL,
	[PriceChange_Price] [decimal](19, 6) NULL,
	[Return_Restock] [bit] NULL,
	[PriceChange] [bit] NULL,
	[Promotion] [bit] NULL,
	[PromotionId] [int] NULL,
 CONSTRAINT [PK_DocumentTransactionsLines] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
