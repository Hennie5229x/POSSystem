USE [POSSystem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyInformation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [nvarchar](250) NOT NULL,
	[BranchName] [nvarchar](250) NULL,
	[BillToAddress] [nvarchar](max) NULL,
	[ShipToAddress] [nvarchar](max) NULL,
	[ContactPersonName] [nvarchar](100) NULL,
	[Telephone] [nvarchar](50) NULL,
	[CellPhone] [nvarchar](50) NULL,
	[Email] [nvarchar](250) NULL,
	[VATNumber] [nvarchar](50) NULL,
	[CurrencySign] [nvarchar](10) NULL,
	[Logo] [nvarchar](max) NULL,
	[LogoImageName] [nvarchar](250) NULL,
 CONSTRAINT [PK_CompanyInformation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
