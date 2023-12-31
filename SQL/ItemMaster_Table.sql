USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ItemMaster](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ItemCode] [nvarchar](50) NULL,
	[ItemName] [nvarchar](50) NULL,
	[QuantityAvailable] [decimal](19, 6) NULL,
	[QuantityRequestMin] [decimal](19, 6) NULL,
	[QuantityRequestMax] [decimal](19, 6) NULL,
	[QuantityRequested] [decimal](19, 6) NULL,
	[PriceSellExclVat] [decimal](19, 2) NULL,
	[PricePurchaseExclVat] [decimal](19, 2) NULL,
	[DiscountPercentage] [decimal](19, 6) NULL,
	[DiscountedPriceIncl] [decimal](19, 2) NULL,
	[ProfitMargin] [decimal](19, 6) NULL,
	[Active] [bit] NULL,
	[Barcode] [nvarchar](100) NULL,
	[SupplierId] [int] NULL,
	[TaxCode] [int] NULL,
	[UoMId] [int] NULL,
	[TimeStampCreate] [datetime] NULL,
	[TimeStampChange] [datetime] NULL,
	[ItemGroupId] [int] NULL,
 CONSTRAINT [PK_ItemMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20201020-183443] ON [dbo].[ItemMaster]
(
	[Barcode] ASC,
	[ItemCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
