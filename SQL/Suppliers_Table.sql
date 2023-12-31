USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Suppliers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [nvarchar](100) NOT NULL,
	[SupplierName] [nvarchar](100) NULL,
	[BillToAddress] [nvarchar](max) NULL,
	[ShipToAddress] [nvarchar](max) NULL,
	[BillingInformation] [nvarchar](max) NULL,
	[ContactPerson] [nvarchar](100) NULL,
	[Telephone] [nvarchar](50) NULL,
	[CellPhone] [nvarchar](50) NULL,
	[Email] [nvarchar](250) NULL,
	[VATNumber] [nvarchar](50) NULL,
 CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
