USE [master]
GO
/****** Object:  Database [POSSystem]    Script Date: 2023/11/25 16:02:19 ******/
CREATE DATABASE [POSSystem]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'POSSystem', FILENAME = N'C:\Data\DB\POSSystem.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'POSSystem_log', FILENAME = N'C:\Data\DB\POSSystem_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [POSSystem] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [POSSystem].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [POSSystem] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [POSSystem] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [POSSystem] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [POSSystem] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [POSSystem] SET ARITHABORT OFF 
GO
ALTER DATABASE [POSSystem] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [POSSystem] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [POSSystem] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [POSSystem] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [POSSystem] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [POSSystem] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [POSSystem] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [POSSystem] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [POSSystem] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [POSSystem] SET  DISABLE_BROKER 
GO
ALTER DATABASE [POSSystem] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [POSSystem] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [POSSystem] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [POSSystem] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [POSSystem] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [POSSystem] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [POSSystem] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [POSSystem] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [POSSystem] SET  MULTI_USER 
GO
ALTER DATABASE [POSSystem] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [POSSystem] SET DB_CHAINING OFF 
GO
ALTER DATABASE [POSSystem] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [POSSystem] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [POSSystem] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [POSSystem] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [POSSystem] SET QUERY_STORE = OFF
GO
USE [POSSystem]
GO
/****** Object:  User [POSUser]    Script Date: 2023/11/25 16:02:19 ******/
CREATE USER [POSUser] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [POSUser]
GO
/****** Object:  UserDefinedFunction [dbo].[fnItemMasterCompoundQuantity]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fnItemMasterCompoundQuantity]
(	
	@ItemMasterId INT
)

RETURNS
@Table TABLE 
(
	ItemMasterId INT, 
	ItemCode NVARCHAR(50), 
	ItemName NVARCHAR(50),
	ItemIdCompound INT,
	ItemCodeCompound NVARCHAR(50), 
	ItemNameCompound NVARCHAR(50), 
	CompoundQty DECIMAL(19, 6)
)
AS
BEGIN 
	
	DECLARE @Items TABLE	(
								ItemCode NVARCHAR(50), 
								BaseCode NVARCHAR(50), 
								CompoundQty DECIMAL(19,6)
							)
	
	;WITH
	  cte (ItemId, Qty, [Level], CompoundQty, BaseItem)
	  AS
	  (
		SELECT  Id, QuantityAvailable, 1, CAST(1.00 AS DECIMAL(19,6)), Id
		FROM	ItemMaster    
		UNION ALL
		SELECT	A.HeaderId, A.Quantity, Level + 1, CAST(A.Quantity * B.CompoundQty AS DECIMAL(19,6)), B.BaseItem
		FROM	ItemMasterCompounds A
		JOIN	cte B ON B.ItemId = A.ItemMasterItemId
	  )
	
	INSERT INTO @Items
	SELECT	ItemId, BaseItem, CompoundQty
	FROM	cte
	WHERE	BaseItem NOT IN (SELECT HeaderId FROM ItemMasterCompounds)
	
	INSERT INTO @Table
	SELECT		B.Id AS ItemMasterId, B.ItemCode, B.ItemName, C.Id, C.ItemCode, C.ItemName, A.CompoundQty
	FROM		@Items A
	JOIN		ItemMaster B ON B.Id = A.ItemCode
	JOIN		ItemMaster C ON C.Id = A.BaseCode
	WHERE		A.ItemCode = @ItemMasterId
	ORDER BY	B.Id

	RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[fnPasswordHash]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnPasswordHash]
(
	-- Add the parameters for the function here
	@Password NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	
	DECLARE @HashPass varbinary(64)
	SET @HashPass = HASHBYTES('SHA2_256', @Password)

	RETURN CONVERT(VARCHAR(1000), @HashPass, 1)

END
GO
/****** Object:  Table [dbo].[ItemGroups]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ItemGroups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GroupName] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](250) NULL,
 CONSTRAINT [PK_ItemGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[viwItemGroups_Buttons]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[viwItemGroups_Buttons]  AS
	
	SELECT	ROW_NUMBER() OVER(ORDER BY GroupName ASC) AS RowNum,
			Id,
			GroupName 
	FROM	ItemGroups
GO
/****** Object:  Table [dbo].[ItemButtons]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ItemButtons](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ItemId] [int] NOT NULL,
	[ButtonText] [nvarchar](50) NOT NULL,
	[Font] [nvarchar](50) NOT NULL,
	[FontSize] [int] NOT NULL,
	[Hex] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ItemButtons] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ItemMaster]    Script Date: 2023/11/25 16:02:19 ******/
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
/****** Object:  View [dbo].[viwItems_Buttons]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[viwItems_Buttons]  AS


	SELECT		ROW_NUMBER() OVER(ORDER BY ISNULL(B.ButtonText, A.ItemName) ASC) AS RowNum,
				A.ItemGroupId,
				ISNULL(B.ItemId, A.Id) AS ItemId,
				ISNULL(B.ButtonText, A.ItemName) AS ButtonText,
				ISNULL(B.Font, 'Segoe UI') AS Font,
				ISNULL(B.FontSize, 20) AS FontSize,
				ISNULL(B.Hex, '#DDDDDD') AS Hex
	FROM		ItemMaster A
	LEFT JOIN	ItemButtons B ON B.ItemId = A.Id
	WHERE		A.Active = 1

GO
/****** Object:  Table [dbo].[ItemMasterCompounds]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ItemMasterCompounds](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[HeaderId] [int] NOT NULL,
	[ItemMasterItemId] [int] NOT NULL,
	[Quantity] [decimal](19, 6) NOT NULL,
 CONSTRAINT [PK_ItemMasterCompounds] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaxCodes]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxCodes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TaxCode] [nvarchar](50) NULL,
	[VAT] [decimal](19, 6) NULL,
 CONSTRAINT [PK_TaxCodes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UoM]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UoM](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UoM] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NULL,
 CONSTRAINT [PK_UoM] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Suppliers]    Script Date: 2023/11/25 16:02:19 ******/
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
/****** Object:  View [dbo].[viwItemMaster]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[viwItemMaster]
AS
		SELECT		 A.[Id]
					,[ItemCode]
					,[ItemName]
					,QuantityAvailable AS QuantityAvailable
					,[QuantityRequestMin]
					,[QuantityRequestMax]
					,[QuantityRequested]					
					,FORMAT(ROUND([PriceSellExclVat],2),'N2') AS [PriceSellExclVat]
					,FORMAT(ROUND((PriceSellExclVat + C.VAT/100.00 * PriceSellExclVat),2),'N2') AS PriceSellInclVat
					,FORMAT(ROUND([PricePurchaseExclVat],2),'N2') AS [PricePurchaseExclVat]
					,FORMAT(ROUND(DiscountedPriceIncl - DiscountPercentage/100.00 * DiscountedPriceIncl, 2),'N2') AS DiscountPriceSellIncl
					--,FORMAT(ROUND((PriceSellExclVat - DiscountPercentage/100.00 * PriceSellExclVat),2),'N2') AS DiscountPriceSellExcl
					--,FORMAT(ROUND((PriceSellExclVat - DiscountPercentage/100.00 * PriceSellExclVat) + (C.VAT/100.00 * (PriceSellExclVat - DiscountPercentage/100.00 * PriceSellExclVat)),2),'N2') AS DiscountPriceSellIncl
					,FORMAT(ROUND((DiscountedPriceIncl - C.VAT/100.00 * DiscountedPriceIncl),2),'N2') AS DiscountPriceSellExcl					
					,[DiscountPercentage]
					,ProfitMargin
					,CASE WHEN [Active] = 1 THEN 'Active' ELSE 'Inactive' END AS [Active]
					,[Barcode]
					,B.SupplierName AS Supplier
					,FORMAT(ROUND(C.VAT,2),'N2') AS Vat
					,E.UoM
					,F.GroupName AS ItemGroup
					,CASE WHEN G.HeaderId IS NULL THEN 'No' ELSE 'Yes' END AS CompoundItem
		FROM		[ItemMaster] A
		LEFT JOIN	Suppliers B ON B.Id = A.SupplierId
		LEFT JOIN	TaxCodes C ON C.Id = A.TaxCode		
		LEFT JOIN	UoM E ON E.Id = A.UoMId
		LEFT JOIN	ItemGroups F ON F.Id = A.ItemGroupId
		LEFT JOIN	(SELECT DISTINCT HeaderId FROM ItemMasterCompounds) G ON G.HeaderId = A.Id
		
GO
/****** Object:  Table [dbo].[Users]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [uniqueidentifier] NOT NULL,
	[LoginName] [nvarchar](100) NOT NULL,
	[Password] [nvarchar](250) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Surname] [nvarchar](100) NULL,
	[Phone] [nvarchar](50) NULL,
	[Email] [nvarchar](250) NULL,
	[Active] [bit] NOT NULL,
	[Pin] [nchar](4) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_Pin] UNIQUE NONCLUSTERED 
(
	[Pin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[viwUsers]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viwUsers] AS

SELECT      Id, LoginName, Password, Name, Surname, Phone, Email, Active, ISNULL(Name,'')+' '+ISNULL(Surname,'') AS FullName
FROM        Users
GO
/****** Object:  Table [dbo].[StockReceive]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockReceive](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ItemId] [int] NOT NULL,
	[ReceiveDate] [datetime] NOT NULL,
	[QuantityReceived] [decimal](19, 6) NOT NULL,
	[PricePurchaseExcl] [decimal](19, 2) NOT NULL,
	[PricePurchaseIncl] [decimal](19, 2) NOT NULL,
	[SupplierId] [int] NULL,
	[ReceivedByUserId] [nvarchar](50) NOT NULL,
	[InvoiceNum] [nvarchar](50) NULL,
 CONSTRAINT [PK_StockReceive] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[viwStockReceive]    Script Date: 2023/11/25 16:02:19 ******/
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
/****** Object:  Table [dbo].[CashUp]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CashUp](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NULL,
	[StatusId] [int] NULL,
	[ShiftId] [int] NULL,
 CONSTRAINT [PK_CashUp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CashUpLines]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CashUpLines](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[HeaderId] [int] NULL,
	[DenominationId] [int] NULL,
	[DenominationCount] [int] NULL,
 CONSTRAINT [PK_CashUpLines] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CashUpStatus]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CashUpStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_CashUpStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompanyInformation]    Script Date: 2023/11/25 16:02:19 ******/
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
/****** Object:  Table [dbo].[Denominations]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Denominations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Value] [decimal](19, 2) NOT NULL,
	[TypeId] [int] NOT NULL,
 CONSTRAINT [PK_Denominations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DenominationTypes]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DenominationTypes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DenominationTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentTransactionsHeader]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentTransactionsHeader](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DocumentNumber] [nvarchar](50) NOT NULL,
	[DocumentStatusId] [int] NOT NULL,
	[DocumentTypeId] [int] NULL,
	[Date] [datetime] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[ShiftId] [int] NULL,
	[TerminalId] [int] NULL,
	[TenderedCashTotal] [decimal](19, 6) NULL,
	[TenderedCardTotal] [decimal](19, 6) NULL,
	[TenderedTotal] [decimal](19, 6) NULL,
	[DocumentTotal] [decimal](19, 6) NULL,
	[ReturnDocNum] [nvarchar](50) NULL,
 CONSTRAINT [PK_TransactionHeader] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentTransactionsHeaderStatus]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentTransactionsHeaderStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DocumentTransactionsHeaderStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentTransactionsLines]    Script Date: 2023/11/25 16:02:19 ******/
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
/****** Object:  Table [dbo].[DocumentTransactionsLinesStatus]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentTransactionsLinesStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DocumentTransactionsLinesStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentTransactionsLinesTypes]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentTransactionsLinesTypes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DocumentTransactionLineTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentType]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DocumentType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HistoryLog]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HistoryLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Datetime] [datetime] NOT NULL,
	[UserId] [nvarchar](50) NULL,
	[Action] [nvarchar](50) NULL,
	[Description] [nvarchar](max) NULL,
	[FromValue] [nvarchar](max) NULL,
	[ToValue] [nvarchar](max) NULL,
	[FieldId] [nvarchar](50) NULL,
 CONSTRAINT [PK_HistoryLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Objects]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Objects](
	[Id] [uniqueidentifier] NOT NULL,
	[ObjectName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Objects] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Printers]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Printers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PrinterName] [nvarchar](50) NOT NULL,
	[PrinterDescription] [nvarchar](100) NULL,
 CONSTRAINT [PK_Printers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Promotions]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Promotions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PromoName] [nvarchar](50) NULL,
	[PromoDescription] [nvarchar](255) NULL,
	[DateFrom] [date] NULL,
	[DateTo] [date] NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_Promotions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PurchaseOrderHeader]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PurchaseOrderHeader](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PONumber] [nvarchar](50) NOT NULL,
	[Date] [datetime] NULL,
	[SupplierId] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[Notes] [nvarchar](max) NULL,
 CONSTRAINT [PK_PurchaseOrderHeader] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PurchaseOrderLines]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PurchaseOrderLines](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[HeaderId] [int] NOT NULL,
	[ItemCode] [nvarchar](50) NULL,
	[Quantity] [decimal](19, 6) NULL,
 CONSTRAINT [PK_PurchaseOrderLines] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PurchaseOrderStatus]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PurchaseOrderStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_PurchaseOrderStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Returns]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Returns](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReturnType] [nvarchar](50) NOT NULL,
	[OriginalDocNum] [nvarchar](50) NULL,
	[OriginalDocId] [int] NULL,
	[UnlinkedHeaderId] [int] NULL,
	[ItemId] [int] NOT NULL,
	[Qty] [decimal](19, 6) NOT NULL,
	[PriceSell] [decimal](19, 6) NOT NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_Returns] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReturnsStatus]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReturnsStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[StatusName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ReturnsStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleGroupObjects]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleGroupObjects](
	[ObjectId] [uniqueidentifier] NOT NULL,
	[RoleGroupId] [int] NOT NULL,
 CONSTRAINT [PK_RoleGroupObjects] PRIMARY KEY CLUSTERED 
(
	[ObjectId] ASC,
	[RoleGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleGroups]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleGroups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
 CONSTRAINT [PK_RoleGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleGroupUsers]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleGroupUsers](
	[UserId] [uniqueidentifier] NOT NULL,
	[RoleGroupId] [int] NOT NULL,
 CONSTRAINT [PK_RoleGroupUsers] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Shifts]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shifts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[ShiftStatusId] [int] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[StartFloat] [decimal](19, 6) NULL,
	[CashUpStatus] [int] NULL,
	[CashUpOut] [decimal](19, 6) NULL,
	[CardMachineTotal] [decimal](19, 6) NULL,
 CONSTRAINT [PK_Shifts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShiftStatus]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShiftStatus](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ShiftStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StockReceive_Temp]    Script Date: 2023/11/25 16:02:19 ******/
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
/****** Object:  Table [dbo].[StockTake]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockTake](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[UserId] [nvarchar](50) NULL,
 CONSTRAINT [PK_StockTake] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StockTake_Temp]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockTake_Temp](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ItemGroupId] [int] NULL,
	[UserId] [nvarchar](50) NULL,
 CONSTRAINT [PK_StockTake_Temp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StockTakeLines]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockTakeLines](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[HeaderId] [int] NOT NULL,
	[ItemGroupId] [int] NOT NULL,
	[ItemId] [int] NOT NULL,
	[Quantity] [decimal](19, 6) NOT NULL,
	[Variance] [decimal](19, 6) NULL,
 CONSTRAINT [PK_StockTakeLines] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StockTakeLines_Temp]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockTakeLines_Temp](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ItemId] [int] NOT NULL,
	[Quantity] [decimal](19, 6) NULL,
	[Variance] [decimal](19, 6) NULL,
 CONSTRAINT [PK_StockTakeLines_Temp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SystemSettings]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemSettings](
	[SettingName] [nvarchar](max) NOT NULL,
	[SettingValue] [nvarchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TenderTypes]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TenderTypes](
	[Id] [int] NOT NULL,
	[TenderType] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_TenderTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Terminals]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Terminals](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TerminalName] [nvarchar](50) NULL,
	[Terminal_IP] [nvarchar](50) NULL,
	[PrinterId] [int] NULL,
 CONSTRAINT [PK_Terminals] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TestTable]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TestTable](
	[SalesTotal] [decimal](19, 2) NULL,
	[Date] [date] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NonClusteredIndex-20201020-183443]    Script Date: 2023/11/25 16:02:19 ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20201020-183443] ON [dbo].[ItemMaster]
(
	[Barcode] ASC,
	[ItemCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NonClusteredIndex-20220820-162818]    Script Date: 2023/11/25 16:02:19 ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20220820-162818] ON [dbo].[Returns]
(
	[OriginalDocNum] ASC,
	[OriginalDocId] ASC,
	[UnlinkedHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[calcChangePrice_Values]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcChangePrice_Values]
	
	@DocId INT,
	@LineId INT,
	@ItemId INT,
	@Action NVARCHAR(50) --SearchChange/PriceChange
AS
BEGIN	
	SET NOCOUNT ON;  

	IF(@Action = 'SearchChange') --From Search Item Action
	BEGIN
		SELECT	ItemName, QuantityAvailable AS Quantity, DiscountPriceSellIncl AS Price
		FROM	viwItemMaster
		WHERE	Id = @ItemId
	END
	ELSE IF(@Action = 'PriceChange') --From Price Change Action
	BEGIN
		SELECT	B.ItemName, A.Quantity, CAST(A.PriceUnitVatIncl AS DECIMAL(19,2)) AS Price
		FROM	DocumentTransactionsLines A
		JOIN	ItemMaster B ON B.Id = A.ItemId
		WHERE	A.HeaderId = @DocId
		AND		A.Id = @LineId
	END
		

END
GO
/****** Object:  StoredProcedure [dbo].[calcDoc_GetItemId]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcDoc_GetItemId]
	
	@LineId INT
	
AS
BEGIN	
	SET NOCOUNT ON;  

	
	SELECT	ItemId
	FROM	DocumentTransactionsLines
	WHERE	Id = @LineId
		

END
GO
/****** Object:  StoredProcedure [dbo].[calcDoc_GetLastSaleChange]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcDoc_GetLastSaleChange]
	
	@UserId NVARCHAR(50),
	@TerminalId INT
	
AS
BEGIN
	
	SET NOCOUNT ON;  		
		
		DECLARE @DocId INT = NULL

		DECLARE @T TABLE ([Value] INT)
		INSERT INTO @T
		EXEC stpPOS_DocId_Selection @UserId, @TerminalId

		IF((SELECT [Value] FROM @T) <> 0)
		BEGIN
			SELECT	@DocId = [Value]
			FROM	@T
		END
		ELSE
		BEGIN
			SELECT		TOP 1 @DocId = Id
			FROM		DocumentTransactionsHeader
			WHERE		UserId = @UserId 
			AND			TerminalId = @TerminalId
			AND			DocumentStatusId = 3 --Finalized
			ORDER BY	Id DESC
		END			


		DECLARE @Currency NVARCHAR(10)
		SELECT	@Currency = CurrencySign
		FROM	CompanyInformation

		IF(@DocId IS NOT NULL)
		BEGIN
			SELECT	@Currency + FORMAT(ROUND(CASE 
					WHEN (ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) > 0
					THEN CEILING((ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) * 10) / 10 --Round up to nearst 10 cent
					ELSE 0.0
					END,1),'N2') AS Change
			FROM	DocumentTransactionsHeader		
			WHERE	Id = @DocId
		END
		ELSE
		BEGIN
			SELECT '' AS Change
		END


END
GO
/****** Object:  StoredProcedure [dbo].[calcDoc_ResumeSuspendSale]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcDoc_ResumeSuspendSale]
	
	@UserId NVARCHAR(50),
	@TerminalId INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	IF EXISTS	(
					SELECT	1
					FROM	DocumentTransactionsHeader
					WHERE	UserId = @UserId
					AND		TerminalId = @TerminalId
					AND		DocumentStatusId = 2--Suspended
				)
	BEGIN
		SELECT 'Resume Sale' AS [Type]
	END
	ELSE
	BEGIN
		SELECT 'Suspend Sale' AS [Type]
	END


END
GO
/****** Object:  StoredProcedure [dbo].[calcGetTerminal]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcGetTerminal]
	
	@TerminalIP NVARCHAR(50)

AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION		
		SET NOCOUNT ON;  
			
			IF NOT EXISTS(SELECT 1 FROM Terminals WHERE Terminal_IP = @TerminalIP)
			BEGIN
				RAISERROR('No Terminal Available',11,1)
			END
			ELSE
			BEGIN
				SELECT	Id, TerminalName, Terminal_IP, PrinterId
				FROM	Terminals
				WHERE	Terminal_IP = @TerminalIP
			END
		
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
/****** Object:  StoredProcedure [dbo].[calcItem_PLU]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcItem_PLU]
	
	
AS
BEGIN
	
	SET NOCOUNT ON;  

	DECLARE @Code NVARCHAR(10)
	DECLARE @PLU NVARCHAR(50)

	SELECT		TOP 1 @Code = ItemCode
	FROM		ItemMaster
	WHERE		ItemCode IS NOT NULL
	AND			ISNUMERIC(ItemCode) = 1
	ORDER BY	ItemCode DESC	
	
	DECLARE @Number INT = CAST(@Code AS NVARCHAR(50)) +1 
	SET @Number = ISNULL(@Number,1)	
	SET @PLU = RIGHT ('0000'+ CAST(@Number AS NVARCHAR), 5) 	

	WHILE EXISTS (SELECT 1 FROM ItemMaster WHERE ItemCode = @PLU)
	BEGIN
		SET @Number  = CAST(@PLU AS NVARCHAR(50)) +1 
		SET @Number = ISNULL(@Number,1)	
		SET @PLU = RIGHT ('0000'+ CAST(@Number AS NVARCHAR), 5) 		
	END

	SELECT @PLU AS PLU

	----------------
	--Old Code
	----------------
	--DECLARE @Code NVARCHAR(10)

	--SELECT		TOP 1 @Code = ItemCode
	--FROM		ItemMaster
	--WHERE		ItemCode IS NOT NULL
	--AND			ISNUMERIC(ItemCode) = 1
	--ORDER BY	ItemCode DESC
	
	--DECLARE @Number INT = CAST(@Code AS NVARCHAR(50)) +1 
	
	--SELECT RIGHT ('0000'+ CAST(@Number AS NVARCHAR), 5) AS PLU


END
GO
/****** Object:  StoredProcedure [dbo].[calcItemButtonValues]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[calcItemButtonValues]
	-- PARAMETERS
	
		@ItemId INT		

AS
BEGIN
	SET NOCOUNT ON;
    
	SELECT	ButtonText,
			Font,
			FontSize,
			Hex
	FROM	ItemButtons
	WHERE	ItemId = @ItemId

END
GO
/****** Object:  StoredProcedure [dbo].[calcItemGroup_Values]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcItemGroup_Values]
	
	@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	GroupName, [Description]
	FROM	ItemGroups
	WHERE	Id = @Id


END
GO
/****** Object:  StoredProcedure [dbo].[calcItemMaster_Tax]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[calcItemMaster_Tax]
	-- PARAMETERS
		@ItemId INT
AS
BEGIN
	SET NOCOUNT ON; 
			
		SELECT	B.VAT
		FROM	ItemMaster A
		JOIN	TaxCodes B ON B.Id = A.TaxCode
		WHERE	A.Id = @ItemId
		
		
END
GO
/****** Object:  StoredProcedure [dbo].[calcItemMaster_Values]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcItemMaster_Values]
	
	@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT		A.ItemCode,
				A.ItemName,
				A.ItemGroupId,
				A.UoMId,
				A.TaxCode,
				A.Active,
				A.SupplierId,
				A.Barcode,
				A.PriceSellExclVat,
				FORMAT(A.DiscountedPriceIncl - (A.DiscountPercentage/100 * A.DiscountedPriceIncl), 'N2') AS PriceSellInclVat,
				--FORMAT(A.PriceSellExclVat + (B.VAT/100.00 * A.PriceSellExclVat),'N2') AS PriceSellInclVat,
				FORMAT(A.DiscountPercentage,'N2') AS DiscountPercentage,
				A.DiscountedPriceIncl AS FinalPrice,
				A.QuantityRequestMin,
				A.QuantityRequestMax
	FROM		ItemMaster A
	JOIN		TaxCodes B ON B.Id = A.TaxCode
	WHERE		A.Id = @Id


END
GO
/****** Object:  StoredProcedure [dbo].[calcItemName]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcItemName]
	
	@ItemId INT

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	ISNULL(ItemName,'') AS ItemName
	FROM	ItemMaster
	WHERE	Id = @ItemId


END
GO
/****** Object:  StoredProcedure [dbo].[calcItemName_Value]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcItemName_Value]
	
	@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;  


	SELECT	B.ItemName, A.Quantity
	FROM	ItemMasterCompounds A
	JOIN	ItemMaster B ON B.Id = A.ItemMasterItemId
	WHERE	A.Id = @Id


END
GO
/****** Object:  StoredProcedure [dbo].[calcItemOverView_SelectedValues]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcItemOverView_SelectedValues]
		
		@DocId INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	/*
		Selected values by Lines Id
	*/

	SELECT	ISNULL(MIN(Id),0) AS Id_Min,
			ISNULL(MAX(Id),0) AS Id_Max
	FROM	DocumentTransactionsLines
	WHERE	HeaderId = @DocId
	AND		LineStatus = 1 --Open

	/*
	SELECT	MIN(Id) AS Id_Min,
			MAX(Id) AS Id_Max
	FROM	DocumentTransactionsLines
	WHERE	HeaderId = @DocId
	AND		LineStatus = 1 --Open
	*/


END
GO
/****** Object:  StoredProcedure [dbo].[calcPOSDocLines_Values]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcPOSDocLines_Values]
	
	@DocId INT,
	@LineId INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	B.ItemName, A.Quantity, A.PriceUnitVatIncl AS Price
	FROM	DocumentTransactionsLines A
	JOIN	ItemMaster B ON B.Id = A.ItemId
	WHERE	A.HeaderId = @DocId
	AND		A.Id = @LineId

	

END
GO
/****** Object:  StoredProcedure [dbo].[calcPrinters_Values]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcPrinters_Values]	
	
	@Id INT
AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT      PrinterName, 
				PrinterDescription
	FROM        Printers
	WHERE		Id = @Id
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[calcReturns_IdSelection]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcReturns_IdSelection]	
	
	
AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		TOP 1
				Id,
				ReturnType,
				OriginalDocNum,
				ISNULL(OriginalDocId, 0) AS OriginalDocId,
				ISNULL(UnlinkedHeaderId, 0) AS UnlinkedHeaderId
	FROM		[Returns]
	WHERE		[Status] = 2 --InComplete
	ORDER BY	Id ASC

	
		
END
GO
/****** Object:  StoredProcedure [dbo].[calcReturns_ItemCount]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcReturns_ItemCount]	
	
	@DocNum NVARCHAR(50)
AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT	COUNT(Id) AS [Count]
	FROM	[Returns]
	WHERE	OriginalDocNum = @DocNum

	
		
END
GO
/****** Object:  StoredProcedure [dbo].[calcReturns_ValidDocNum]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcReturns_ValidDocNum]
	
	@DocNum NVARCHAR(50)
	
AS
BEGIN	
	SET NOCOUNT ON;


	IF EXISTS	(
					SELECT	1
					FROM	DocumentTransactionsHeader
					WHERE	DocumentNumber = @DocNum
					AND		DocumentStatusId = 3 --Finalized
					AND		DocumentTypeId = 1 --Sale

				)
	BEGIN
		SELECT CAST(1 AS BIT) AS ValidDocNum
	END
	ELSE
	BEGIN
		SELECT CAST(0 AS BIT) AS ValidDocNum
	END
	
		

END
GO
/****** Object:  StoredProcedure [dbo].[calcReturnsItemOverView_SelectedValues]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcReturnsItemOverView_SelectedValues]
		
		@DocId INT,
		@UnlinkedHeaderId INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	/*
		Selected values by Lines Id
	*/

	SELECT	ISNULL(MIN(Id),0) AS Id_Min,
			ISNULL(MAX(Id),0) AS Id_Max
	FROM	[Returns]
	WHERE	(	
				(ISNULL(OriginalDocId,0) > 0 AND ISNULL(OriginalDocId,0) = ISNULL(@DocId,0)) OR 
				(ISNULL(UnlinkedHeaderId,0) > 0 AND ISNULL(UnlinkedHeaderId,0) = ISNULL(@UnlinkedHeaderId,0))
			)
	AND		[Status] = 2 --Incomplete
		

END
GO
/****** Object:  StoredProcedure [dbo].[calcRoleGroupUsersName]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcRoleGroupUsersName]
	
	@RoleGroupId INT

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	[Name]
	FROM	RoleGroups
	WHERE	Id = @RoleGroupId


END
GO
/****** Object:  StoredProcedure [dbo].[calcStockReceiveUpdate_ItemTax]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[calcStockReceiveUpdate_ItemTax]
	-- PARAMETERS
		@Id INT
AS
BEGIN
	SET NOCOUNT ON; 
			
		SELECT	C.VAT
		FROM	StockReceive_Temp A
		JOIN	ItemMaster B ON B.Id = A.ItemId
		JOIN	TaxCodes C ON C.Id = B.TaxCode
		WHERE	A.Id = @Id	
		
END
GO
/****** Object:  StoredProcedure [dbo].[calcSuppliers_Values]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcSuppliers_Values]
	
	@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	CompanyName,
			SupplierName, 
			BillToAddress, 
			ShipToAddress, 
			BillingInformation, 
			ContactPerson, 
			Telephone, 
			CellPhone, 
			Email, 
			VATNumber
	FROM    Suppliers
	WHERE	Id = @Id


END
GO
/****** Object:  StoredProcedure [dbo].[calcTerminals_Values]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcTerminals_Values]
	
	@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT		TerminalName,
				Terminal_IP,
				PrinterId
	FROM		Terminals
	WHERE		Id = @Id


END
GO
/****** Object:  StoredProcedure [dbo].[calcUoM_Values]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcUoM_Values]	
	
	@Id INT
AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT      UoM, 
				[Description]
	FROM        UoM
	WHERE		Id = @Id
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[calcUserName]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcUserName]
	
	@UserId NVARCHAR(50)

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	FullName AS UserName
	FROM	viwUsers
	WHERE	Id = @UserId

	--SELECT	ISNULL([Name],'') + ' ' + ISNULL([Surname],'') AS UserName
	--FROM	Users
	--WHERE	Id = @UserId


END
GO
/****** Object:  StoredProcedure [dbo].[calcVatValue]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calcVatValue]
	
	@TaxCodeId INT

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	VAT
	FROM	TaxCodes
	WHErE	Id = @TaxCodeId


END
GO
/****** Object:  StoredProcedure [dbo].[lkpDashBoardGraphOptions]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpDashBoardGraphOptions]
	
	

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT 1 AS Id, 'Last 7 Days' AS [Option]
	UNION ALL
	SELECT 2 AS Id, 'Last 30 Days' AS [Option]
	UNION ALL
	SELECT 3 AS Id, 'Custom (Any Date Range)' AS [Option]
	

	

	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpDenominationsTypes]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpDenominationsTypes]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	Id, [Type]
	FROM	DenominationTypes
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpHistoryLog_Actions]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpHistoryLog_Actions]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT 'All' AS [Action]
	UNION ALL
	SELECT	DISTINCT [Action]
	FROM	HistoryLog
	
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpItemGroups]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpItemGroups]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	Id, GroupName
	FROM	ItemGroups
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpItemMaster_ItemGroups]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpItemMaster_ItemGroups]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT 'All' AS GroupName
	UNION ALL
	SELECT	GroupName
	FROM	ItemGroups
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpItemMaster_Suppliers]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpItemMaster_Suppliers]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT 'All' AS [Supplier]
	UNION ALL
	SELECT		DISTINCT B.SupplierName AS [Supplier]
	FROM		ItemMaster A
	LEFT JOIN	Suppliers B ON B.Id = A.SupplierId
	WHERE		ISNULL(SupplierName,'') <> ''
	
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpItemMaster_Vat]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpItemMaster_Vat]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT 'All' AS Vat
	UNION ALL
	SELECT		DISTINCT FORMAT(ROUND(B.VAT,2),'N2')+'%' AS Vat
	FROM		ItemMaster A
	LEFT JOIN	TaxCodes B ON B.Id = A.TaxCode
	WHERE		A.ItemCode IS NOT NULL
	
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpItems]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpItems]
	
	@ItemCode NVARCHAR(50) = NULL,
	@ItemName NVARCHAR(50) = NULL,
	@BarCode NVARCHAR(50) = NULL

AS
BEGIN
	
	SET NOCOUNT ON;  

	SET @ItemCode = ISNULL(@ItemCode,'')
	SET @ItemName = ISNULL(@ItemName,'')
	SET @BarCode = ISNULL(@BarCode,'')

	IF(@ItemCode = '' AND @ItemName = '' AND @BarCode = '')
	BEGIN		
		SELECT	Id, ItemCode ,ItemName, Barcode
		FROM	ItemMaster
		WHERE	ItemCode IS NOT NULL
	END
	ELSE
	BEGIN
		SELECT	Id, ItemCode ,ItemName, Barcode
		FROM	ItemMaster
		WHERE	ItemCode IS NOT NULL
		AND		ISNULL(ItemCode,'') LIKE '%'+@ItemCode+'%'
		AND		ISNULL(ItemName,'') LIKE '%'+@ItemName+'%'
		AND		ISNULL(Barcode,'') LIKE '%'+@BarCode+'%'
	END

	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpItems_Returns]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpItems_Returns]
	
	@DocNum NVARCHAR(50)

AS
BEGIN
	
	SET NOCOUNT ON;  

	
	DECLARE @OringinalDocId INT
	SELECT	@OringinalDocId = Id
	FROM	DocumentTransactionsHeader
	WHERE	DocumentNumber = @DocNum

	SELECT	A.Id,
			B.ItemName,
			A.QuantityOpen,
			A.PriceUnitVatIncl AS PriceSell
	FROM	DocumentTransactionsLines A
	JOIN	ItemMaster B ON B.Id = A.ItemId
	WHERE	A.HeaderId = @OringinalDocId
	
		
END

GO
/****** Object:  StoredProcedure [dbo].[lkpObjects]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpObjects]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	Id,
			ObjectName AS [Name]
	FROM	[Objects]
	
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpPrinters]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpPrinters]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	Id, PrinterName 
	FROM	Printers
	
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpSuppliers]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpSuppliers]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	--SELECT  0 AS Id, '' AS SupplierName
	--UNION ALL
	SELECT	Id, SupplierName
	FROM	Suppliers	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpTaxCodes]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpTaxCodes]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	Id, 
			FORMAT(ROUND(VAT,2),'N2')+'%' AS VAT
	FROM	TaxCodes	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpUoM]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpUoM]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	Id, UoM + ' ('+[Description]+')' AS UoM
	FROM	UoM	
		
END
GO
/****** Object:  StoredProcedure [dbo].[lkpUsers]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[lkpUsers]
		

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	Id,
			ISNULL([Name],'')+' '+ISNULL(Surname,'') AS [Name]
	FROM	Users
	
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[rptPOS_TillSlip_Header]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[rptPOS_TillSlip_Header]
	-- PARAMETERS
	@DocId INT	
AS
BEGIN
	SET NOCOUNT ON; 
		
	SELECT		B.CompanyName,
				B.ShipToAddress,
				CASE WHEN Telephone LIKE '% %' THEN Telephone ELSE STUFF(STUFF(Telephone, 4, 0, ' '), 8, 0, ' ') END AS Telephone,
				B.VATNumber,
				A.DocumentNumber,
				CONVERT(VARCHAR, A.[Date], 23) + ' ' + SUBSTRING(CONVERT(VARCHAR, A.[Date],108),1,5) AS [Date],
				--CONVERT(VARCHAR, A.[Date], 113) AS [Date],
				'TOTAL: ' + B.CurrencySign + FORMAT(ROUND(ISNULL(A.DocumentTotal,0),2),'N2') AS SalesTotal,
				B.CurrencySign + FORMAT(ROUND(ISNULL(A.TenderedCardTotal,0),2),'N2') AS TenderedCardTotal,
				B.CurrencySign + FORMAT(ROUND(ISNULL(A.TenderedCashTotal,0),2),'N2') AS TenderedCashTotal,
				B.CurrencySign + FORMAT(ROUND(CASE 
				WHEN (ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) > 0
				THEN CEILING((ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) * 10) / 10 
				ELSE 0.0
				END,1),'N2') AS Change,			
				C.FullName AS Cashier,
				D.TerminalName,
				FORMAT(E.VAT, 'N2') AS Vat,
				B.CurrencySign + FORMAT(ROUND(ISNULL(E.VatTotal,0),2),'N2') AS VatTotal
	FROM		DocumentTransactionsHeader A
	CROSS JOIN	CompanyInformation B
	JOIN		viwUsers C ON C.Id = A.UserId
	JOIN		Terminals D ON D.Id =A.TerminalId
	JOIN		(
					SELECT		A.HeaderId,							
								SUM(C.VAT/100 * (A.PriceUnitVatIncl * A.Quantity)) AS VatTotal,
								C.VAT
					FROM		DocumentTransactionsLines A
					JOIN		ItemMaster B ON B.Id = A.ItemId
					JOIN		TaxCodes C ON C.Id = B.TaxCode
					WHERE		A.LineStatus = 1--Open
					AND			C.Id = 2--Tax					
					GROUP BY	A.HeaderId, C.VAT
				) E ON E.HeaderId = A.Id
	WHERE		A.Id = @DocId


		
END
GO
/****** Object:  StoredProcedure [dbo].[rptPOS_TillSlip_Lines]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[rptPOS_TillSlip_Lines]
	-- PARAMETERS
	@DocId INT	
AS
BEGIN
	SET NOCOUNT ON; 
		
	SELECT		B.ItemName,
				FORMAT(CAST(Quantity AS DECIMAL(19,2)), 'N2') AS Quantity,
				FORMAT(ROUND(ISNULL(A.PriceUnitVatIncl,0),2),'N2') AS UnitPrice,
				FORMAT(ROUND(ISNULL(A.LineTotal,0),2),'N2') AS LineTotal
	FROM		DocumentTransactionsLines A
	JOIN		ItemMaster B ON B.Id = A.ItemId
	CROSS JOIN	CompanyInformation C
	WHERE		A.HeaderId = @DocId
	AND			A.LineStatus = 1
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpCashUp_CardMachineTotal_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpCashUp_CardMachineTotal_Update]
	-- PARAMETERS
	@Id INT,
	@Total DECIMAL(19,6) = NULL

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			

			IF(@Total < 0)
			BEGIN
				RAISERROR('Total must be a positive number', 11, 1)
			END
			ELSE
			BEGIN
				UPDATE	Shifts
				SET		CardMachineTotal = @Total
				WHERE	Id = @Id
			END
			
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
/****** Object:  StoredProcedure [dbo].[stpCashUp_Denominations_Confirm]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpCashUp_Denominations_Confirm]
	-- PARAMETERS
	
	@ShiftId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @HeaderId INT

			SELECT	@HeaderId = Id
			FROM	CashUp A
			WHERE	ShiftId = @ShiftId

			IF EXISTS	(
								SELECT	1
								FROM	DocumentTransactionsHeader
								WHERE	ShiftId = @ShiftId
								AND		DocumentTypeId = 1 --Sale
								AND		(
											DocumentStatusId = 1 --Open
										OR	DocumentStatusId = 2 --Suspended
										)
							)
			BEGIN
				RAISERROR('Please complete the Open / Suspended Sale(s)',11,1)				
			END
			ELSE
			IF NOT EXISTS	(
								SELECT	1
								FROM	CashUpLines
								WHERE	HeaderId = @HeaderId
							)
			BEGIN
				RAISERROR('Please create and update the denominations first.', 11, 1)
			END
			ELSE
			BEGIN
				UPDATE	CashUp
				SET		StatusId =  1 --Completed
				WHERE	ShiftId = @ShiftId
				
				DECLARE @CashUpTotal DECIMAL(19,6) = 0
				SELECT	@CashUpTotal = SUM(A.DenominationCount * B.Value)
				FROM	CashUpLines A
				JOIN	Denominations B ON B.Id = A.DenominationId
				WHERE	HeaderId = @HeaderId

				UPDATE	Shifts
				SET		CashUpStatus = 1, --Completed
						CashUpOut = @CashUpTotal
				WHERE	Id = @ShiftId

				
				
			END
			
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
/****** Object:  StoredProcedure [dbo].[stpCashUp_Denominations_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpCashUp_Denominations_Insert]
	-- PARAMETERS
	
	@ShiftId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION

			
			IF NOT EXISTS (SELECT 1 FROM Denominations)
			BEGIN
				RAISERROR('Cannot Cash Up, because the Denominations are not set up.',11,1)
			END
			ELSE IF EXISTS	(
								SELECT	1
								FROM	DocumentTransactionsHeader
								WHERE	ShiftId = @ShiftId
								AND		DocumentTypeId = 1 --Sale
								AND		(
											DocumentStatusId = 1 --Open
										OR	DocumentStatusId = 2 --Suspended
										)
							)
			BEGIN
				RAISERROR('Please complete the Open / Suspended Sale(s)',11,1)				
			END
			ELSE IF NOT EXISTS (
									SELECT	1
									FROM	CashUp
									WHERE	ShiftId = @ShiftId
								)
			BEGIN
				DECLARE @Id INT

				INSERT INTO CashUp ([Date], StatusId, ShiftId)
				VALUES (GETDATE(), 2, @ShiftId) --StatusId: 2 - Incomplete
				SET @Id = SCOPE_IDENTITY()

				INSERT INTO CashUpLines(HeaderId, DenominationId, DenominationCount)
				SELECT	@Id,
						Id,
						0
				FROM	Denominations
			END
			
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
/****** Object:  StoredProcedure [dbo].[stpCashUp_Denominations_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpCashUp_Denominations_Select]	
	
	@ShiftId INT

AS
BEGIN	
	SET NOCOUNT ON;  
		
	SELECT		B.Id AS LineId,
				C.[Name] AS DenominationName,
				C.[Value] AS DenominationValue,
				B.DenominationCount			
	FROM		CashUp A
	JOIN		CashUpLines B ON B.HeaderId = A.Id
	JOIN		Denominations C ON C.Id = B.DenominationId
	WHERE		A.ShiftId = @ShiftId
	ORDER BY	C.[Value] ASC	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpCashUp_Denominations_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpCashUp_Denominations_Update]
	-- PARAMETERS
	@Id INT,
	@Count INT = NULL

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF(@Count < 0)
			BEGIN
				RAISERROR('Count must be a positive number', 11, 1)
			END
			ELSE
			BEGIN
				UPDATE	CashUpLines
				SET		DenominationCount = @Count
				WHERE	Id = @Id
			END
			
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
/****** Object:  StoredProcedure [dbo].[stpCashUp_Shift_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpCashUp_Shift_Select]	
	
	@UserName NVARCHAR(255) = '',
	@Date DATE = NULL

AS
BEGIN	
	SET NOCOUNT ON;  
	
	
		SELECT		A.Id,
					B.FullName,
					C.[Name] AS ShiftStatus,
					D.[Name] AS CashUpStatus,
					A.StartDate,
					A.StartFloat,
					ISNULL(A.CardMachineTotal, 0) AS CardMachineTotal

		FROM		Shifts A
		JOIN		viwUsers B ON B.Id = A.UserId
		JOIN		ShiftStatus C ON C.Id = A.ShiftStatusId
		JOIN		CashUpStatus D ON D.Id = A.CashUpStatus
		WHERE		ShiftStatusId = 1 --Open
		AND			CashUpStatus = 2 --Incomplete
		AND			(ISNULL(@UserName,'') = '' OR B.FullName LIKE '%'+@UserName+'%')
		AND			(@Date IS NULL OR CAST(A.StartDate AS DATE) = @Date)
		ORDER BY	A.StartDate

	


	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpCompanyInformation_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpCompanyInformation_Select]
	-- PARAMETERS	
			

AS
BEGIN
	SET NOCOUNT ON;    
				
					
		SELECT	[Id]
				,[CompanyName]
				,[BranchName]
				,[BillToAddress]
				,[ShipToAddress]
				,[ContactPersonName]
				,[Telephone]
				,[CellPhone]
				,[Email]
				,[VATNumber]				
				,[CurrencySign]
				,Logo
				,LogoImageName
		 FROM	 [POSSystem].[dbo].[CompanyInformation]
			
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpCompanyInformation_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpCompanyInformation_Update]
	-- PARAMETERS	
		@CompanyName		NVARCHAR(250),
		@BranchName			NVARCHAR(250),
		@BillToAddress		NVARCHAR(MAX),
		@ShipToAddress		NVARCHAR(MAX),
		@ContactPersonName	NVARCHAR(100),
		@Telephone			NVARCHAR(50) ,
		@CellPhone			NVARCHAR(50) ,
		@Email				NVARCHAR(250),
		@VATNumber			NVARCHAR(50) ,
		@CompanyLogo		NVARCHAR(MAX),--IMAGE
		@CurrencySign		NVARCHAR(10),
		@LogoImageName		NVARCHAR(250),
		@ClearImage			BIT,
		@NewImage			BIT = 0
		

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
				
				IF(@ClearImage = 1)
				BEGIN
						UPDATE CompanyInformation
						SET [CompanyName]			= @CompanyName		
						   ,[BranchName] 			= @BranchName			
						   ,[BillToAddress] 		= @BillToAddress		
						   ,[ShipToAddress] 		= @ShipToAddress		
						   ,[ContactPersonName] 	= @ContactPersonName	
						   ,[Telephone] 			= @Telephone			
						   ,[CellPhone]				= @CellPhone			
						   ,[Email] 				= @Email				
						   ,[VATNumber] 			= @VATNumber
						   ,[CurrencySign] 			= @CurrencySign
						   ,Logo					= NULL
						   ,LogoImageName			= NULL
				END
				ELSE IF(@NewImage = 1)
				BEGIN
					UPDATE CompanyInformation
							SET [CompanyName]			= @CompanyName		
							   ,[BranchName] 			= @BranchName			
							   ,[BillToAddress] 		= @BillToAddress		
							   ,[ShipToAddress] 		= @ShipToAddress		
							   ,[ContactPersonName] 	= @ContactPersonName	
							   ,[Telephone] 			= @Telephone			
							   ,[CellPhone]				= @CellPhone			
							   ,[Email] 				= @Email				
							   ,[VATNumber] 			= @VATNumber
							   ,[CurrencySign] 			= @CurrencySign
							   ,Logo					= @CompanyLogo
							   ,LogoImageName			= @LogoImageName
				END
				ELSE
				BEGIN
				BEGIN
					UPDATE CompanyInformation
							SET [CompanyName]			= @CompanyName		
							   ,[BranchName] 			= @BranchName			
							   ,[BillToAddress] 		= @BillToAddress		
							   ,[ShipToAddress] 		= @ShipToAddress		
							   ,[ContactPersonName] 	= @ContactPersonName	
							   ,[Telephone] 			= @Telephone			
							   ,[CellPhone]				= @CellPhone			
							   ,[Email] 				= @Email				
							   ,[VATNumber] 			= @VATNumber
							   ,[CurrencySign] 			= @CurrencySign
							   --,Logo					= @CompanyLogo
							   --,LogoImageName			= @LogoImageName
				END
				END

				-----------------------------------------
				---------History Log---------------------
				-----------------------------------------

				--DECLARE @To NVARCHAR(MAX) = 'Item Code: '+ISNULL(@ItemCode,'')
				--DECLARE @Des NVARCHAR(MAX) = 'Stock Management: New item added '+ISNULL(@ItemCode,'')

				--EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
				--							@Action = 'Insert',
				--							@Description = @Des,
				--							@FromValue = '',
				--							@ToValue = @To,											
				--							@FieldId = @Id
				
			
			
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
/****** Object:  StoredProcedure [dbo].[stpDashBoard_SalesGraph_Values]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpDashBoard_SalesGraph_Values]
	-- PARAMETERS
	@Options INT = 1, -- 1: Last 7 Days; 2: Last 30 Days; 3: Custom Date Range
	@DateFrom DATE = NULL,
	@DateTo DATE = NULL
		
AS
BEGIN
	SET NOCOUNT ON; 
	

		DECLARE @GraphMaxPoints INT = 15
		DECLARE @Count INT -- = 90	
		
		DECLARE @Table TABLE (SalesTotal DECIMAL(19,2), [Date] DATE)
		DECLARE @GraphData TABLE (SalesTotal DECIMAL(19,2), [Date] DATE)
		
		
		IF(@Options = 1) --Last 7 Days
		BEGIN
			INSERT INTO	@Table
			SELECT		SUM(DocumentTotal) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
			FROM		DocumentTransactionsHeader
			WHERE		DocumentStatusId = 3 --Finalized			
			AND			DATEPART(DAYOFYEAR, [Date]) >= (DATEPART(DAYOFYEAR, GETDATE())-7)
			AND			DATEPART(YEAR,CAST([Date] AS Date)) = DATEPART(YEAR,GETDATE())
			GROUP BY	CAST([Date] AS Date)
			ORDER BY	CAST([Date] AS Date) ASC
		END
		ELSE IF(@Options = 2) --Last 30 Days
		BEGIN
			INSERT INTO	@Table
			SELECT		SUM(DocumentTotal) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
			FROM		DocumentTransactionsHeader
			WHERE		DocumentStatusId = 3 --Finalized
			AND			DATEPART(DAYOFYEAR, [Date]) >= (DATEPART(DAYOFYEAR, GETDATE())-30)
			AND			DATEPART(YEAR,CAST([Date] AS Date)) = DATEPART(YEAR,GETDATE())
			GROUP BY	CAST([Date] AS Date)
			ORDER BY	CAST([Date] AS Date) ASC
		END
		ELSE
		BEGIN --Custom
			INSERT INTO	@Table
			SELECT		SUM(DocumentTotal) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]				
			FROM		DocumentTransactionsHeader
			WHERE		DocumentStatusId = 3 --Finalized
			AND			CAST([Date] AS Date) BETWEEN @DateFrom AND @DateTo
			GROUP BY	CAST([Date] AS Date)
			ORDER BY	CAST([Date] AS Date) ASC
		END			

		SELECT	@Count = COUNT([Date])
		FROM	@Table	

		DECLARE @Modules INT

		IF(@Count > @GraphMaxPoints)
		BEGIN
			SELECT	@Modules = FLOOR(COUNT([Date]) / @GraphMaxPoints)
			FROM	@Table
		END
		ELSE
		BEGIN
			SET @Modules = 1
		END
		
		
		
		
		
		WHILE(@Count > 0)
		BEGIN
			INSERT INTO @GraphData
			SELECT	SalesTotal, [Date]
			FROM	(
						SELECT	ROW_NUMBER() OVER(ORDER BY [Date] DESC) AS RowNum, SalesTotal, [Date] 
						FROM	@Table
						--WHERE	[Date] >= GETDATE()-30
					) A
			WHERE RowNum = @Count

			SET @Count -= @Modules
		END

		DECLARE @Min INT,
				@Max INT

		DECLARE @TotalMIN DECIMAL(19,2),
				@TotalMAX DECIMAL(19,6)
			

		SELECT	@Max = CAST(MAX(SalesTotal) AS INT),
				@Min = CAST(MIN(SalesTotal) AS INT)
		FROM	@GraphData

		
		--MAX
		IF(LEN(@Max) = 2)--Tens
		BEGIN
			SET @TotalMAX = CEILING(@Max / 10.0) * 10.0;
		END
		ELSE IF(LEN(@Max) = 3)--Hunderds
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 100.0) * 100.0;
		END
		ELSE IF(LEN(@Max) = 4)--Thousands
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 1000.0) * 1000.0;
		END
		ELSE IF(LEN(@Max) = 5)--Ten Thousands
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 10000.0) * 10000.0;
		END
		ELSE IF(LEN(@Max) = 6)--Hunder Thousands
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 100000.0) * 100000.0;
		END
		ELSE IF(LEN(@Max) = 7)--Millions
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 1000000.0) * 1000000.0;
		END 
		--MIN
		IF(LEN(@Min) = 2)--Tens
		BEGIN
			SET @TotalMIN = FLOOR(@Min / 10.0) * 10.0;
		END
		ELSE IF(LEN(@Min) = 3)--Hunderds
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 100.0) * 100.0;
		END
		ELSE IF(LEN(@Min) = 4)--Thousands
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 1000.0) * 1000.0;
		END
		ELSE IF(LEN(@Min) = 5)--Ten Thousands
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 10000.0) * 10000.0;
		END
		ELSE IF(LEN(@Min) = 6)--Hunder Thousands
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 100000.0) * 100000.0;
		END
		ELSE IF(LEN(@Min) = 7)--Millions
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 1000000.0) * 1000000.0;
		END	   	

		SELECT		CAST(@TotalMIN AS INT) AS TotalMIN, 
					CAST(@TotalMAX AS INT) AS TotalMAX,
					CAST(((@TotalMAX - @TotalMIN) / 10) AS INT) AS Interval, --10 Marks on Y axis
					SalesTotal, 
					CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		@GraphData	
		ORDER BY	[Date] ASC

		/*
		SELECT		SalesTotal, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		@GraphData
		ORDER BY	[Date] ASC
		*/



	/*
	--SET @DateFrom = '2021-01-01'
	--SET @DateTo = '2021-09-29'	
	
	IF(@Options = 1) --This Week
	BEGIN
		SELECT		COUNT(Id) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		DocumentTransactionsHeader
		WHERE		DocumentStatusId = 3 --Finalized
		AND			DATEPART(WEEK, CAST([Date] AS Date)) = DATEPART(WW, GETDATE())
		AND			DATEPART(YEAR,CAST([Date] AS Date)) = DATEPART(YEAR,GETDATE())
		GROUP BY	CAST([Date] AS Date)
		ORDER BY	CAST([Date] AS Date) ASC
	END
	ELSE IF(@Options = 2) --This Month
	BEGIN
		SELECT		COUNT(Id) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		DocumentTransactionsHeader
		WHERE		DocumentStatusId = 3 --Finalized
		AND			DATEPART(M, CAST([Date] AS Date)) = DATEPART(M, GETDATE())
		AND			DATEPART(YEAR,CAST([Date] AS Date)) = DATEPART(YEAR,GETDATE())
		GROUP BY	CAST([Date] AS Date)
		ORDER BY	CAST([Date] AS Date) ASC
	END
	ELSE
	BEGIN --Custom
		SELECT		COUNT(Id) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]				
		FROM		DocumentTransactionsHeader
		WHERE		DocumentStatusId = 3 --Finalized
		AND			CAST([Date] AS Date) BETWEEN @DateFrom AND @DateTo
		GROUP BY	CAST([Date] AS Date)
		ORDER BY	CAST([Date] AS Date) ASC
	END

	*/


END
GO
/****** Object:  StoredProcedure [dbo].[stpDashBoard_SalesGraph_Values_BackUp_2022-07-02]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpDashBoard_SalesGraph_Values_BackUp_2022-07-02]
	-- PARAMETERS
	@Options INT, -- 1: Last 7 Days; 2: Last 30 Days; 3: Custom Date Range
	@DateFrom DATE,
	@DateTo DATE
		
AS
BEGIN
	SET NOCOUNT ON; 
	

		DECLARE @GraphMaxPoints INT = 15
		DECLARE @Table TABLE (SalesTotal DECIMAL(19,2), [Date] DATE)
		DECLARE @GraphData TABLE (SalesTotal DECIMAL(19,2), [Date] DATE)
		DECLARE @AmountOfRows INT = 90

		DECLARE @Count INT = @AmountOfRows	
		WHILE(@Count > 0)
		BEGIN
			INSERT INTO @Table
			SELECT CAST(RAND()*(50000-10000)+10000 AS DECIMAL(19,2)), GETDATE()-@Count

			SET @Count -= 1
		END

		/*
		/*
		TEST TABLE
		*/
		DELETE FROM @Table

		INSERT INTO @Table
		SELECT * FROM TestTable

		/*------*/
		*/

		DECLARE @Modules INT

		SELECT	@Modules = FLOOR(COUNT([Date]) / @GraphMaxPoints)
		FROM	@Table

		
		SET @Count = @AmountOfRows
		WHILE(@Count > 0)
		BEGIN
			INSERT INTO @GraphData
			SELECT	SalesTotal, [Date]
			FROM	(
						SELECT	ROW_NUMBER() OVER(ORDER BY [Date] DESC) AS RowNum, SalesTotal, [Date] 
						FROM	@Table
						--WHERE	[Date] >= GETDATE()-30
					) A
			WHERE RowNum = @Count

			SET @Count -= @Modules
		END

		DECLARE @Min INT,
				@Max INT

		DECLARE @TotalMIN DECIMAL(19,2),
				@TotalMAX DECIMAL(19,6)
			

		SELECT	@Max = CAST(MAX(SalesTotal) AS INT),
				@Min = CAST(MIN(SalesTotal) AS INT)
		FROM	@GraphData

		
		--MAX
		IF(LEN(@Max) = 2)--Tens
		BEGIN
			SET @TotalMAX = CEILING(@Max / 10.0) * 10.0;
		END
		ELSE IF(LEN(@Max) = 3)--Hunderds
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 100.0) * 100.0;
		END
		ELSE IF(LEN(@Max) = 4)--Thousands
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 1000.0) * 1000.0;
		END
		ELSE IF(LEN(@Max) = 5)--Ten Thousands
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 10000.0) * 10000.0;
		END
		ELSE IF(LEN(@Max) = 6)--Hunder Thousands
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 100000.0) * 100000.0;
		END
		ELSE IF(LEN(@Max) = 7)--Millions
		BEGIN
			SET @TotalMAX =  CEILING(@Max / 1000000.0) * 1000000.0;
		END 
		--MIN
		IF(LEN(@Min) = 2)--Tens
		BEGIN
			SET @TotalMIN = FLOOR(@Min / 10.0) * 10.0;
		END
		ELSE IF(LEN(@Min) = 3)--Hunderds
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 100.0) * 100.0;
		END
		ELSE IF(LEN(@Min) = 4)--Thousands
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 1000.0) * 1000.0;
		END
		ELSE IF(LEN(@Min) = 5)--Ten Thousands
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 10000.0) * 10000.0;
		END
		ELSE IF(LEN(@Min) = 6)--Hunder Thousands
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 100000.0) * 100000.0;
		END
		ELSE IF(LEN(@Min) = 7)--Millions
		BEGIN
			SET @TotalMIN =  FLOOR(@Min / 1000000.0) * 1000000.0;
		END	   	

		SELECT		CAST(@TotalMIN AS INT) AS TotalMIN, 
					CAST(@TotalMAX AS INT) AS TotalMAX,
					CAST(((@TotalMAX - @TotalMIN) / 10) AS INT) AS Interval, --10 Marks on Y axis
					SalesTotal, 
					CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		@GraphData	
		ORDER BY	[Date] ASC

		/*
		SELECT		SalesTotal, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		@GraphData
		ORDER BY	[Date] ASC
		*/



	/*
	--SET @DateFrom = '2021-01-01'
	--SET @DateTo = '2021-09-29'	
	
	IF(@Options = 1) --This Week
	BEGIN
		SELECT		COUNT(Id) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		DocumentTransactionsHeader
		WHERE		DocumentStatusId = 3 --Finalized
		AND			DATEPART(WEEK, CAST([Date] AS Date)) = DATEPART(WW, GETDATE())
		AND			DATEPART(YEAR,CAST([Date] AS Date)) = DATEPART(YEAR,GETDATE())
		GROUP BY	CAST([Date] AS Date)
		ORDER BY	CAST([Date] AS Date) ASC
	END
	ELSE IF(@Options = 2) --This Month
	BEGIN
		SELECT		COUNT(Id) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]
		FROM		DocumentTransactionsHeader
		WHERE		DocumentStatusId = 3 --Finalized
		AND			DATEPART(M, CAST([Date] AS Date)) = DATEPART(M, GETDATE())
		AND			DATEPART(YEAR,CAST([Date] AS Date)) = DATEPART(YEAR,GETDATE())
		GROUP BY	CAST([Date] AS Date)
		ORDER BY	CAST([Date] AS Date) ASC
	END
	ELSE
	BEGIN --Custom
		SELECT		COUNT(Id) AS TotalSales, CONVERT(NVARCHAR, CAST([Date] AS Date), 111) AS [Date]				
		FROM		DocumentTransactionsHeader
		WHERE		DocumentStatusId = 3 --Finalized
		AND			CAST([Date] AS Date) BETWEEN @DateFrom AND @DateTo
		GROUP BY	CAST([Date] AS Date)
		ORDER BY	CAST([Date] AS Date) ASC
	END

	*/


END
GO
/****** Object:  StoredProcedure [dbo].[stpDenomiations_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpDenomiations_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@Name NVARCHAR(50),
	@Value DECIMAL(19,6),
	@TypeId INT	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF EXISTS	(
						SELECT	1
						FROM	Denominations
						WHERE	[Name] = @Name
					)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX) = ISNULL(@Name,'') + ' already exists.'
			RAISERROR(@Msg,11,1)
		END
		ELSE
		BEGIN

			DECLARE @Id INT

			INSERT INTO Denominations([Name], [Value], TypeId)
			VALUES(@Name, @Value, @TypeId)
			SET @Id = SCOPE_IDENTITY()

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = 'Name: '+ISNULL(@Name,'')+', Value: '+ISNULL(CAST(@Value AS NVARCHAR(50)),'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = 'Denominations: New Denomination created',
										@FromValue = '',
										@ToValue = @To,
										@FieldId = @Id
		END
			
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
/****** Object:  StoredProcedure [dbo].[stpDenomiations_Reset]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpDenomiations_Reset]
	-- PARAMETERS
	
	@UserId NVARCHAR(50)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
			IF EXISTS	(
							SELECT	1
							FROM	CashUp
						)
			BEGIN
				RAISERROR('Denominations cannot be reset, because it is being used in Cash Ups',11,1)
			END
			ELSE
			BEGIN
				TRUNCATE TABLE Denominations
			
			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			
			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = 'Denominations: Denominations Reset',
										@FromValue = '',
										@ToValue = '',
										@FieldId = NULL
			
			END
			
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
/****** Object:  StoredProcedure [dbo].[stpDenominations_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpDenominations_Select]	
	

AS
BEGIN	
	SET NOCOUNT ON;  
	
	DECLARE @CurrencySign NVARCHAR(10) = NULL
	SELECT	@CurrencySign = CurrencySign
	FROM	CompanyInformation
	
	SELECT	A.Id,
			@CurrencySign AS CurrencySign,
			B.[Type],
			A.[Name],
			A.[Value]
	FROM	Denominations A
	JOIN	DenominationTypes B ON B.Id = A.TypeId
	


	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpHistoryLog_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpHistoryLog_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),	
	@Action NVARCHAR(50),
	@Description NVARCHAR(MAX),
	@FromValue NVARCHAR(MAX),
	@ToValue NVARCHAR(MAX),
	@FieldId NVARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
		
		INSERT INTO HistoryLog ([Datetime], UserId, [Action], [Description], FromValue, ToValue, FieldId)
						VALUES (GETDATE(), @UserId, @Action, @Description, @FromValue, @ToValue, @FieldId)
			
		
			
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
/****** Object:  StoredProcedure [dbo].[stpHistoryLog_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpHistoryLog_Select]
	
	@DateTime DATETIME,
	@UserName NVARCHAR(250),
	@Action NVARCHAR(50),
	@Description NVARCHAR(MAX),
	@FromValue NVARCHAR(MAX),
	@ToValue NVARCHAR(MAX)

AS
BEGIN
	
	SET NOCOUNT ON;  

	--RAISERROR('qwe',11,1)

	DECLARE @Date DATETIME = NULL
	DECLARE @DateStr NVARCHAR(50) = CAST(ISNULL(@Date,'') AS NVARCHAR(50))
	

	SET @Action = ISNULL(@Action,'')
	SET	@Description = ISNULL(@Description,'')
	SET @FromValue = ISNULL(@FromValue,'')
	SET @ToValue = ISNULL(@ToValue,'')

	IF(@DateTime = '' AND @UserName = '' AND @Action = '' AND @Description = '' AND @FromValue = '' AND @ToValue = '')
	BEGIN
		--RAISERROR('1',11,1)
		SELECT		ISNULL(A.Id,'') AS Id,
					ISNULL([Datetime],'') AS [Datetime],
					ISNULL(B.[Name],'')+' '+ISNULL(B.Surname,'') AS [Name],
					ISNULL([Action],'') AS [Action],
					ISNULL([Description],'') AS [Description],
					ISNULL(FromValue,'') AS FromValue,
					ISNULL(ToValue,'') AS ToValue
		FROM		HistoryLog A
		LEFT JOIN	Users B ON CAST(B.Id AS NVARCHAR(50))= A.UserId
		ORDER BY	[Datetime] DESC

	END
	ELSE IF(ISNULL(@DateTime,'') = ISNULL(@Date,''))
	BEGIN
		--RAISERROR('2',11,1)
		SELECT		ISNULL(A.Id,'') AS Id,
					ISNULL([Datetime],'') AS [Datetime],
					ISNULL(B.[Name],'')+' '+ISNULL(B.Surname,'') AS [Name],
					ISNULL([Action],'') AS [Action],
					ISNULL([Description],'') AS [Description],
					ISNULL(FromValue,'') AS FromValue,
					ISNULL(ToValue,'') AS ToValue
		FROM		HistoryLog A
		LEFT JOIN	Users B ON CAST(B.Id AS NVARCHAR(50))= A.UserId
		WHERE		--CAST([Datetime] AS DATE) = CAST(@DateTime AS DATE)
					ISNULL(B.[Name],'')+' '+ISNULL(B.Surname,'') LIKE '%'+@UserName+'%'
		AND			ISNULL([Action],'') LIKE '%'+@Action+'%'
		AND			ISNULL([Description],'') LIKE '%'+@Description+'%'
		AND			ISNULL(FromValue,'') LIKE '%'+@FromValue+'%'
		AND			ISNULL(ToValue,'') LIKE '%'+@ToValue+'%'
		ORDER BY	[Datetime] DESC
	END
	ELSE
	BEGIN
		--RAISERROR('3',11,1)
		SELECT		ISNULL(A.Id,'') AS Id,
					ISNULL([Datetime],'') AS [Datetime],
					ISNULL(B.[Name],'')+' '+ISNULL(B.Surname,'') AS [Name],
					ISNULL([Action],'') AS [Action],
					ISNULL([Description],'') AS [Description],
					ISNULL(FromValue,'') AS FromValue,
					ISNULL(ToValue,'') AS ToValue
		FROM		HistoryLog A
		LEFT JOIN	Users B ON CAST(B.Id AS NVARCHAR(50))= A.UserId
		WHERE		CAST([Datetime] AS DATE) = CAST(@DateTime AS DATE)
		AND			ISNULL(B.[Name],'')+' '+ISNULL(B.Surname,'') LIKE '%'+@UserName+'%'
		AND			ISNULL([Action],'') LIKE '%'+@Action+'%'
		AND			ISNULL([Description],'') LIKE '%'+@Description+'%'
		AND			ISNULL(FromValue,'') LIKE '%'+@FromValue+'%'
		AND			ISNULL(ToValue,'') LIKE '%'+@ToValue+'%'
		ORDER BY	[Datetime] DESC

	END
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpItemButton_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemButton_Insert]
	-- PARAMETERS
	
		@ItemId INT,
		@ButtonText NVARCHAR(50),
		@Font NVARCHAR(50),
		@FontSize INT,
		@Hex NVARCHAR(50)		

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
				
		INSERT INTO ItemButtons (ItemId, ButtonText, Font, FontSize, Hex) 
					VALUES (@ItemId, @ButtonText, @Font, @FontSize, @Hex)	
			
			
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
/****** Object:  StoredProcedure [dbo].[stpItemButton_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemButton_Update]
	-- PARAMETERS
	
		@ItemId INT,
		@ButtonText NVARCHAR(50),
		@Font NVARCHAR(50),
		@FontSize INT,
		@Hex NVARCHAR(50)		

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF NOT EXISTS(SELECT 1 FROM ItemButtons WHERE ItemId = @ItemId)
		BEGIN
			INSERT INTO ItemButtons (ItemId, ButtonText, Font, FontSize, Hex) 
					VALUES (@ItemId, @ButtonText, @Font, @FontSize, @Hex)	
		END
		ELSE
		BEGIN
			UPDATE	A
			SET		ButtonText = @ButtonText,
					Font = @Font,
					FontSize = @FontSize,
					Hex = @Hex
			FROM	ItemButtons A
			WHERE	A.ItemId = @ItemId
		END
			
			
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
/****** Object:  StoredProcedure [dbo].[stpItemButtons_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpItemButtons_Select]

	@GroupId INT,
	@RowNum INT = 0

AS
BEGIN	
	SET NOCOUNT ON;  

	IF(@RowNum = 0)
	BEGIN
		SELECT		ROW_NUMBER() OVER(ORDER BY ISNULL(B.ButtonText, A.ItemName) ASC) AS RowNum,
					A.ItemGroupId,
					ISNULL(B.ItemId, A.Id) AS ItemId,
					ISNULL(B.ButtonText, A.ItemName) AS ButtonText,
					ISNULL(B.Font, 'Segoe UI') AS Font,
					ISNULL(B.FontSize, 20) AS FontSize,
					ISNULL(B.Hex, '#DDDDDD') AS Hex
		FROM		ItemMaster A
		LEFT JOIN	ItemButtons B ON B.ItemId = A.Id
		WHERE		A.Active = 1
		AND			ItemGroupId = @GroupId	
	END
	ELSE
	BEGIN
		SELECT	RowNum, ItemGroupId, ItemId, ButtonText, Font, FontSize, Hex
		FROM	(
					SELECT		ROW_NUMBER() OVER(ORDER BY ISNULL(B.ButtonText, A.ItemName) ASC) AS RowNum,
								A.ItemGroupId,
								ISNULL(B.ItemId, A.Id) AS ItemId,
								ISNULL(B.ButtonText, A.ItemName) AS ButtonText,
								ISNULL(B.Font, 'Segoe UI') AS Font,
								ISNULL(B.FontSize, 20) AS FontSize,
								ISNULL(B.Hex, '#DDDDDD') AS Hex
					FROM		ItemMaster A
					LEFT JOIN	ItemButtons B ON B.ItemId = A.Id
					WHERE		A.Active = 1
					AND			ItemGroupId = @GroupId
				) A
		WHERE	RowNum = @RowNum
	END
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpItemGroupButtons_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpItemGroupButtons_Select]
	
	@RowNum INT = 0
AS
BEGIN	
	SET NOCOUNT ON;  

	IF(@RowNum = 0)
	BEGIN
		SELECT	RowNum,
				Id,
				GroupName
		FROM	viwItemGroups_Buttons
	END
	ELSE
	BEGIN
		SELECT	RowNum,
				Id,
				GroupName
		FROM	viwItemGroups_Buttons
		WHERE	RowNum = @RowNum
	END
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpItemGroups_Delete]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemGroups_Delete]
	-- PARAMETERS	
	@Id INT,
	@UserId NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF EXISTS	(
							SELECT	1
							FROM	ItemMaster
							WHERE	ItemGroupId = @Id
						)
			BEGIN
				RAISERROR('Cannot remove Group because it is in use',11,1)
			END
			ELSE
			BEGIN
				DECLARE @GroupName NVARCHAR(50)

				SELECT	@GroupName = GroupName
				FROM	ItemGroups
				WHERE	Id = @Id

				

				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @From NVARCHAR(MAX) = 'Group Name: '+ISNULL(@GroupName,'')			

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Delete',
											@Description = 'Item Groups: Item Group removed',
											@FromValue = @From,
											@ToValue = '',
											@FieldId = @Id
			END
			
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
/****** Object:  StoredProcedure [dbo].[stpItemGroups_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemGroups_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@GroupName NVARCHAR(50),
	@Description NVARCHAR(250)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF EXISTS	(
						SELECT	1
						FROM	ItemGroups
						WHERE	GroupName = @GroupName
					)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX) = ISNULL(@GroupName,'') + ' already exists.'
			RAISERROR(@Msg,11,1)
		END
		ELSE
		BEGIN

			DECLARE @Id INT

			INSERT INTO ItemGroups(GroupName, [Description])
			VALUES(@GroupName, @Description)
			SET @Id = SCOPE_IDENTITY()

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = 'Name: '+ISNULL(@GroupName,'')+', Description: '+ISNULL(@Description,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = 'Item Groups: New Item Group created',
										@FromValue = '',
										@ToValue = @To,
										@FieldId = @Id
		END
			
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
/****** Object:  StoredProcedure [dbo].[stpItemGroups_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpItemGroups_Select]	
	

AS
BEGIN	
	SET NOCOUNT ON;  
			
	
	SELECT		Id, GroupName, [Description]
	FROM		ItemGroups
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpItemGroups_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemGroups_Update]
	-- PARAMETERS
	
	@Id INT,
	@Description NVARCHAR(250),
	@UserId NVARCHAR(50)	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			DECLARE @Description_Old NVARCHAR(250)

			SELECT	@Description_Old = [Description]
			FROM	ItemGroups
			WHERE	Id = @Id

			UPDATE	A
			SET		A.[Description] = @Description
			FROM	ItemGroups A
			WHERE	A.Id = @Id

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @From NVARCHAR(MAX) = 'Description: '+ISNULL(@Description_Old,'')
			DECLARE @To NVARCHAR(MAX) = 'Description: '+ISNULL(@Description,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = 'Item Groups: Item Group updated',
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		
			
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
/****** Object:  StoredProcedure [dbo].[stpItemMaster_CreateHeader]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemMaster_CreateHeader]
	-- PARAMETERS	
	--@Id INT
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION
			
			--DELETE Old Empty Headers
			DELETE
			FROM	ItemMaster
			WHERE	ItemCode IS NULL
			AND		CAST(TimeStampCreate AS DATE) < CAST(GETDATE() AS DATE)
			-------------------------------------------------------------------
			
			DECLARE @Id INT

			INSERT INTO ItemMaster (ItemCode, TimeStampCreate) VALUES (NULL, GETDATE())
			SET @Id = SCOPE_IDENTITY()

			SELECT @Id AS Id
			
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
/****** Object:  StoredProcedure [dbo].[stpItemMaster_DeleteHeader]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemMaster_DeleteHeader]
	-- PARAMETERS	
		@Id INT
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION
			
			--Lines (Compound Items)
			DELETE
			FROM	ItemMasterCompounds
			WHERE	HeaderId = @Id
			
			--Header
			DELETE
			FROM	ItemMaster
			WHERE	Id = @Id
			
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
/****** Object:  StoredProcedure [dbo].[stpItemMaster_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemMaster_Insert]
	-- PARAMETERS
	
		@Id INT,
		@ItemCode NVARCHAR(50),
		@ItemName NVARCHAR(50),
		--@QuantityAvailable DECIMAL(19,6),
		@QuantityRequestMin DECIMAL(19,6) = NULL,
		@QuantityRequestMax DECIMAL(19,6) = NULL,
		--@QuantityRequested DECIMAL(19,6) = NULL,
		@PriceSellExclVat DECIMAL(19,2),
		--@PricePurchaseExclVat DECIMAL(19,2),
		@DiscountPercentage DECIMAL(19,6),
		@DiscountedPriceIncl DECIMAL(19,6),
		--@ProfitMargin DECIMAL(19,6),
		@Active BIT,
		@Barcode NVARCHAR(100) = NULL,
		@SupplierId INT = NULL,
		@TaxCode INT,
		@LoggedInUserId NVARCHAR(50),
		@UoM INT,
		@ItemGroupId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
						
			IF EXISTS	(
							SELECT	1
							FROM	ItemMaster
							WHERE	ItemCode = @ItemCode
						)
			BEGIN
				RAISERROR('Item Code (PLU) already exists',11,1)
			END

			IF(ISNULL(@SupplierId,0) = 0)
			BEGIN
				SET @SupplierId = NULL
			END
			
			IF EXISTS	(
							SELECT	1	
							FROM	ItemMaster
							WHERE	ItemCode = @ItemCode
						)
			BEGIN	
				DECLARE @Msg NVARCHAR(MAX) = 'Item Code '+@ItemCode+' already exists.'
				RAISERROR(@Msg,11,1)
			END
			ELSE
			BEGIN			

			UPDATE	 A
					 SET [ItemCode]				 = @ItemCode					
						,[ItemName]				 = @ItemName
						--,[QuantityAvailable]	 = @QuantityAvailable
						--,[QuantityRequestMin]	 = @QuantityRequestMin
						--,[QuantityRequestMax]	 = @QuantityRequestMax
						--,[QuantityRequested]	 = @QuantityRequested
						,[PriceSellExclVat]		 = @PriceSellExclVat
						--,[PricePurchaseExclVat]	 = @PricePurchaseExclVat
						,[DiscountPercentage]	 = @DiscountPercentage
						,[DiscountedPriceIncl]	 = @DiscountedPriceIncl
						--,[ProfitMargin]			 = @ProfitMargin
						,[Active]				 = @Active
						,[Barcode]				 = @Barcode
						,[SupplierId]			 = @SupplierId
						,[TaxCode] 				 = @TaxCode
						,[UoMId]				 = @UoM
						,[ItemGroupId]			 = @ItemGroupId
			FROM     ItemMaster A
			WHERE	 A.Id = @Id
			
			/*
				INSERT INTO [dbo].[ItemMaster]
				           (
								 [ItemCode]
								,[ItemName]
								,[QuantityAvailable]
								,[QuantityRequestMin]
								,[QuantityRequestMax]
								,[QuantityRequested]
								,[PriceSellExclVat]
								,[PricePurchaseExclVat]
								,[DiscountPercentage]
								,[DiscountedPriceIncl]
								,[ProfitMargin]
								,[Active]
								,[Barcode]
								,[SupplierId]
								,[TaxCode]
						   )
				     VALUES
				           (
								 @ItemCode
								,@ItemName
								,@QuantityAvailable
								,@QuantityRequestMin
								,@QuantityRequestMax
								,@QuantityRequested
								,@PriceSellExclVat
								,@PricePurchaseExclVat
								,@DiscountPercentage
								,@DiscountedPriceIncl
								,@ProfitMargin
								,@Active
								,@Barcode
								,@SupplierId
								,@TaxCode
						   )
				*/

				---------------------------------------
				-------History Log---------------------
				---------------------------------------

				DECLARE @To NVARCHAR(MAX) = 'Item Code: '+ISNULL(@ItemCode,'')
				DECLARE @Des NVARCHAR(MAX) = 'Stock Management: New item added '+ISNULL(@ItemCode,'')

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Insert',
											@Description = @Des,
											@FromValue = '',
											@ToValue = @To,											
											@FieldId = @Id
				
			END
			
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
/****** Object:  StoredProcedure [dbo].[stpItemMaster_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpItemMaster_Select]
	
	@ItemCode NVARCHAR(50),
	@ItemName NVARCHAR(50),	
	@Barcode NVARCHAR(100),
	@Supplier NVARCHAR(100),
	@Vat NVARCHAR(50),
	@ItemGroup NVARCHAR(50)

AS
BEGIN
	
	SET NOCOUNT ON;  

	/*
	Active: All, Active, Inactive
	*/

	SELECT	@ItemCode = ISNULL(@ItemCode,''),
			@ItemName = ISNULL(@ItemName,''),			
			@Barcode = ISNULL(@Barcode,''),
			@Supplier = ISNULL(@Supplier,''),
			@Vat = ISNULL(@Vat,''),
			@ItemGroup = ISNULL(@ItemGroup,'')
	

	IF(@ItemCode = '' AND @ItemName = '' AND @Barcode = '' AND @Supplier = '' AND @Vat = '' AND @ItemGroup = '')
	BEGIN	
		
		SELECT		Id, 
					ItemCode, 
					ItemName, 
					QuantityAvailable, 
					QuantityRequestMin, 
					QuantityRequestMax, 
					QuantityRequested, 
					PriceSellExclVat,
					PriceSellInclVat,
					PricePurchaseExclVat, 
					DiscountPriceSellExcl,
					DiscountPriceSellIncl,
					ProfitMargin,
					DiscountPercentage, 
					Active, 
					Barcode, 
					Supplier, 
                    Vat,
					UoM,
					ItemGroup,
					CompoundItem
		FROM        viwItemMaster
		WHERE		ItemCode IS NOT NULL

	END
	ELSE
	BEGIN
		
		SELECT		Id, 
					ItemCode, 
					ItemName, 
					QuantityAvailable, 
					QuantityRequestMin, 
					QuantityRequestMax, 
					QuantityRequested, 
					PriceSellExclVat,
					PriceSellInclVat,
					PricePurchaseExclVat, 
					DiscountPriceSellExcl,
					DiscountPriceSellIncl,
					ProfitMargin,
					DiscountPercentage, 
					Active, 
					Barcode, 
					Supplier, 
                    Vat,
					UoM,
					ItemGroup,
					CompoundItem
		FROM        viwItemMaster
		WHERE		ISNULL(ItemCode,'') LIKE '%'+@ItemCode+'%'
		AND			ISNULL(ItemName,'') LIKE '%'+@ItemName+'%'
		AND			ISNULL(Barcode,'') LIKE '%'+@Barcode+'%'
		AND			ISNULL(Supplier,'') LIKE '%'+@Supplier+'%'
		AND			ISNULL(VAT,'') LIKE '%'+@Vat+'%'
		AND			ISNULL(ItemGroup,'') LIKE '%'+@ItemGroup+'%'
		AND			ItemCode IS NOT NULL

	END
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpItemMaster_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemMaster_Update]
	-- PARAMETERS
	
		@Id INT,
		@ItemCode NVARCHAR(50),
		@ItemName NVARCHAR(50),		
		@PriceSellExclVat DECIMAL(19,2),		
		@DiscountPercentage DECIMAL(19,6),
		@DiscountedPriceIncl DECIMAL(19,6),		
		@Active BIT,
		@Barcode NVARCHAR(100) = NULL,
		@SupplierId INT = NULL,
		@TaxCode INT,
		@LoggedInUserId NVARCHAR(50),
		@UoM INT,
		@ItemGroupId INT,
		@QuantityRequestMin DECIMAL(19,6) = NULL,
		@QuantityRequestMax DECIMAL(19,6) = NULL

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
						
			
			IF(ISNULL(@SupplierId,0) = 0)
			BEGIN
				SET @SupplierId = NULL
			END		

			UPDATE	 A
					 SET [ItemCode]				 = @ItemCode					
						,[ItemName]				 = @ItemName						
						,[PriceSellExclVat]		 = @PriceSellExclVat						
						,[DiscountPercentage]	 = @DiscountPercentage
						,[DiscountedPriceIncl]	 = @DiscountedPriceIncl						
						,[Active]				 = @Active
						,[Barcode]				 = @Barcode
						,[SupplierId]			 = @SupplierId
						,[TaxCode] 				 = @TaxCode
						,[UoMId]				 = @UoM
						,[ItemGroupId]			 = @ItemGroupId
						,QuantityRequestMin		 = @QuantityRequestMin
						,QuantityRequestMax		 = @QuantityRequestMax
						,TimeStampChange		 = GETDATE()

			FROM     ItemMaster A
			WHERE	 A.Id = @Id
			
			
				---------------------------------------
				-------History Log---------------------
				---------------------------------------

				DECLARE @To NVARCHAR(MAX) = 'Item Code: '+ISNULL(@ItemCode,'')
				DECLARE @Des NVARCHAR(MAX) = 'Stock Management: Item updated '+ISNULL(@ItemCode,'')

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
											@Description = @Des,
											@FromValue = '',
											@ToValue = @To,
											@FieldId = @Id

				
			
			
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
/****** Object:  StoredProcedure [dbo].[stpItemMasterCompounds_Delete]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemMasterCompounds_Delete]
	-- PARAMETERS
	
		@Id INT		

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DELETE	
		FROM	ItemMasterCompounds
		WHERE	Id = @Id
			
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
/****** Object:  StoredProcedure [dbo].[stpItemMasterCompounds_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemMasterCompounds_Insert]
	-- PARAMETERS
	
		@HeaderId INT,
		@ItemMasterItemId INT,
		@Quantity DECIMAL(19,6)
		

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
			IF(@HeaderId = @ItemMasterItemId)
			BEGIN
				RAISERROR('Cannot reference the same item.',11,1)
			END
			ELSE
			BEGIN
				INSERT INTO ItemMasterCompounds (HeaderId, ItemMasterItemId, Quantity)
				VALUES (@HeaderId, @ItemMasterItemId, @Quantity)	
			END
			
					
			
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
/****** Object:  StoredProcedure [dbo].[stpItemMasterCompounds_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpItemMasterCompounds_Select]
	
		@Id INT

AS
BEGIN
	
	SET NOCOUNT ON;  

		SELECT	A.Id,
				C.ItemCode,
				C.ItemName,
				A.Quantity
		FROM	ItemMasterCompounds A
		JOIN	ItemMaster B ON B.Id = A.HeaderId
		JOIN	ItemMaster C ON C.Id = A.ItemMasterItemId
		WHERE	B.Id = @Id	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpItemMasterCompounds_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpItemMasterCompounds_Update]
	-- PARAMETERS
	
		@Id INT,
		@Quantity DECIMAL(19,6)	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF(@Quantity IS NULL)
		BEGIN
			RAISERROR('Quantity cannot be empty.',11,1)
		END
		IF(@Quantity < 0)
		BEGIN
			RAISERROR('Quantity cannot be negative.',11,1)
		END

		UPDATE	ItemMasterCompounds
		SET		Quantity = @Quantity
		WHERE	Id = @Id
			
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
/****** Object:  StoredProcedure [dbo].[stpPOS_Doc_AddItem]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_Doc_AddItem]
	-- PARAMETERS	
	@BarCodeEntry NVARCHAR(MAX),
	@UserId NVARCHAR(50),
	@TerminalId INT,
	@SearchAddItem_Price DECIMAL(19,6) = NULL
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION
		
		--DECLARE @A NVARCHAR(MAX)
		--SET @A = CAST(@TerminalId AS NVARCHAR(50))
		
		/*------------------------
			Item Add to Overview
		---------------------------*/
		DECLARE @ItemId INT = NULL
		DECLARE @DocId INT = NULL
		DECLARE @ValidItem BIT = 0;
		-------------------
		-----If Barcode----
		-------------------
		IF EXISTS (
					SELECT	1 
					FROM	ItemMaster 
					WHERE	ISNULL(Barcode,'') = ISNULL(@BarCodeEntry,'') 
					AND		ISNULL(@BarCodeEntry,'') <> ''
					AND		ISNULL(Active,0) = 1)
		BEGIN
			SELECT	@ItemId = Id
			FROM	ItemMaster
			WHERE	Barcode = @BarCodeEntry
			AND		ISNULL(@BarCodeEntry,'') <> ''
			AND		ISNULL(Active,0) = 1
		END
		-------------------
		----If ItemCode----
		-------------------
		ELSE IF EXISTS(SELECT 1 FROM ItemMaster WHERE ISNULL(ItemCode,'') = ISNULL(@BarCodeEntry,'') AND ISNULL(Active,0) = 1)
		BEGIN
			SELECT	@ItemId = Id
			FROM	ItemMaster
			WHERE	ItemCode = @BarCodeEntry
			AND		ISNULL(Active,0) = 1
		END		

		IF(@ItemId IS NOT NULL)
		BEGIN
			
			SET @ValidItem = 1;

			-- Check for Open Shift
			IF NOT EXISTS (
						  	SELECT	1
							FROM	Shifts
							WHERE	UserId = @UserId
							AND		ShiftStatusId = 1 --Open
						  )
			BEGIN				
				DECLARE @Msg NVARCHAR(MAX) = 'No active shift for '+(SELECT FullName FROM viwUsers WHERE Id = @UserId)
				RAISERROR(@Msg,11,1)
			END
			--Check for Cash Up Completed
			IF NOT EXISTS (
					  		SELECT	1
							FROM	Shifts
							WHERE	UserId = @UserId
							AND		ShiftStatusId = 1 --Open
							AND		CashUpStatus = 2 --Incomplete
						  )
			BEGIN				
				RAISERROR('Cash Up for the current shift has already been completed, please end the Shift.',11,1)
			END

			/*-------------------
				Create Doc Header
			----------------------*/
			IF NOT EXISTS	(
									SELECT	1
									FROM	DocumentTransactionsHeader A
									JOIN	Shifts B ON B.Id = A.ShiftId		
									WHERE	A.DocumentStatusId = 1 --Open
									AND		B.UserId = @UserId
									AND		B.ShiftStatusId = 1 -- Open
									AND		B.CashUpStatus = 2 --Incomplete
									AND		A.TerminalId = @TerminalId								
							)
							--SELECT	1 
							--FROM	DocumentTransactionsHeader 
							--WHERE	DocumentStatusId = 1
							--AND		TerminalId = @TerminalId
							--AND		UserId = @UserId
						   --)--Open
			BEGIN
			
				--Document Number
				DECLARE @DocNum NVARCHAR(50) = NULL
				DECLARE @NewDocNum NVARCHAR(50) = ''

				SELECT		TOP 1 @DocNum = DocumentNumber
				FROM		DocumentTransactionsHeader
				ORDER BY	Id DESC
								
				IF(@DocNum IS NULL)
				BEGIN
					SET @NewDocNum = 'DOC-1'
				END
				ELSE
				BEGIN					
					DECLARE @Num INT = CAST(RIGHT(@DocNum, LEN(@DocNum)-4) AS INT)+1
					SET @NewDocNum = 'DOC-'+CAST(@Num AS NVARCHAR(50))					
				END				
				
				--Shift
				DECLARE @ShiftId INT
				SELECT	@ShiftId = Id 
				FROM	Shifts
				WHERE	ShiftStatusId = 1 --Open
				AND		UserId = @UserId	
		
				--Create Header
				INSERT INTO DocumentTransactionsHeader(DocumentNumber, DocumentStatusId, [Date], UserId, ShiftId, TerminalId, DocumentTypeId)
												VALUES(@NewDocNum, 1, GETDATE(), @UserId, @ShiftId, @TerminalId, 1)
				SET @DocId = SCOPE_IDENTITY()

			END				
				/*-----------
				-- Add Line
				-----------*/
				
				IF(@DocId IS NULL)
				BEGIN
					DECLARE @TableDocId TABLE (Id INT)
					INSERT INTO @TableDocId
					EXEC stpPOS_DocId_Selection @UserId = @UserId ,	@TerminalId = @TerminalId

					SELECT	@DocId = Id
					FROM	@TableDocId					
				END
				---------------
				IF(@DocId > 0)
				BEGIN

					DECLARE @ItemUnitPrice DECIMAL(19,6)
					DECLARE @LineTotal DECIMAL(19,6)

					IF(@SearchAddItem_Price IS NULL)
					BEGIN
						SELECT	@ItemUnitPrice = DiscountPriceSellIncl,
								@LineTotal = DiscountPriceSellIncl --Because default qty is 1 (untill updated)
						FROM	viwItemMaster
						WHERE	Id = @ItemId
					END
					ELSE
					BEGIN
						SET @ItemUnitPrice = @SearchAddItem_Price
						SET @LineTotal = @SearchAddItem_Price --Because default qty is 1 (untill updated)
					END
					
					DECLARE @LineId INT

					INSERT INTO DocumentTransactionsLines(HeaderId, ItemId, Quantity, PriceUnitVatIncl, LineStatus, LineTotal)
					VALUES(@DocId, @ItemId, 1, @ItemUnitPrice, 1, @LineTotal)
					SET @LineId = SCOPE_IDENTITY()

					
					/*--------------------------*/
					--Price Change (Special Price)
					DECLARE @ItemMasterPrice DECIMAL(19,6),
							@ItemMasterDiscountPercentage DECIMAL(19,6)

					SELECT	@ItemMasterPrice = DiscountPriceSellIncl,
							@ItemMasterDiscountPercentage = B.DiscountPercentage
					FROM	DocumentTransactionsLines A
					JOIN	viwItemMaster B ON B.Id = A.ItemId
					WHERE	A.Id = @LineId

					IF(@ItemMasterPrice <> @SearchAddItem_Price)
					BEGIN
						UPDATE	A
						SET		ItemMaster_Price = @ItemMasterPrice,
								ItemMasterDiscountPercentage = @ItemMasterDiscountPercentage,
								PriceChange_Price = @SearchAddItem_Price
						FROM	DocumentTransactionsLines A
						WHERE	HeaderId = @DocId
						AND		Id = @LineId
					END
					/*--------------------------*/

					DECLARE @DocTotal DECIMAL(19,2)
					SELECT	@DocTotal = SUM(B.LineTotal)
					FROM	DocumentTransactionsHeader A
					JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
					WHERE	A.Id = @DocId
					AND		B.LineStatus = 1 --Open
					
					UPDATE	A
					SET		A.DocumentTotal = @DocTotal
					FROM	DocumentTransactionsHeader A
					JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
					WHERE	A.Id = @DocId
					AND		B.LineStatus = 1 --Open

				END
		END

		

		SELECT @ValidItem AS ValidItem
		

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
/****** Object:  StoredProcedure [dbo].[stpPOS_Doc_PriceChange]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_Doc_PriceChange]
	-- PARAMETERS
	@LineId INT,
	@Price DECIMAL(19,6),
	@DocId INT
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF(ISNULL(@Price, 0) <= 0)
		BEGIN
			RAISERROR('Price cannot be smaller than or equal to 0.',11,1)
		END
		ELSE
		BEGIN

			DECLARE @LineTotal DECIMAL(19,2)
			DECLARE @DocTotal DECIMAL(19,6)
						
			UPDATE	A
			SET		PriceUnitVatIncl = @Price,
					LineTotal = (ISNULL(@Price, 0) * ISNULL(Quantity, 0))
			FROM	DocumentTransactionsLines A
			WHERE	HeaderId = @DocId
			AND		Id = @LineId				

			SELECT	@DocTotal = SUM(B.LineTotal)
			FROM	DocumentTransactionsHeader A
			JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
			WHERE	A.Id = @DocId
			AND		B.LineStatus = 1
			
			UPDATE	A
			SET		A.DocumentTotal = @DocTotal
			FROM	DocumentTransactionsHeader A
			JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
			WHERE	A.Id = @DocId
			AND		B.LineStatus = 1
			
			/*--------------------------*/
			DECLARE @ItemMasterPrice DECIMAL(19,6),
					@ItemMasterDiscountPercentage DECIMAL(19,6)
			
			SELECT	@ItemMasterPrice = DiscountPriceSellIncl,
					@ItemMasterDiscountPercentage = B.DiscountPercentage
			FROM	DocumentTransactionsLines A
			JOIN	viwItemMaster B ON B.Id = A.ItemId
			WHERE	A.Id = @LineId
			
			IF(@ItemMasterPrice <> @Price)
			BEGIN
				UPDATE	A
				SET		ItemMaster_Price = @ItemMasterPrice,
						ItemMasterDiscountPercentage = @ItemMasterDiscountPercentage,
						PriceChange_Price = @Price,
						PriceChange = 1 --True
				FROM	DocumentTransactionsLines A
				WHERE	HeaderId = @DocId
				AND		Id = @LineId
			END					

		END
			
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
/****** Object:  StoredProcedure [dbo].[stpPOS_Doc_QtyChange]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_Doc_QtyChange]
	-- PARAMETERS
	@LineId INT,
	@Quantity DECIMAL(19,6),
	@DocId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF(@Quantity <= 0)
		BEGIN
			RAISERROR('Quantity cannot be smaller than or equal to 0.',11,1)
		END
		ELSE
		BEGIN

			DECLARE @LineTotal DECIMAL(19,2)
			DECLARE @DocTotal DECIMAL(19,6)
			

			SELECT	@LineTotal = (@Quantity * PriceUnitVatIncl)				
			FROM	DocumentTransactionsLines
			WHERE	HeaderId = @DocId
			AND		Id = @LineId

			UPDATE	A
			SET		A.Quantity = @Quantity,
					A.LineTotal = @LineTotal
			FROM	DocumentTransactionsLines A
			WHERE	HeaderId = @DocId
			AND		Id = @LineId

			SELECT	@DocTotal = SUM(LineTotal)
			FROM	DocumentTransactionsLines
			WHERE	HeaderId = @DocId
			AND		LineStatus = 1 --Open

			UPDATE	DocumentTransactionsHeader
			SET		DocumentTotal = @DocTotal
			WHERE	Id = @DocId	

		END
			
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
/****** Object:  StoredProcedure [dbo].[stpPOS_Doc_ResumeSale]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_Doc_ResumeSale]
	-- PARAMETERS
	@UserId NVARCHAR(50),
	@TerminalId INT
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION	
		
		IF EXISTS	(
						SELECT	1
						FROM	DocumentTransactionsHeader
						WHERE	DocumentStatusId = 1 --Open
						AND		UserId = @UserId
						AND		TerminalId = @TerminalId
					)
		BEGIN
			RAISERROR('There is sale in progress, finish the current sale first.',11,1)
		END
		ELSE IF NOT EXISTS	(
								SELECT	1 
								FROM	DocumentTransactionsHeader
								WHERE	DocumentStatusId = 2 --Suspended
								AND		UserId = @UserId
								AND		TerminalId = @TerminalId
							)
		BEGIN
			RAISERROR('There is no sale to resume, first suspend a sale.',11,1)
		END
		ELSE
		BEGIN
				
			UPDATE	DocumentTransactionsHeader
			SET		DocumentStatusId = 1 --Open
			WHERE	DocumentStatusId = 2 --Suspended
			AND		UserId = @UserId
			AND		TerminalId = @TerminalId

		END
			
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
/****** Object:  StoredProcedure [dbo].[stpPOS_Doc_SuspendSale]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_Doc_SuspendSale]
	-- PARAMETERS
	@DocId INT,
	@UserId NVARCHAR(50),
	@TerminalId INT
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION	
		
		IF NOT EXISTS	(
							SELECT	*
							FROM	DocumentTransactionsHeader
							WHERE	Id = ISNULL(@DocId,0)
							AND		DocumentStatusId = 1 --Open
							AND		UserId = @UserId
							AND		TerminalId = @TerminalId
						)
		BEGIN
			RAISERROR('There is no sale to suspend.',11,1)
		END
		ELSE IF EXISTS	(
							SELECT	1 
							FROM	DocumentTransactionsHeader
							WHERE	DocumentStatusId = 2 --Suspended
							AND		UserId = @UserId
							AND		TerminalId = @TerminalId
						)
		BEGIN
			RAISERROR('A sale is already suspended, first resume suspended sale.',11,1)
		END
		ELSE
		BEGIN
				
			UPDATE	DocumentTransactionsHeader
			SET		DocumentStatusId = 2 --Suspended
			WHERE	Id = @DocId
			AND		UserId = @UserId
			AND		TerminalId = @TerminalId

		END
			
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
/****** Object:  StoredProcedure [dbo].[stpPOS_Doc_TransactionHeader]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_Doc_TransactionHeader]
	@Id INT	
AS
BEGIN	
	SET NOCOUNT ON;  

	/*Open*/
	SELECT		Id,
				DocumentNumber, 
				DocumentStatusId, 
				[Date], 
				UserId, 
				ShiftId, 
				TerminalId, 
				TenderedCashTotal, 
				TenderedCardTotal, 
				TenderedTotal,
				ISNULL(DocumentTotal,0.0),
				(SELECT ISNULL(CurrencySign,'') FROM CompanyInformation) +''+ FORMAT(ROUND(ISNULL(DocumentTotal,0.0),2),'N2') AS DocumentTotal_Formatted
	FROM        DocumentTransactionsHeader
	WHERE       Id = @Id
	--DocumentStatusId = 1

	
	
	


END
GO
/****** Object:  StoredProcedure [dbo].[stpPOS_Doc_TransactionLines]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_Doc_TransactionLines]
	@Id INT		
AS
BEGIN	
	SET NOCOUNT ON;  

	/*
	SELECT 1 AS Id, 'Olof Bergh' AS Item, 2 AS Qty, 49.99 AS UnitPrice, 99.98 AS Total
	*/

	/*Open*/
	SELECT		A.Id,
				B.ItemName AS Item,
				FORMAT(ROUND(A.Quantity,3),'N3') AS Qty,
				FORMAT(A.PriceUnitVatIncl,'N2') UnitPrice,
				FORMAT(A.LineTotal,'N2') AS Total,
				A.HeaderId, 
				A.ItemId,
				A.LineStatus				
	FROM        DocumentTransactionsLines A
	JOIN		ItemMaster B ON B.Id = A.ItemId
	WHERE		HeaderId = @Id
	AND			A.LineStatus = 1 --Open Lines
	
	


END
GO
/****** Object:  StoredProcedure [dbo].[stpPOS_Doc_VoidDocument]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_Doc_VoidDocument]
	-- PARAMETERS
		@DocumentId INT
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION	
		
		UPDATE	DocumentTransactionsHeader
		SET		DocumentStatusId = 4 --Closed
		WHERE	Id = @DocumentId
				

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
/****** Object:  StoredProcedure [dbo].[stpPOS_Doc_VoidLine]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_Doc_VoidLine]
	-- PARAMETERS
	@DocId INT,
	@LineId INT	
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION	
		
		DECLARE @DocTotal DECIMAL(19,6) = 0.0		
		
		
		UPDATE	DocumentTransactionsLines
		SET		LineStatus = 2 --Closed
		WHERE	HeaderId = @DocId
		AND		Id = @LineId

		SELECT	@DocTotal = SUM(LineTotal)
		FROM	DocumentTransactionsLines
		WHERE	HeaderId = @DocId
		AND		LineStatus = 1 --Open		

		--DECLARE @A NVARCHAR(MAX) = ''
		--SET @A = CAST(@DocTotal AS NVARCHAR(50))
		--SET @A = ISNULL(@A,'NULL')
		--RAISERROR(@A,11,1)		
		
		UPDATE	DocumentTransactionsHeader
		SET		DocumentTotal = ISNULL(@DocTotal,0.0)
		WHERE	Id = @DocId		
			
			
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
/****** Object:  StoredProcedure [dbo].[stpPOS_DocId_Selection]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_DocId_Selection]
	-- PARAMETERS
	@UserId NVARCHAR(50),
	@TerminalId INT
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION			
		
		/*
			Document Selection
		*/
		
		DECLARE @DocId INT = NULL

		SELECT	@DocId = A.Id
		FROM	DocumentTransactionsHeader A
		JOIN	Shifts B ON B.Id = A.ShiftId		
		WHERE	A.DocumentStatusId = 1 --Open
		AND		B.UserId = @UserId
		AND		B.ShiftStatusId = 1 -- Open
		AND		B.CashUpStatus = 2 --Incomplete
		AND		A.TerminalId = @TerminalId		

		
		SELECT ISNULL(@DocId,0) AS Id

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
/****** Object:  StoredProcedure [dbo].[stpPOS_Messages]    Script Date: 2023/11/25 16:02:19 ******/
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
/****** Object:  StoredProcedure [dbo].[stpPOS_PAY_Finalize]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_PAY_Finalize]
	-- PARAMETERS
	@DocId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		UPDATE	A
		SET		DocumentStatusId = 3 --Finalized
		FROM	DocumentTransactionsHeader A
		WHERE	Id = @DocId

		UPDATE		C
		SET			C.QuantityAvailable = (ISNULL(C.QuantityAvailable,0) - (ISNULL(A.Quantity,0) * ISNULL(B.CompoundQty,0)))
		FROM		DocumentTransactionsLines A
		CROSS APPLY	dbo.fnItemMasterCompoundQuantity(A.ItemId) B
		JOIN		ItemMaster C ON C.Id = B.ItemIdCompound
		WHERE		A.HeaderId = @DocId
				
					
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
/****** Object:  StoredProcedure [dbo].[stpPOS_PAY_Reset]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_PAY_Reset]
	-- PARAMETERS
	@DocId INT
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		UPDATE	A
		SET		TenderedCashTotal = NULL,
				TenderedCardTotal = NULL,
				TenderedTotal = NULL
		FROM	DocumentTransactionsHeader A
		WHERE	Id = @DocId
					
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
/****** Object:  StoredProcedure [dbo].[stpPOS_PAY_TenderTypes]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_PAY_TenderTypes]
	-- PARAMETERS
	@DocId INT,
	@TenderType NVARCHAR(10), --Cash/Card
	@TenderedTotal DECIMAL(19,2)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF(@TenderType = 'Cash')
		BEGIN
			UPDATE	A 
			SET		A.TenderedCashTotal = @TenderedTotal
			FROM	DocumentTransactionsHeader A
			WHERE	A.Id = @DocId
		END
		ELSE IF(@TenderType = 'Card')
		BEGIN
			UPDATE	A 
			SET		A.TenderedCardTotal = @TenderedTotal
			FROM	DocumentTransactionsHeader A
			WHERE	A.Id = @DocId
		END

		UPDATE	A
		SET		TenderedTotal = (ISNULL(TenderedCashTotal,0) + ISNULL(TenderedCardTotal,0))
		FROM	DocumentTransactionsHeader A
		WHERE	Id = @DocId

					
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
/****** Object:  StoredProcedure [dbo].[stpPOS_PAY_Values]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_PAY_Values]
	-- PARAMETERS

	@DocId INT
	
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION			
		
		DECLARE @Currency NVARCHAR(10)
		SELECT	@Currency = CurrencySign
		FROM	CompanyInformation

		SELECT	@Currency + FORMAT(ROUND(ISNULL(DocumentTotal,0),2),'N2') AS SalesTotal,
				@Currency + FORMAT(ROUND(CASE WHEN ISNULL(DocumentTotal,0) - ISNULL(TenderedCashTotal,0)+ISNULL(TenderedCardTotal,0) > 0 
				THEN (ISNULL(DocumentTotal,0) - (ISNULL(TenderedCashTotal,0)+ISNULL(TenderedCardTotal,0))) 
				ELSE 0.0 
				END,2),'N2') AS AmountDue,
				@Currency + FORMAT(ROUND(ISNULL(TenderedCashTotal,0),2),'N2') AS CashTendered,
				@Currency + FORMAT(ROUND(ISNULL(TenderedCardTotal,0),2),'N2') AS CardTendered,
				@Currency + FORMAT(ROUND(CASE 
				WHEN (ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) > 0
				THEN CEILING((ISNULL(TenderedCashTotal,0) - ISNULL(DocumentTotal,0)) * 10) / 10 --Round up to nearst 10 cent
				ELSE 0.0
				END,1),'N2') AS Change,
				CAST(ROUND(CASE WHEN ISNULL(DocumentTotal,0) - ISNULL(TenderedCashTotal,0)+ISNULL(TenderedCardTotal,0) > 0 
				THEN (ISNULL(DocumentTotal,0) - (ISNULL(TenderedCashTotal,0)+ISNULL(TenderedCardTotal,0))) 
				ELSE 0.0 END,2) AS DECIMAL(19,2)) AS DocumentTotal
				--CAST(ROUND(DocumentTotal, 2) AS DECIMAL(19,2)) AS DocumentTotal
		FROM	DocumentTransactionsHeader
		WHERE	DocumentStatusId = 1 --Open
		AND		Id = @DocId

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
/****** Object:  StoredProcedure [dbo].[stpPOS_Search_AddItem]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPOS_Search_AddItem]
	-- PARAMETERS

	@ItemId INT,
	@Price DECIMAL(19,6) = NULL,
	@UserId NVARCHAR(50),
	@TerminalId INT,
	--For Returns--
	@Type NVARCHAR(10) = 'SALE', --SALE / RETURN
	@ReturnType NVARCHAR(50) = '', --LINKED/UNLINKED
	@ReturnAllLines BIT = 0,
	@DocNum NVARCHAR(50) = '',
	@UnlinkedHeaderId INT = NULL

AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION			
		
		--Adding the item with custom price

		

		IF(@Type = 'SALE')
		BEGIN
			DECLARE @ItemCode NVARCHAR(50)
			SELECT	@ItemCode = ItemCode
			FROM	ItemMaster
			WHERE	Id = @ItemId

			EXEC stpPOS_Doc_AddItem		@BarCodeEntry = @ItemCode,
										@UserId = @UserId,
										@TerminalId = @TerminalId,
										@SearchAddItem_Price = @Price
		END
		ELSE IF(@Type = 'RETURN')
		BEGIN			
			EXEC stpReturns_AddItem	@ReturnType = @ReturnType, --LINKED/UNLINKED
									@ReturnAllLines = @ReturnAllLines,
									@DocNum = @DocNum,
									@ItemId = @ItemId,
									@Barcode = '',
									@UnlinkedHeaderId = @UnlinkedHeaderId,
									@Price = @Price
		END

		


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
/****** Object:  StoredProcedure [dbo].[stpPOS_Search_Values]    Script Date: 2023/11/25 16:02:19 ******/
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
/****** Object:  StoredProcedure [dbo].[stpPrinters_Delete]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPrinters_Delete]
	-- PARAMETERS
	
	@Id INT,
	@UserId NVARCHAR(50)	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF EXISTS(SELECT 1 FROM Terminals WHERE PrinterId = @Id)
			BEGIN
				RAISERROR('Printer in use at a terminal',11,1)
			END
			ELSE
			BEGIN
				
				DECLARE @PrinterName NVARCHAR(50)
				SELECT	@PrinterName = PrinterName
				FROM	Printers
				WHERE	Id = @Id

				DELETE 
				FROM	Printers
				WHERE	Id = @Id
					
				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @From NVARCHAR(MAX) = 'Printer Name: '+ISNULL(@PrinterName,'')
				DECLARE @To NVARCHAR(MAX) = ''

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Insert',
											@Description = 'Printers: Printer Deleted',
											@FromValue = @From,
											@ToValue = @To,
											@FieldId = @Id
				
			END
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
/****** Object:  StoredProcedure [dbo].[stpPrinters_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPrinters_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@PrinterName NVARCHAR(50),
	@PrinterDescription NVARCHAR(100)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF EXISTS(SELECT 1 FROM Printers WHERE PrinterName = @PrinterName)
			BEGIN
				RAISERROR('Printer already exists',11,1)
			END
			ELSE
			BEGIN		

				DECLARE @Id INT

				INSERT INTO Printers(PrinterName, PrinterDescription)
							  VALUES(@PrinterName, @PrinterDescription)
				
				SET @Id = SCOPE_IDENTITY()

				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @To NVARCHAR(MAX) = 'Name: '+ISNULL(@PrinterName,'')+', Description: '+ISNULL(@PrinterDescription,'')

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Insert',
											@Description = 'Printers: New Printer created',
											@FromValue = '',
											@ToValue = @To,
											@FieldId = @Id
			END
			
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
/****** Object:  StoredProcedure [dbo].[stpPrinters_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpPrinters_Select]	
	

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT      Id, 
				PrinterName, 
				PrinterDescription
	FROM        Printers
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpPrinters_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpPrinters_Update]
	-- PARAMETERS
	
	@Id INT,	
	@PrinterDescription NVARCHAR(100),
	@UserId NVARCHAR(50)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			DECLARE @Old_PrinterDescription NVARCHAR(100)
			SELECT	@Old_PrinterDescription = PrinterDescription
			FROM	Printers
			WHERE	Id = @Id

			UPDATE	Printers
			SET		PrinterDescription = @PrinterDescription
			WHERE	Id = @Id


			IF(ISNULL(@PrinterDescription,'') <> ISNULL(@Old_PrinterDescription,''))
			BEGIN			
				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @From NVARCHAR(MAX) = 'Description: '+ISNULL(@Old_PrinterDescription,'')
				DECLARE @To NVARCHAR(MAX) = 'Description: '+ISNULL(@PrinterDescription,'')

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Update',
											@Description = 'Printers: Printer Description changed',
											@FromValue = @From,
											@ToValue = @To,
											@FieldId = @Id
				
			END
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
/****** Object:  StoredProcedure [dbo].[stpResetPassword]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpResetPassword]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@CurrentPass NVARCHAR(100),
	@NewPass NVARCHAR(100),
	@ConfirmPass NVARCHAR(100)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @LoginName NVARCHAR(100)
		DECLARE @Pass NVARCHAR(250)

		SELECT	@LoginName = LoginName,
				@Pass = [Password]
		FROM	Users
		WHERE	Id = @UserId

		IF(dbo.fnPasswordHash(@CurrentPass) <> @Pass)
		BEGIN
			RAISERROR('Current password incorrect',11,1)
		END
		ELSE IF(@NewPass <> @ConfirmPass COLLATE Latin1_General_CS_AS)
		BEGIN
			RAISERROR('Passwords do not match',11,1)
		END
		ELSE
		BEGIN
			
			UPDATE	Users
			SET		[Password] = dbo.fnPasswordHash(@NewPass)
			WHERE	Id = @UserId

			---------------------------------------
			-------History Log---------------------
			---------------------------------------		
			DECLARE @Des NVARCHAR(MAX) = 'Users: '+@LoginName+' password changed'

			EXEC stpHistoryLog_Insert	@UserId = @UserId,
										@Action = 'Update',
										@Description = @Des,
										@FromValue = '',
										@ToValue = '',											
										@FieldId = @UserId
		
		END
			
			
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
/****** Object:  StoredProcedure [dbo].[stpResetPassword_ValidLoginName]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpResetPassword_ValidLoginName]
	
	@LoginName NVARCHAR(100)

AS
BEGIN	
	SET NOCOUNT ON;  

	IF EXISTS	(
					SELECT	1
					FROM	Users
					WHERE	LoginName = @LoginName
				)
	BEGIN
		SELECT	CAST(1 AS BIT) AS Result, Id AS UserId		
		FROM	Users
		WHERE	LoginName = @LoginName
	END
	ELSE
	BEGIN
		SELECT CAST(0 AS BIT) AS Result, '' AS UserId		
	END
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpReturns_AddItem]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpReturns_AddItem]
	-- PARAMETERS	
	
	@ReturnType NVARCHAR(50), --LINKED/UNLINKED
	@ReturnAllLines BIT,
	@DocNum NVARCHAR(50),
	@Barcode NVARCHAR(50),
	@UnlinkedHeaderId INT,
	@ItemId INT = NULL,
	@Price DECIMAL(19,6) = NULL

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION				
			
			IF(@ItemId IS NOT NULL)
			AND EXISTS (	
							SELECT	1
							FROM	DocumentTransactionsHeader A
							JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
							WHERE	A.DocumentNumber = @DocNum
							AND		B.Id = @ItemId
					    )
			BEGIN --Convert the line id to the item master id
				SELECT	@ItemId = B.ItemId
				FROM	DocumentTransactionsHeader A
				JOIN	DocumentTransactionsLines B ON B.HeaderId = A.Id
				WHERE	A.DocumentNumber = @DocNum
				AND		B.Id = @ItemId
			END
			ELSE
			IF(@ItemId IS NULL)
			BEGIN
				SELECT	@ItemId = Id
				FROM	ItemMaster
				WHERE	ItemCode = ISNULL(@Barcode,'')
				OR		ISNULL(Barcode,'') = ISNULL(@Barcode, '')
			END

			IF(@ItemId IS NOT NULL OR @ReturnAllLines = 1)
			BEGIN
				IF(@ReturnType = 'LINKED')
				BEGIN
					--Safty Check
					DECLARE @Tbl TABLE (Valid BIT)
					INSERT INTO @Tbl
					EXEC calcReturns_ValidDocNum @DocNum

					IF((SELECT Valid FROM @Tbl) = 1) --Valid = True
					BEGIN --LINKED
						IF(@ReturnAllLines = 1)
						BEGIN
							-- All Lines
							INSERT INTO [Returns] (ReturnType, OriginalDocNum, OriginalDocId, ItemId, Qty, PriceSell, Status)
							SELECT	@ReturnType, UPPER(@DocNum), B.Id, A.ItemId, A.Quantity, A.PriceUnitVatIncl, 2 --InComplete
							FROM	DocumentTransactionsLines A
							JOIN	DocumentTransactionsHeader B ON B.Id = A.HeaderId
							WHERE	B.DocumentNumber = @DocNum
							AND		A.LineStatus = 1 --Open
						END
						ELSE
						BEGIN
							
							IF NOT EXISTS	( 
												SELECT	1
												FROM	DocumentTransactionsLines A
												JOIN	DocumentTransactionsHeader B ON B.Id = A.HeaderId												
												WHERE	A.ItemId = @ItemId
												AND		B.DocumentNumber = @DocNum
												AND		A.LineStatus = 1 --Open
											)
							BEGIN
							
								DECLARE @Msg NVARCHAR(255) = ''
								SELECT	@Msg = ISNULL(ItemName, '') + ' was not on the orignal invoice.'
								FROM	ItemMaster
								WHERE	Id = @ItemId

								RAISERROR(@Msg, 11, 1)
							END
							ELSE
							BEGIN
								
								-- Single Line
								INSERT INTO [Returns] (ReturnType, OriginalDocNum, OriginalDocId,  ItemId, Qty, PriceSell, Status)
								SELECT	TOP 1 @ReturnType, UPPER(@DocNum), B.Id, @ItemId, 1, A.PriceUnitVatIncl, 2 --InComplete
								FROM	DocumentTransactionsLines A
								JOIN	DocumentTransactionsHeader B ON B.Id = A.HeaderId
								WHERE	A.ItemId = @ItemId
								AND		B.DocumentNumber = @DocNum
								AND		A.LineStatus = 1 --Open
							END
						END
					
					END
				END
				ELSE --UNLINKED
				BEGIN				
					
					DECLARE @NewUnlinkedHeaderId INT = NULL

					IF(ISNULL(@UnlinkedHeaderId,0) > 0)
					BEGIN
						SET @NewUnlinkedHeaderId = @UnlinkedHeaderId
					END
					ELSE
					BEGIN
						SET @NewUnlinkedHeaderId = ISNULL(@NewUnlinkedHeaderId, 0) +1
					END

					-- Single Line
					INSERT INTO [Returns] (ReturnType, OriginalDocNum, UnlinkedHeaderId, ItemId, Qty, PriceSell, Status)
					SELECT	TOP 1 @ReturnType, @DocNum, @NewUnlinkedHeaderId, @ItemId, 1, COALESCE(@Price,DiscountPriceSellIncl), 2 --InComplete
					FROM	viwItemMaster
					WHERE	Id = @ItemId					
				END
			END

			
			
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
/****** Object:  StoredProcedure [dbo].[stpReturns_Cancel]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpReturns_Cancel]
	-- PARAMETERS	
	
	@ReturnType NVARCHAR(50), --LINKED/UNLINKED	
	@OrignalDocId INT,	
	@UnlinkedHeaderId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF(@ReturnType = 'LINKED' AND ISNULL(@OrignalDocId, 0) > 0)
			BEGIN
				DELETE
				FROM	[Returns]
				WHERE	OriginalDocId = @OrignalDocId
			END
			ELSE IF(@ReturnType = 'UNLINKED' AND ISNULL(@UnlinkedHeaderId,0) > 0)
			BEGIN
				DELETE
				FROM	[Returns]
				WHERE	UnlinkedHeaderId = @UnlinkedHeaderId
			END

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
/****** Object:  StoredProcedure [dbo].[stpReturns_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpReturns_Select]	
	
	@ReturnType NVARCHAR(50),
	@DocId INT,
	@UnlinkedHeaderId INT
	
AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		A.Id,
				B.ItemName,
				CAST(A.Qty AS DECIMAL(19,2)) AS Qty,
				CAST(A.PriceSell AS DECIMAL(19,2)) AS UnitPrice,
				CAST(ISNULL(A.PriceSell, 0) * ISNULL(A.Qty, 0) AS DECIMAL(19,2)) AS LineTotal
	FROM		[Returns] A
	JOIN		viwItemMaster B ON B.Id = A.ItemId
	WHERE		A.ReturnType = @ReturnType
	AND			(A.OriginalDocId = @DocId OR A.UnlinkedHeaderId = @UnlinkedHeaderId)
	AND			A.[Status] = 2 --InComplete
	

	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpRoleGroup_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpRoleGroup_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@RoleGroupName NVARCHAR(50),
	@RoleGroupDescription NVARCHAR(100)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @Id INT

		INSERT INTO RoleGroups ([Name], [Description])
		VALUES(@RoleGroupName, @RoleGroupDescription)
		SET @Id = SCOPE_IDENTITY()

		---------------------------------------
		-------History Log---------------------
		---------------------------------------
		DECLARE @To NVARCHAR(MAX) = 'Name: '+ISNULL(@RoleGroupName,'')+', Description: '+ISNULL(@RoleGroupDescription,'')

		EXEC stpHistoryLog_Insert	@UserId = @UserId,	
									@Action = 'Insert',
									@Description = 'Role Groups: New Role Group created',
									@FromValue = '',
									@ToValue = @To,
									@FieldId = @Id
		
			
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
/****** Object:  StoredProcedure [dbo].[stpRoleGroup_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpRoleGroup_Update]
	-- PARAMETERS
	
	@Id INT,
	@UserId NVARCHAR(50),	
	@RoleGroupDescription NVARCHAR(100)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @RoleGroupDescriptionOld NVARCHAR(100)

		SELECT	@RoleGroupDescriptionOld = [Description]
		FROM	RoleGroups
		WHERE	Id = @Id

		UPDATE		RoleGroups
		SET			[Description] = @RoleGroupDescription
		WHERE		Id = @Id

		---------------------------------------
		-------History Log---------------------
		---------------------------------------
		
		DECLARE @To NVARCHAR(MAX) = ''
		DECLARE @From NVARCHAR(MAX) = ''

		IF(ISNULL(@RoleGroupDescription,'') <> ISNULL(@RoleGroupDescriptionOld,''))
		BEGIN
			SET @To = 'Description: '+ISNULL(@RoleGroupDescription,'')
			SET @From = 'Description: '+ISNULL(@RoleGroupDescriptionOld,'')
		END		 

		EXEC stpHistoryLog_Insert	@UserId = @UserId,	
									@Action = 'Update',
									@Description = 'Role Groups: Role Group updated',
									@FromValue = @From,
									@ToValue = @To
		
			
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
/****** Object:  StoredProcedure [dbo].[stpRoleGroups_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpRoleGroups_Select]	
	

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		A.Id,
				A.[Name],
				A.[Description],
				'Users ('+CAST(ISNULL(B.[Count], 0) AS NVARCHAR(50))+')' AS RoleGroupUser,
				'Objects ('+CAST(ISNULL(C.[Count], 0) AS NVARCHAR(50))+')' AS RoleGroupObjects
	FROM		RoleGroups A
	LEFT JOIN	(
					SELECT		COUNT(UserId) AS [Count], RoleGroupId
					FROM		RoleGroupUsers
					GROUP BY	RoleGroupId
				) B ON B.RoleGroupId = A.Id
	LEFT JOIN	(
					SELECT		COUNT(ObjectId) AS [Count], RoleGroupId
					FROM		RoleGroupObjects
					GROUP BY	RoleGroupId
				) C	ON C.RoleGroupId = A.Id




	/*
	SELECT		A.Id,
				A.[Name],
				A.[Description],
				'Users ('+CAST(COUNT(B.UserId) AS NVARCHAR(50))+')' AS RoleGroupUser,
				'Objects ('+CAST(COUNT(C.ObjectId) AS NVARCHAR(50))+')' AS RoleGroupObjects
	FROM		RoleGroups A
	LEFT JOIN	RoleGroupUsers B ON B.RoleGroupId = A.Id
	LEFT JOIN	RoleGroupObjects C ON C.RoleGroupId = A.Id
	GROUP BY	A.Id, A.[Name], A.[Description]	
	*/
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpRoleGroups_Values_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpRoleGroups_Values_Select]
	
	@Id INT

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		[Name],
				[Description]
	FROM        RoleGroups 
	WHERE		Id = @Id
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpRoleGroupsObjects_Delete]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpRoleGroupsObjects_Delete]
	-- PARAMETERS
	
	@RoleGroupId INT,
	@ObjectId NVARCHAR(50),
	@LoggedInUserId NVARCHAR(50)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION	

			DECLARE @ObjectName NVARCHAR(250),
					@RoleGroupName NVARCHAR(50)

			SELECT	@RoleGroupName = [Name]
			FROM	RoleGroups
			WHERE	Id = @RoleGroupId

			SELECT	@ObjectName = ISNULL([ObjectName],'')
			FROM	Objects
			WHERE	Id = @ObjectId

			DELETE
			FROM	RoleGroupObjects
			WHERE	RoleGroupId = @RoleGroupId
			AND		ObjectId = @ObjectId

			---------------------------------------
			-------History Log---------------------
			---------------------------------------

			DECLARE @Fr NVARCHAR(MAX) = 'Object Name: '+ISNULL(@ObjectName,'')
			DECLARE @Des NVARCHAR(MAX) = 'Role Group Objects: '+@ObjectName+' removed from Role Group: '+ISNULL(@RoleGroupName,'')

			EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
										@Action = 'Delete',
										@Description = @Des,
										@FromValue = @Fr,
										@ToValue = ''
			
		
			
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
/****** Object:  StoredProcedure [dbo].[stpRoleGroupsObjects_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpRoleGroupsObjects_Insert]
	-- PARAMETERS
	
	@RoleGroupId INT,
	@ObjectId NVARCHAR(50),
	@LoggedInUserId NVARCHAR(50)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @ObjectName NVARCHAR(250),
				@RoleGroupName NVARCHAR(50)

		SELECT	@RoleGroupName = [Name]
		FROM	RoleGroups
		WHERE	Id = @RoleGroupId

		SELECT	@ObjectName = ISNULL(ObjectName,'')
		FROM	[Objects]
		WHERE	Id = @ObjectId


		IF(ISNULL(@ObjectId,'') = '')
		BEGIN
			RAISERROR('Must select a user',11,1)
		END
		ELSE IF EXISTS	(
							SELECT	1
							FROM	RoleGroupObjects
							WHERE	ObjectId = @ObjectId
							AND		RoleGroupId = @RoleGroupId
						)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX) = @ObjectName + ' already in role group'
			RAISERROR(@Msg,11,1)
		END
		ELSE
		BEGIN

			INSERT INTO RoleGroupObjects(ObjectId, RoleGroupId)
			VALUES (@ObjectId, @RoleGroupId)

			---------------------------------------
			-------History Log---------------------
			---------------------------------------

			DECLARE @To NVARCHAR(MAX) = 'Object Name: '+ISNULL(@ObjectName,'')
			DECLARE @Des NVARCHAR(MAX) = 'Role Group Objects: '+@ObjectName+' added to Role Group: '+ISNULL(@RoleGroupName,'')

			EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
										@Action = 'Insert',
										@Description = @Des,
										@FromValue = '',
										@ToValue = @To
			
		END
			
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
/****** Object:  StoredProcedure [dbo].[stpRoleGroupsObjects_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpRoleGroupsObjects_Select]
	
	@RoleGroupId INT

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		ObjectId,
				RoleGroupId,
				B.ObjectName AS [Object],
				C.[Name] AS RoleGroup
	FROM		RoleGroupObjects A
	JOIN		[Objects] B ON B.Id = A.ObjectId
	JOIN		RoleGroups C ON C.Id = A.RoleGroupId
	WHERE		RoleGroupId = @RoleGroupId
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpRoleGroupsUsers_Delete]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpRoleGroupsUsers_Delete]
	-- PARAMETERS
	
	@RoleGroupId INT,
	@UserId UNIQUEIDENTIFIER,
	@LoggedInUserId NVARCHAR(50)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION	

			DECLARE @UserName NVARCHAR(250),
					@RoleGroupName NVARCHAR(50)

			SELECT	@RoleGroupName = [Name]
			FROM	RoleGroups
			WHERE	Id = @RoleGroupId

			SELECT	@UserName = ISNULL([Name],'')+' '+ISNULL(Surname,'')
			FROM	Users
			WHERE	Id = @UserId

			DELETE
			FROM	RoleGroupUsers
			WHERE	RoleGroupId = @RoleGroupId
			AND		UserId = @UserId

			---------------------------------------
			-------History Log---------------------
			---------------------------------------

			DECLARE @Fr NVARCHAR(MAX) = 'User Name: '+ISNULL(@UserName,'')
			DECLARE @Des NVARCHAR(MAX) = 'Role Group Users: '+@UserName+' removed from Role Group: '+ISNULL(@RoleGroupName,'')

			EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
										@Action = 'Delete',
										@Description = @Des,
										@FromValue = @Fr,
										@ToValue = ''
			
		
			
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
/****** Object:  StoredProcedure [dbo].[stpRoleGroupsUsers_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpRoleGroupsUsers_Insert]
	-- PARAMETERS
	
	@RoleGroupId INT,
	@UserId NVARCHAR(50),
	@LoggedInUserId NVARCHAR(50)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @UserName NVARCHAR(250),
				@RoleGroupName NVARCHAR(50)

		SELECT	@RoleGroupName = [Name]
		FROM	RoleGroups
		WHERE	Id = @RoleGroupId

		SELECT	@UserName = ISNULL([Name],'')+' '+ISNULL(Surname,'')
		FROM	Users
		WHERE	Id = @UserId


		IF(ISNULL(@UserId,'') = '')
		BEGIN
			RAISERROR('Must select a user',11,1)
		END
		ELSE IF EXISTS	(
							SELECT	1
							FROM	RoleGroupUsers
							WHERE	UserId = @UserId
							AND		RoleGroupId = @RoleGroupId
						)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX) = @UserName + ' already in role group'
			RAISERROR(@Msg,11,1)
		END
		ELSE
		BEGIN

			INSERT INTO RoleGroupUsers (UserId, RoleGroupId)
			VALUES (@UserId, @RoleGroupId)

			---------------------------------------
			-------History Log---------------------
			---------------------------------------

			DECLARE @To NVARCHAR(MAX) = 'User Name: '+ISNULL(@UserName,'')
			DECLARE @Des NVARCHAR(MAX) = 'Role Group Users: '+@UserName+' added to Role Group: '+ISNULL(@RoleGroupName,'')

			EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
										@Action = 'Insert',
										@Description = @Des,
										@FromValue = '',
										@ToValue = @To
			
		END
			
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
/****** Object:  StoredProcedure [dbo].[stpRoleGroupsUsers_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpRoleGroupsUsers_Select]
	
	@RoleGroupId INT

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		UserId,
				RoleGroupId,
				ISNULL(B.[Name],'')+' '+ISNULL(B.Surname,'') AS UserName,
				C.[Name] AS RoleGroup
	FROM		RoleGroupUsers A
	JOIN		Users B ON B.Id = A.UserId
	JOIN		RoleGroups C ON C.Id = A.RoleGroupId
	WHERE		RoleGroupId = @RoleGroupId
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpSalesHistory_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpSalesHistory_Select]	
	
	@ShiftId INT = NULL,
	@DocNum NVARCHAR(50) = NULL,
	@Date DATE = NULL,
	@User NVARCHAR(50) = NULL,
	@Terminal NVARCHAR(50) = NULL

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		A.Id,
				A.DocumentNumber,
				B.[Name] AS [Status],
				C.[Type],
				[Date],
				D.FullName AS [User],
				E.TerminalName,
				A.ShiftId,
				'Items ('+CAST(ISNULL(F.Cnt,0) AS NVARCHAR(10))+')' AS Items,
				TenderedCashTotal,
				TenderedCardTotal,
				TenderedTotal,
				DocumentTotal
	FROM		DocumentTransactionsHeader A
	JOIN		DocumentTransactionsHeaderStatus B ON B.Id = A.DocumentStatusId
	JOIN		DocumentType C ON C.Id = A.DocumentTypeId
	JOIN		viwUsers D ON D.Id = A.UserId
	JOIN		Terminals E ON E.Id = A.TerminalId
	LEFT JOIN	(
					SELECT		HeaderId, COUNT(Id) AS Cnt
					FROM		DocumentTransactionsLines
					WHERE		LineStatus = 1--Open
					GROUP BY	HeaderId
				) F ON F.HeaderId = A.Id
	WHERE		A.DocumentStatusId = 3--Finalized
	AND			A.DocumentTypeId = 1--Sale
	AND			(@ShiftId IS NULL OR A.ShiftId = @ShiftId)
	AND			(@DocNum IS NULL OR A.DocumentNumber LIKE '%'+@DocNum+'%')
	AND			(@Date IS NULL OR CAST(A.[Date] AS DATE) = @Date)
	AND			(@User IS NULL OR D.FullName LIKE '%'+@User+'%')
	AND			(@Terminal IS NULL OR E.TerminalName LIKE '%'+@Terminal+'%')
	ORDER BY	A.Id DESC
			
END
GO
/****** Object:  StoredProcedure [dbo].[stpSalesHistoryLines_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpSalesHistoryLines_Select]	
	
	@DocId INT

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		B.ItemCode,
				B.ItemName,
				A.Quantity,
				CAST(PriceUnitVatIncl AS DECIMAL(19,2)) AS Price,
				CAST(LineTotal AS DECIMAL(19,2)) AS LineTotal,
				CASE WHEN ISNULL(PriceChange,0) = 1 THEN 'True' ELSE 'False' END AS PriceChanged,
				ItemMaster_Price AS FullSellPrice,
				ItemMasterDiscountPercentage AS FullDiscountPercentage,	
				CASE WHEN ISNULL(Promotion,0) = 1 THEN 'True' ELSE 'False' END AS IsPromotion,
				C.PromoName
	FROM		DocumentTransactionsLines A
	JOIN		viwItemMaster B ON B.Id = A.ItemId
	LEFT JOIN	Promotions C ON C.Id = A.PromotionId
	WHERE		A.HeaderId = @DocId
	AND			A.LineStatus = 1 --Open
			
END
GO
/****** Object:  StoredProcedure [dbo].[stpSecurityAccess]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpSecurityAccess]
	
	@ObjectId NVARCHAR(50),
	@UserId NVARCHAR(50)

AS
BEGIN	
	SET NOCOUNT ON;  
	
	IF EXISTS	(
					SELECT	1 
					FROM	RoleGroupObjects A
					JOIN	RoleGroupUsers B ON B.RoleGroupId = A.RoleGroupId
					WHERE	UserId = @UserId
					AND		ObjectId = @ObjectId
				)
	BEGIN 
		SELECT CAST(1 AS BIT) AS Result
	END
	ELSE
	BEGIN
		SELECT CAST(0 AS BIT) AS Result
	END
	
	
	
	
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpShifts_End]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpShifts_End]
	-- PARAMETERS
		@Id INT	
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF NOT EXISTS	(
								SELECT	1
								FROM	CashUp
								WHERE	ShiftId = @Id
								AND		StatusId = 1 --InComplete
							)
			BEGIN
				RAISERROR('Please complete Cash Up first.',11,1)
			END
			ELSE IF EXISTS	(
								SELECT	1
								FROM	DocumentTransactionsHeader
								WHERE	ShiftId = @Id
								AND		DocumentTypeId = 1 --Sale
								AND		(
											DocumentStatusId = 1 --Open
										OR	DocumentStatusId = 2 --Suspended
										)
							)
			BEGIN
				RAISERROR('Please complete the Open / Suspended Sale(s)',11,1)				
			END
			ELSE
			BEGIN
				UPDATE	Shifts
				SET		ShiftStatusId = 2, --Closed
						EndDate = GETDATE()
				WHERE	Id = @Id
			END
			
		


			
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
/****** Object:  StoredProcedure [dbo].[stpShifts_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpShifts_Insert]
	-- PARAMETERS
		@UserId NVARCHAR(50),
		@StartFloat DECIMAL(19,2)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF EXISTS	(
							SELECT	1
							FROM	Shifts
							WHERE	UserId = @UserId
							AND		ShiftStatusId = 1--Open
						)
			BEGIN
				DECLARE @UserName NVARCHAR(50)
				SELECT	@UserName = B.FullName
				FROM	Shifts A
				JOIN	viwUsers B ON B.Id = A.UserId
				WHERE	UserId = @UserId
				AND		ShiftStatusId = 1--Open
				
				DECLARE @Msg NVARCHAR(MAX) = 'An open shift for '+@UserName+' already exists.'

				RAISERROR(@Msg,11,1)
			END
			ELSE
			BEGIN
				INSERT INTO Shifts(UserId, ShiftStatusId, StartDate, StartFloat, CashUpStatus)
				VALUES(@UserId, 1, GETDATE(), @StartFloat, 2)
			END
			
			

			
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
/****** Object:  StoredProcedure [dbo].[stpShifts_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpShifts_Select]
	
	@UserName NVARCHAR(50) = '',
	@StartDate DATE = NULL,
	@EndDate DATE = NULL

AS
BEGIN
	
	SET NOCOUNT ON;  
	
	

		SELECT		A.Id,
					C.FullName AS UserName,
					B.[Name] AS ShiftStatus,
					A.StartDate,
					A.EndDate,
					CAST(A.StartFloat AS DECIMAL(19,2)) AS StartFloat,
					CAST(A.CashUpOut AS DECIMAL(19,2)) AS CashUpOut,
					CAST(ISNULL(A.CashUpOut,0) - (ISNULL(A.StartFloat,0) ) AS DECIMAL(19,2)) AS Variance,
					D.[Name] AS CashUpStatus,
					'Sales ('+CAST(ISNULL(E.Cnt,0) AS NVARCHAR(10))+')' AS Sales,
					F.TenderedCardTotal AS SalesCardTotal,
					A.CardMachineTotal AS CashUpCardTotal,
					ISNULL(F.TenderedCardTotal,0) - ISNULL(A.CardMachineTotal,0) AS CardTotalVariance
		FROM		Shifts A
		JOIN		ShiftStatus B ON B.Id = A.ShiftStatusId
		JOIN		viwUsers C ON C.Id = A.UserId
		JOIN		CashUpStatus D ON D.Id = A.CashUpStatus
		LEFT JOIN	(
						SELECT		ShiftId, COUNT(Id) AS Cnt
						FROM		DocumentTransactionsHeader
						WHERE		DocumentStatusId = 3--Finalized
						AND			DocumentTypeId = 1--Sale
						GROUP BY	ShiftId, DocumentStatusId, DocumentTypeId
					) E ON E.ShiftId = A.Id
		LEFT JOIN	(
						SELECT		ShiftId, SUM(TenderedCardTotal) AS TenderedCardTotal
						FROM		DocumentTransactionsHeader
						WHERE		DocumentStatusId = 3--Finalized
						AND			DocumentTypeId = 1--Sale
						GROUP BY	ShiftId
					) F ON F.ShiftId = A.Id
		WHERE		(ISNULL(C.FullName,'') LIKE '%'+@UserName+'%')
		AND			(@StartDate IS NULL OR CAST(A.StartDate AS DATE) = @StartDate)
		AND			(@EndDate IS NULL OR CAST(A.EndDate AS DATE) = @EndDate)
		ORDER BY	ShiftStatusId ASC
		
		
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Insert]
	-- PARAMETERS
		@ItemId INT, 
		@QuantityReceived DECIMAL(19,6), 
		@PricePurchaseExcl DECIMAL(19,2), 
		@PricePurchaseIncl DECIMAL(19,2), 
		@SupplierId INT, 
		@ReceivedByUserId NVARCHAR(50),
		@InvoiceNum NVARCHAR(50)


AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			DECLARE @ItemName NVARCHAR(50)
			SELECT	@ItemName = ItemName
			FROM	ItemMaster
			WHERE	Id = @ItemId

			DECLARE @Id INT
			
			INSERT INTO StockReceive(ItemId, ReceiveDate, QuantityReceived, PricePurchaseExcl, PricePurchaseIncl, SupplierId, ReceivedByUserId)
			VALUES(@ItemId, GETDATE(), @QuantityReceived, @PricePurchaseExcl, @PricePurchaseIncl, @SupplierId, @ReceivedByUserId)
			SET @Id = SCOPE_IDENTITY()

			--DECLARE @QtyAvail DECIMAL(19,6)
			--SELECT	@QtyAvail = QuantityAvailable
			--FROM	ItemMaster
			--WHERE	Id = @Id

			UPDATE	A
			SET		A.QuantityAvailable = (ISNULL(A.QuantityAvailable, 0) + @QuantityReceived)
			FROM	ItemMaster A
			WHERE	Id = @ItemId

			---------------------------------------
			-------History Log---------------------
			---------------------------------------

			DECLARE @To NVARCHAR(MAX) = 'Quantity: '+ISNULL(CAST(@QuantityReceived AS NVARCHAR(50)),'')
			DECLARE @Des NVARCHAR(MAX) = 'Stock Received for item: '+ISNULL(@ItemName,'')

			EXEC stpHistoryLog_Insert	@UserId = @ReceivedByUserId,	
										@Action = 'Insert',
										@Description = @Des,
										@FromValue = '',
										@ToValue = @To,
										@FieldId = @Id			
		
			
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
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Select]    Script Date: 2023/11/25 16:02:19 ******/
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
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Temp_Header]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Temp_Header]
	-- PARAMETERS
		
AS
BEGIN
	SET NOCOUNT ON; 
			
		IF EXISTS	(
						SELECT	1
						FROM	StockReceive_Temp
					)
		BEGIN
			SELECT	TOP 1 SupplierId, InvoiceNum, CAST(ReceiveDate AS DATE) AS ReceiveDate, 1 AS [Exists]
			FROM	StockReceive_Temp
		END
		ELSE
		BEGIN
			SELECT NULL AS SupplierId, NULL AS InvoiceNum, CAST(GETDATE() AS DATE) AS ReceiveDate, 0 AS [Exists]
		END

		
		
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Temp_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Temp_Insert]
	-- PARAMETERS
		@ItemId INT, 
		@QuantityReceived DECIMAL(19,6), 
		@PricePurchaseExcl DECIMAL(19,2), 
		@PricePurchaseIncl DECIMAL(19,2), 
		@SupplierId INT, 
		@ReceivedByUserId NVARCHAR(50),
		@InvoiceNum NVARCHAR(50),
		@ReceiveDate DATETIME
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION	
			
			INSERT INTO StockReceive_Temp(ItemId, ReceiveDate, QuantityReceived, PricePurchaseExcl, PricePurchaseIncl, SupplierId, ReceivedByUserId, InvoiceNum)
			VALUES(@ItemId, @ReceiveDate, @QuantityReceived, @PricePurchaseExcl, @PricePurchaseIncl, @SupplierId, @ReceivedByUserId, @InvoiceNum)
			
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
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Temp_ItemDetail]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Temp_ItemDetail]
	-- PARAMETERS
	@ItemId INT	
AS
BEGIN
	SET NOCOUNT ON; 
			
	SELECT		B.UoM, A.DiscountedPriceIncl AS PriceSellIncl
	FROM		ItemMaster A
	LEFT JOIN	UoM B ON B.Id = A.UoMId
	WHERE		A.Id = @ItemId
		
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Temp_Select]    Script Date: 2023/11/25 16:02:19 ******/
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
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Temp_Totals]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Temp_Totals]
	-- PARAMETERS
		
AS
BEGIN
	SET NOCOUNT ON; 
			
		SELECT	CAST(SUM(PricePurchaseIncl) AS DECIMAL(19,2)) AS PricePurchaseIncl,
				CAST(SUM(PricePurchaseExcl) AS DECIMAL(19,2)) AS PricePurchaseExcl,
				CAST(SUM(PricePurchaseIncl) - SUM(PricePurchaseExcl) AS DECIMAL(19,2)) AS VAT 
		FROM	StockReceive_Temp
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Tmp_Cancel]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Tmp_Cancel]
	-- PARAMETERS
			
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION
		
			DELETE FROM StockReceive_Temp

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
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Tmp_Delete]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Tmp_Delete]
	-- PARAMETERS
		@Id INT		
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION			
		
		DELETE
		FROM	StockReceive_Temp
		WHERE	Id = @Id

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
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Tmp_ItemDetail]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Tmp_ItemDetail]
	-- PARAMETERS
		@Id INT
AS
BEGIN
	SET NOCOUNT ON; 
			
		SELECT	B.ItemName, A.QuantityReceived, PricePurchaseIncl, PricePurchaseExcl
		FROM	StockReceive_Temp A
		JOIN	ItemMaster B ON B.Id = A.ItemId
		WHERE	A.Id = @Id
		
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Tmp_Save]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Tmp_Save]
	-- PARAMETERS
			
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION
		
			DECLARE	@ItemId INT, 
					@ReceiveDate DATETIME, 
					@QuantityReceived DECIMAL(19,6), 
					@PricePurchaseExcl DECIMAL(19,2), 
					@PricePurchaseIncl DECIMAL(19,2), 
					@SupplierId INT, 
					@ReceivedByUserId NVARCHAR(50), 
					@InvoiceNum NVARCHAR(50)
			
			--Cursor to loop over tmp table 
			DECLARE StockCursor CURSOR 
			FOR
			----------------
			SELECT  ItemId, ReceiveDate, QuantityReceived, PricePurchaseExcl, PricePurchaseIncl, SupplierId, ReceivedByUserId, InvoiceNum
			FROM    StockReceive_Temp
			-----------------
			OPEN StockCursor
			FETCH NEXT FROM StockCursor INTO @ItemId, @ReceiveDate, @QuantityReceived, @PricePurchaseExcl, @PricePurchaseIncl, @SupplierId, @ReceivedByUserId, @InvoiceNum
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				DECLARE @ItemName NVARCHAR(50)
				SELECT	@ItemName = ItemName
				FROM	ItemMaster
				WHERE	Id = @ItemId
			
				DECLARE @Id INT
			
				INSERT INTO StockReceive(ItemId, ReceiveDate, QuantityReceived, PricePurchaseExcl, PricePurchaseIncl, SupplierId, ReceivedByUserId, InvoiceNum)
				VALUES (@ItemId, @ReceiveDate, @QuantityReceived, @PricePurchaseExcl, @PricePurchaseIncl, @SupplierId, @ReceivedByUserId, @InvoiceNum)
				SET @Id = SCOPE_IDENTITY()
			
				UPDATE	A
				SET		A.QuantityAvailable = (ISNULL(A.QuantityAvailable, 0) + @QuantityReceived)
				FROM	ItemMaster A
				WHERE	Id = @ItemId
			
				---------------------------------------
				-------History Log---------------------
				---------------------------------------
			
				DECLARE @To NVARCHAR(MAX) = 'Quantity Received: '+ISNULL(CAST(@QuantityReceived AS NVARCHAR(50)),'')
				DECLARE @Des NVARCHAR(MAX) = 'Stock Received for item: '+ISNULL(@ItemName,'')
			
				EXEC stpHistoryLog_Insert	@UserId = @ReceivedByUserId,	
											@Action = 'Insert',
											@Description = @Des,
											@FromValue = '',
											@ToValue = @To,
											@FieldId = @Id	
			
			
			FETCH NEXT FROM StockCursor
			INTO @ItemId, @ReceiveDate, @QuantityReceived, @PricePurchaseExcl, @PricePurchaseIncl, @SupplierId, @ReceivedByUserId, @InvoiceNum
			END
			CLOSE StockCursor
			DEALLOCATE StockCursor

			DELETE FROM StockReceive_Temp

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
/****** Object:  StoredProcedure [dbo].[stpStockReceive_Tmp_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockReceive_Tmp_Update]
	-- PARAMETERS
		@Id INT,
		@Quantity DECIMAL(19,6),
		@PriceIncl DECIMAL(19,2),
		@PriceExcl DECIMAL(19,2)
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
		BEGIN TRANSACTION	
		
		UPDATE	A
		SET		A.QuantityReceived = @Quantity,
				A.PricePurchaseIncl = @PriceIncl,
				A.PricePurchaseExcl = @PriceExcl
		FROM	StockReceive_Temp A
		WHERE	A.Id = @Id

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
/****** Object:  StoredProcedure [dbo].[stpStockTake_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpStockTake_Select]
	
	@DateFrom DATE = NULL,
	@DateTo DATE = NULL

AS
BEGIN
	
	SET NOCOUNT ON;  

	IF(@DateFrom IS NULL OR @DateTo IS NULL)
	BEGIN
		SELECT	A.Id,
				A.[Date],				
				B.FullName
		FROM	StockTake A
		JOIN	viwUsers B ON B.Id = A.UserId
	END
	ELSE
	BEGIN
		SELECT	A.Id,
				A.[Date],				
				B.FullName
		FROM	StockTake A
		JOIN	viwUsers B ON B.Id = A.UserId
		WHERE	@DateFrom <= CAST(A.[Date] AS DATE) AND @DateTo >= CAST(A.[Date] AS DATE)
		--WHERE	CAST(A.[Date] AS DATE) BETWEEN @DateFrom AND @DateTo
	END
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpStockTake_Temp_CreateHeader]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpStockTake_Temp_CreateHeader]
	
	@UserId NVARCHAR(50)

AS
BEGIN
	
	SET NOCOUNT ON;  

	IF NOT EXISTS(SELECT 1 FROM StockTake_Temp)
	BEGIN
		INSERT INTO StockTake_Temp(ItemGroupId, UserId)
		SELECT	A.Id, @UserId
		FROM	ItemGroups A
		WHERE	A.Id IN (SELECT ItemGroupId FROM ItemMaster)

		INSERT INTO StockTakeLines_Temp(ItemId, Quantity)
		SELECT Id, NULL AS Qty FROM ItemMaster
	END	
	
END
GO
/****** Object:  StoredProcedure [dbo].[stpStockTake_Temp_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpStockTake_Temp_Select]
		
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT		B.Id,
				B.GroupName,
				CASE WHEN D.Id IS NULL THEN 'Completed' ELSE 'Incomplete' END AS Status
	FROM		StockTake_Temp A
	JOIN		ItemGroups B ON B.Id = A.ItemGroupId
	JOIN		StockTakeLines_Temp C ON C.ItemId = B.Id
	LEFT JOIN	(
					SELECT	DISTINCT D.Id							
					FROM	StockTakeLines_Temp A
					JOIN	ItemMaster B ON B.Id = A.ItemId
					JOIN	ItemGroups C ON C.Id = B.ItemGroupId
					JOIN	StockTake_Temp D ON D.ItemGroupId = C.Id
					WHERE	A.Quantity IS NULL
				) D ON D.Id = A.Id


	--SELECT		B.Id,
	--			B.GroupName
	--FROM		StockTake_Temp A
	--JOIN		ItemGroups B ON B.Id = A.ItemGroupId
	--JOIN		StockTakeLines_Temp C ON C.ItemId = B.Id
	----LEFT JOIN	ItemMaster D ON D.ItemGroupId = A.ItemGroupId
	----LEFT JOIN	ItemMaster E ON E.ItemGroupId = A.ItemGroupId
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpStockTakeLines_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpStockTakeLines_Select]
	
	@HeaderId INT

AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT	A.HeaderId,
			B.GroupName,
			C.ItemName,
			A.Quantity,
			A.Variance,
			D.UoM
	FROM	StockTakeLines A
	JOIN	ItemGroups B ON B.Id = A.ItemGroupId
	JOIN	ItemMaster C ON C.Id = A.ItemId
	JOIN	UoM D ON D.Id = C.UoMId
	WHERE	A.HeaderId = @HeaderId
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpStockTakeLines_Temp_Cancel]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockTakeLines_Temp_Cancel]
	
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		TRUNCATE TABLE StockTake_Temp
		TRUNCATE TABLE StockTakeLines_Temp
			
			
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
/****** Object:  StoredProcedure [dbo].[stpStockTakeLines_Temp_Save]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockTakeLines_Temp_Save]
	
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF EXISTS (
					SELECT	1
					FROM	StockTakeLines_Temp
					WHERE	Quantity IS NULL
				  )
		BEGIN
			RAISERROR('All item groups must be completed',11,1)
		END
		ELSE
		BEGIN
			DECLARE @Id INT
			DECLARE @UserId NVARCHAR(50)
			SELECT  @UserId = UserId
			FROM	StockTake_Temp

			/*	Insert Header	*/
			INSERT INTO StockTake([Date], UserId)
			SELECT      GETDATE(), @UserId			
			SET @Id = SCOPE_IDENTITY()

			/*	Insert Lines	*/
			INSERT INTO StockTakeLines(HeaderId, ItemGroupId, ItemId, Quantity, Variance)
			SELECT  @Id AS Id, D.ItemGroupId, A.ItemId, A.Quantity, A.Variance
			FROM	StockTakeLines_Temp A
			JOIN	ItemMaster B ON B.Id = A.ItemId
			JOIN	ItemGroups C ON C.Id = B.ItemGroupId
			JOIN	StockTake_Temp D ON D.ItemGroupId = C.Id

			/*	Clear Temp tables	*/
			EXEC dbo.stpStockTakeLines_Temp_Cancel
			
			---------------------------------------
			-------History Log---------------------
			---------------------------------------			
			DECLARE @Des NVARCHAR(MAX) = 'Stock Take: Stock counted'

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = @Des,
										@FromValue = '',
										@ToValue = '',
										@FieldId = @Id		
			
		
		END
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
/****** Object:  StoredProcedure [dbo].[stpStockTakeLines_Temp_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpStockTakeLines_Temp_Select]
		@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;  

	SELECT		A.Id,
				C.GroupName,
				B.ItemName,
				A.Quantity,
				Variance,
				D.UoM
	FROM		StockTakeLines_Temp A
	JOIN		ItemMaster B ON B.Id = A.ItemId
	JOIN		ItemGroups C ON C.Id = B.ItemGroupId
	JOIN		UoM D ON D.Id = B.UoMId
	WHERE		B.ItemGroupId = @Id
	ORDER BY	B.ItemName

	

	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpStockTakeLines_Temp_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpStockTakeLines_Temp_Update]
	-- PARAMETERS
	@Id INT,
	@Quantity DECIMAL(19,6) = NULL

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @ItemId INT
		DECLARE @OnHand DECIMAL(19,6)

		SELECT	@ItemId = ItemId
		FROM	StockTakeLines_Temp
		WHERE	Id = @Id

		SELECT	@OnHand = QuantityAvailable
		FROM	ItemMaster
		WHERE	Id = @ItemId


		UPDATE	StockTakeLines_Temp
		SET		Quantity = @Quantity,
				Variance = (ISNULL(@OnHand,0.0) - @Quantity)
		WHERE	Id = @Id

		
			
			
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
/****** Object:  StoredProcedure [dbo].[stpSuppliers_Delete]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpSuppliers_Delete]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@Id INT


AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @SupplierName NVARCHAR(100)
		SELECT	@SupplierName = SupplierName
		FROM	Suppliers
		WHERE	Id = @Id

		IF EXISTS	(
						SELECT	1
						FROM	ItemMaster
						WHERE	SupplierId = @Id
					)
		BEGIN			
			RAISERROR('Cannot delete supplier because it is in use',11,1)
		END
		ELSE
		BEGIN		
			
			DELETE
			FROM	Suppliers
			WHERE	Id = @Id

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = 'Supplier: '+ISNULL(@SupplierName,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Delete',
										@Description = 'Suppliers: Supplier removed',
										@FromValue = '',
										@ToValue = @To,
										@FieldId = @Id
		END
			
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
/****** Object:  StoredProcedure [dbo].[stpSuppliers_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpSuppliers_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@CompanyName NVARCHAR(100),
	@SupplierName NVARCHAR(100),
	@BillToAddress NVARCHAR(MAX),
	@ShipToAddress NVARCHAR(MAX),
	@BillingInformation NVARCHAR(MAX),
	@ContactPerson NVARCHAR(100),
	@Telephone NVARCHAR(250),
	@CellPhone NVARCHAR(50),
	@Email NVARCHAR(250),
	@VATNumber NVARCHAR(50)


AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF EXISTS	(
						SELECT	1
						FROM	Suppliers
						WHERE	SupplierName = @SupplierName
						OR		CompanyName = @CompanyName
					)
		BEGIN
			DECLARE @msg NVARCHAR(MAX) = ISNULL(@SupplierName,'')+' / '+ISNULL(@CompanyName,'')+' already exists.'
			RAISERROR(@msg,11,1)
		END
		ELSE
		BEGIN
		
			DECLARE @Id INT	

			INSERT INTO [dbo].[Suppliers]
		   (
			[SupplierName]
		   ,[BillToAddress]
		   ,[ShipToAddress]
		   ,[BillingInformation]
		   ,[ContactPerson]
		   ,[Telephone]
		   ,[CellPhone]
		   ,[Email]
		   ,[VATNumber]
		   ,CompanyName
		   )
			VALUES
		   (
		    @SupplierName
		   ,@BillToAddress
		   ,@ShipToAddress
		   ,@BillingInformation
		   ,@ContactPerson
		   ,@Telephone
		   ,@CellPhone
		   ,@Email
		   ,@VATNumber
		   ,@CompanyName
		   )			
			SET @Id = SCOPE_IDENTITY()

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = 'Supplier: '+ISNULL(@SupplierName,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = 'Suppliers: New Supplier created',
										@FromValue = '',
										@ToValue = @To,
										@FieldId = @Id
		END
			
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
/****** Object:  StoredProcedure [dbo].[stpSuppliers_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpSuppliers_Select]
	
	@SupplierName NVARCHAR(100),
	@CompanyName NVARCHAR(100)

AS
BEGIN
	
	SET NOCOUNT ON;  

	/*
	Active: All, Active, Inactive
	*/

	SET	@SupplierName = ISNULL(@SupplierName,'')			
	SET @CompanyName = ISNULL(@CompanyName,'')

	IF(@SupplierName = '' AND @CompanyName = '')
	BEGIN	
		
		SELECT	 [Id]
				,CompanyName
				,[SupplierName]
				,REPLACE(REPLACE([BillToAddress],CHAR(10),' '), CHAR(13), '') AS [BillToAddress]
				,REPLACE(REPLACE([ShipToAddress],CHAR(10),' '), CHAR(13), '') AS [ShipToAddress]
				,REPLACE(REPLACE([BillingInformation],CHAR(10),' '), CHAR(13), '') AS [BillingInformation]
				,[ContactPerson]
				,[Telephone]
				,[CellPhone]
				,[Email]
				,[VATNumber]
		FROM	[POSSystem].[dbo].[Suppliers]

	END
	ELSE
	BEGIN
		
		SELECT	 [Id]
				,CompanyName
				,[SupplierName]
				,REPLACE(REPLACE([BillToAddress],CHAR(10),' '), CHAR(13), '') AS [BillToAddress]
				,REPLACE(REPLACE([ShipToAddress],CHAR(10),' '), CHAR(13), '') AS [ShipToAddress]
				,REPLACE(REPLACE([BillingInformation],CHAR(10),' '), CHAR(13), '') AS [BillingInformation]
				,[ContactPerson]
				,[Telephone]
				,[CellPhone]
				,[Email]
				,[VATNumber]
		FROM	[POSSystem].[dbo].[Suppliers]
		WHERE	ISNULL([SupplierName],'') LIKE '%'+@SupplierName+'%'
		AND		ISNULL(CompanyName,'') LIKE '%'+@CompanyName+'%' 

	END
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpSuppliers_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpSuppliers_Update]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	
	@Id INT,
	@BillToAddress NVARCHAR(MAX),
	@ShipToAddress NVARCHAR(MAX),
	@BillingInformation NVARCHAR(MAX),
	@ContactPerson NVARCHAR(100),
	@Telephone NVARCHAR(250),
	@CellPhone NVARCHAR(50),
	@Email NVARCHAR(250),
	@VATNumber NVARCHAR(50),
	@SupplierName NVARCHAR(100)


AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION
		
		--RAISERROR(@SupplierName,11,1)

		/*-- History Log Params --*/
		DECLARE @Old_SupplierName NVARCHAR(100),
				@Old_BillToAddress NVARCHAR(MAX),
				@Old_ShipToAddress NVARCHAR(MAX),
				@Old_BillingInformation NVARCHAR(MAX),
				@Old_ContactPerson NVARCHAR(100),
				@Old_Telephone NVARCHAR(250),
				@Old_CellPhone NVARCHAR(50),
				@Old_Email NVARCHAR(250),
				@Old_VATNumber NVARCHAR(50)

		SELECT	@Old_SupplierName = SupplierName,
				@Old_BillToAddress = BillToAddress,
				@Old_ShipToAddress = ShipToAddress,
				@Old_BillingInformation = BillingInformation,
				@Old_ContactPerson = ContactPerson,
				@Old_Telephone = Telephone,
				@Old_CellPhone = CellPhone,
				@Old_Email = Email,
				@Old_VATNumber = VATNumber
		FROM	Suppliers
		WHERE	Id = @Id
		/*	---------------------	*/

		

		UPDATE	[dbo].[Suppliers]		
		SET		 [BillToAddress] = 			@BillToAddress
				,[ShipToAddress] = 			@ShipToAddress
				,[BillingInformation] = 	@BillingInformation
				,[ContactPerson] = 			@ContactPerson
				,[Telephone] = 				@Telephone
				,[CellPhone] = 				@CellPhone
				,[Email] = 					@Email
				,[VATNumber] = 				@VATNumber
				,SupplierName =				@SupplierName
		WHERE	Id = @Id		   
		  
		---------------------------------------
		-------History Log---------------------
		---------------------------------------
		DECLARE @Description NVARCHAR(MAX) = 'Suppliers: '+ISNULL(@SupplierName,'')+' updated'
		DECLARE @To NVARCHAR(MAX) = ''
		DECLARE @From NVARCHAR(MAX) = ''

		IF(ISNULL(@BillToAddress,'') <> ISNULL(@Old_BillToAddress,''))
		BEGIN
			SET @To = 'Bill To Address: '+ISNULL(@BillToAddress,'')
			SET @From = 'Bill To Address: '+ISNULL(@Old_BillToAddress,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@ShipToAddress,'') <> ISNULL(@Old_ShipToAddress,''))
		BEGIN
			SET @To = 'Ship To Address: '+ISNULL(@ShipToAddress,'')
			SET @From = 'Ship To Address: '+ISNULL(@Old_ShipToAddress,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@BillingInformation,'') <> ISNULL(@Old_BillingInformation,''))
		BEGIN
			SET @To = 'Billing Information: '+ISNULL(@BillingInformation,'')
			SET @From = 'Billing Information: '+ISNULL(@Old_BillingInformation,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@ContactPerson,'') <> ISNULL(@Old_ContactPerson,''))
		BEGIN
			SET @To = 'Contact Person: '+ISNULL(@ContactPerson,'')
			SET @From = 'Contact Person: '+ISNULL(@Old_ContactPerson,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@Telephone,'') <> ISNULL(@Old_Telephone,''))
		BEGIN
			SET @To = 'Telephone: '+ISNULL(@Telephone,'')
			SET @From = 'Telephone: '+ISNULL(@Old_Telephone,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@CellPhone,'') <> ISNULL(@Old_CellPhone,''))
		BEGIN
			SET @To = 'Cell Phone: '+ISNULL(@CellPhone,'')
			SET @From = 'Cell Phone: '+ISNULL(@Old_CellPhone,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@Email,'') <> ISNULL(@Old_Email,''))
		BEGIN
			SET @To = 'Email: '+ISNULL(@Email,'')
			SET @From = 'Email: '+ISNULL(@Old_Email,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@VATNumber,'') <> ISNULL(@Old_VATNumber,''))
		BEGIN
			SET @To = 'VAT Number: '+ISNULL(@VATNumber,'')
			SET @From = 'VAT Number: '+ISNULL(@Old_VATNumber,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END
		IF(ISNULL(@SupplierName,'') <> ISNULL(@Old_SupplierName,''))
		BEGIN
			SET @To = 'Supplier Name: '+ISNULL(@SupplierName,'')
			SET @From = 'Supplier Name: '+ISNULL(@Old_SupplierName,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = @Description,
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		END

			
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
/****** Object:  StoredProcedure [dbo].[stpTerminals_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpTerminals_Insert]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@TerminalName NVARCHAR(50),
	@TerminalIP NVARCHAR(50),
	@PrinterId INT

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF EXISTS(SELECT 1 FROM Terminals WHERE TerminalName = @TerminalName)
			BEGIN
				RAISERROR('Terminal already exists',11,1)
			END
			ELSE IF EXISTS(SELECT 1 FROM Terminals WHERE Terminal_IP = @TerminalIP)
			BEGIN
				RAISERROR('Terminal IP already in use',11,1)
			END
			ELSE
			BEGIN		

				DECLARE @Id INT

				INSERT INTO Terminals (TerminalName, Terminal_IP, PrinterId)
				VALUES(@TerminalName, @TerminalIP, @PrinterId)
								
				SET @Id = SCOPE_IDENTITY()

				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @To NVARCHAR(MAX) = 'Name: '+ISNULL(@TerminalName,'')

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Insert',
											@Description = 'Terminals: New Terminal created',
											@FromValue = '',
											@ToValue = @To,
											@FieldId = @Id
			END
			
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
/****** Object:  StoredProcedure [dbo].[stpTerminals_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpTerminals_Select]	
	

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT	A.Id,
			A.TerminalName,
			A.Terminal_IP,
			A.PrinterId,
			B.PrinterName
	FROM	Terminals A
	JOIN	Printers B ON B.Id = A.PrinterId
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpTerminals_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpTerminals_Update]
	-- PARAMETERS
	
	@Id INT,	
	@UserId NVARCHAR(50),
	@TerminalName NVARCHAR(50),
	@TerminalIP NVARCHAR(50),
	@PrinterId INT	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			

			DECLARE @Old_TerminalName NVARCHAR(50)					

			SELECT	@Old_TerminalName = TerminalName
			FROM	Terminals A			
			WHERE	A.Id = @Id

			UPDATE	Terminals
			SET		TerminalName = @TerminalName,
					Terminal_IP = @TerminalIP,
					PrinterId = @PrinterId
			WHERE	Id = @Id


			IF(ISNULL(@TerminalName,'') <> ISNULL(@Old_TerminalName,''))
			BEGIN			
				---------------------------------------
				-------History Log---------------------
				---------------------------------------
				DECLARE @From NVARCHAR(MAX) = 'Terminal Name: '+ISNULL(@Old_TerminalName,'')
				DECLARE @To NVARCHAR(MAX) = 'Terminal Name: '+ISNULL(@TerminalName,'')

				EXEC stpHistoryLog_Insert	@UserId = @UserId,	
											@Action = 'Update',
											@Description = 'Terminals: Terminal Name changed',
											@FromValue = @From,
											@ToValue = @To,
											@FieldId = @Id
				
			END

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
/****** Object:  StoredProcedure [dbo].[stpUoM_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpUoM_Insert]
	-- PARAMETERS	
	@UserId NVARCHAR(50),
	@UoM NVARCHAR(50),
	@Description NVARCHAR(250)	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		IF EXISTS	(
						SELECT	1
						FROM	UoM
						WHERE	UoM = @UoM
					)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX) = ISNULL(@UoM,'') + ' already exists.'
			RAISERROR(@Msg,11,1)
		END
		ELSE
		BEGIN

			DECLARE @Id INT

			INSERT INTO UoM(UoM, [Description])
			VALUES(@UoM, @Description)
			SET @Id = SCOPE_IDENTITY()

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = 'UoM: '+ISNULL(@UoM,'')+', Description: '+ISNULL(@Description,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = 'UoM: UoM created',
										@FromValue = '',
										@ToValue = @To,
										@FieldId = @Id
		END
			
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
/****** Object:  StoredProcedure [dbo].[stpUOM_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpUOM_Select]

AS
BEGIN	
	SET NOCOUNT ON;  

	SELECT	Id, 
			UoM, 
			[Description]
	FROM	UoM
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpUoM_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpUoM_Update]
	-- PARAMETERS	
	@Id INT,
	@Description NVARCHAR(250),
	@UserId NVARCHAR(50)	
AS
BEGIN
	SET NOCOUNT ON;    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			DECLARE @Description_Old NVARCHAR(250)

			SELECT	@Description_Old = [Description]
			FROM	UoM
			WHERE	Id = @Id

			UPDATE	A
			SET		A.[Description] = @Description
			FROM	UoM A
			WHERE	A.Id = @Id

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @From NVARCHAR(MAX) = 'Description: '+ISNULL(@Description_Old,'')
			DECLARE @To NVARCHAR(MAX) = 'Description: '+ISNULL(@Description,'')

			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Update',
										@Description = 'UoM: UoM updated',
										@FromValue = @From,
										@ToValue = @To,
										@FieldId = @Id
		
			
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
/****** Object:  StoredProcedure [dbo].[stpUsers_ActiveInactive]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpUsers_ActiveInactive]
	-- PARAMETERS
	
	@UserId UNIQUEIDENTIFIER,	
	@Active BIT,
	@LoggedInUserId NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
				DECLARE @ActiveOld BIT,
						@CurrentLoggedInUser NVARCHAR(100),
						@SelectedUser NVARCHAR(50)

				SELECT	@ActiveOld = Active,
						@SelectedUser = LoginName
				FROM	Users
				WHERE	Id = @UserId

				SELECT	@CurrentLoggedInUser = LoginName
				FROM	Users
				WHERE	Id = @LoggedInUserId

				UPDATE		A
				SET			Active = @Active
				FROM		Users A
				WHERE		Id = @UserId

				-------------------------
				--History Log-------
				-------------------------
				DECLARE @Desc NVARCHAR(MAX) = 'User Management: User '+@SelectedUser+' Active/Inactive updated',
						@From NVARCHAR(MAX) = 'Active: '+ CASE WHEN @ActiveOld = 1 THEN 'Active' ELSE 'Inactive' END,
						@To NVARCHAR(MAX) = 'Active: '+ CASE WHEN @Active = 1 THEN 'Active' ELSE 'Inactive' END

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
											@Description = @Desc,
											@FromValue = @From,
											@ToValue = @To
		
			
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
/****** Object:  StoredProcedure [dbo].[stpUsers_Insert]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpUsers_Insert]
	-- PARAMETERS
	@LoginName NVARCHAR(100),
	@Password NVARCHAR(100),
	@Name NVARCHAR(100),
	@Surname NVARCHAR(100),
	@Phone NVARCHAR(50),
	@Email NVARCHAR(250),
	@UserId NVARCHAR(50),
	@Pin NCHAR(4)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION
			
			IF((SELECT ISNUMERIC(@Pin)) = 0)
			BEGIN
				RAISERROR('Pin has to be numeric',11,1)
			END
			IF EXISTS(SELECT 1 FROM Users WHERE Pin = @Pin)
			BEGIN
				RAISERROR('Pin already in use',11,1)
			END


			IF(@Phone = '')
			BEGIN
				SET @Phone = NULL				
			END
			IF(@Email = '')
			BEGIN
				SET @Email = NULL
			END

			------------------------------------------------
			IF(ISNULL(@LoginName,'') = '')
			BEGIN
				RAISERROR('Login Name cannot be empty.',11,1)
			END
			ELSE IF(ISNULL(@Password,'') = '')
			BEGIN
				RAISERROR('Password cannot be empty.',11,1)
			END
			ELSE IF(ISNULL(@Name,'') = '')
			BEGIN
				RAISERROR('Name cannot be empty.',11,1)
			END
			ELSE IF(ISNULL(@Surname,'') = '')
			BEGIN
				RAISERROR('Surname cannot be empty.',11,1)
			END
			ELSE IF EXISTS (
								SELECT	1
								FROM	Users
								WHERE	LoginName = @LoginName
							)
			BEGIN
				DECLARE @Msg NVARCHAR(MAX) = '"'+@LoginName+'" already exists.'
				RAISERROR(@Msg,11,1)
			END
			ELSE
			BEGIN
				INSERT INTO Users (Id, LoginName, [Password], [Name], Surname, Phone, Email, Active, Pin)
				VALUES (NEWID(), @LoginName, dbo.fnPasswordHash(@Password), @Name, @Surname, @Phone, @Email, 1, @Pin)
			END
			
			DECLARE @To NVARCHAR(MAX) = 'Login Name: '+ISNULL(@LoginName,'')

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			EXEC stpHistoryLog_Insert	@UserId = @UserId,	
										@Action = 'Insert',
										@Description = 'User Management: New User created',
										@FromValue = '',
										@ToValue = @To


			
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
/****** Object:  StoredProcedure [dbo].[stpUsers_Login]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpUsers_Login]
	-- Add the parameters for the stored procedure here
	@LoginName NVARCHAR(100),
	@Password NVARCHAR(MAX)

AS
BEGIN
	
	SET NOCOUNT ON;  

	IF EXISTS	(
					SELECT	1
					FROM	Users
					WHERE	LoginName = @LoginName
					--AND		[Password] = dbo.fnPasswordHash(@Password)
					AND		Active = 0
				)
	BEGIN
		RAISERROR('User is inactive.',11,1)
	END
	ELSE IF EXISTS	(
						SELECT	1
						FROM	Users
						WHERE	LoginName = @LoginName
						AND		[Password] = dbo.fnPasswordHash(@Password)
					)
	BEGIN
		SELECT	1 AS Result,
				Id
		FROM	Users
		WHERE	LoginName = @LoginName
		AND		[Password] = dbo.fnPasswordHash(@Password)
	END	
	ELSE
	BEGIN
		SELECT 0 AS Result, NULL AS Id
	END
	
	


END
GO
/****** Object:  StoredProcedure [dbo].[stpUsers_Login_Pin]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpUsers_Login_Pin]
	-- Add the parameters for the stored procedure here
	@Pin NVARCHAR(10)	--10 Chars to determin invalid pins
AS
BEGIN
	
	SET NOCOUNT ON;  

	IF EXISTS	(
					SELECT	1
					FROM	Users
					WHERE	Pin = @Pin					
					AND		Active = 0
				)
	BEGIN
		RAISERROR('User is inactive.',11,1)
	END
	ELSE IF EXISTS	(
						SELECT	1
						FROM	Users
						WHERE	Pin = @Pin						
					)
	BEGIN
		SELECT	1 AS Result,
				Id
		FROM	Users
		WHERE	Pin = @Pin	

		--History Log
		-------------
		DECLARE @UserId NVARCHAR(50)
		SELECT	@UserId = Id
		FROM	Users
		WHERE	Pin = @Pin
		
		EXEC stpHistoryLog_Insert	@UserId = @UserId,
									@Action = 'POS Login',
									@Description = 'Successfully loggend in',
									@FromValue = NULL,
									@ToValue = NULL								

	END	
	ELSE
	BEGIN
		SELECT 0 AS Result, NULL AS Id
	END
	
	


END
GO
/****** Object:  StoredProcedure [dbo].[stpUsers_ResetPassword]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpUsers_ResetPassword]
	-- PARAMETERS
	
	@UserId NVARCHAR(50),
	@LoggendInUserId NVARCHAR(50),
	@Password NVARCHAR(100),
	@PasswordConfirm NVARCHAR(100)
	

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
		
		DECLARE @UserName NVARCHAR(100)

		SELECT	@UserName = LoginName
		FROM	Users
		WHERE	Id = @UserId

		IF(@Password <> @PasswordConfirm COLLATE Latin1_General_CS_AS)
		BEGIN
			RAISERROR('Passwords do not match',11,1)
		END
		ELSE
		BEGIN
			
			UPDATE		A
			SET			[Password] = dbo.fnPasswordHash(@Password)
			FROM		Users A
			WHERE		Id = @UserId

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			
			DECLARE @Des NVARCHAR(MAX) = 'User '+ISNULL(@UserName,'')+ ' password was reset.'

			EXEC stpHistoryLog_Insert	@UserId = @LoggendInUserId,	
										@Action = 'Update',
										@Description = @Des,
										@FromValue = '',
										@ToValue = '',
										@FieldId = @UserId
		
		END	

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
/****** Object:  StoredProcedure [dbo].[stpUsers_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpUsers_Select]
	
	@LoginName NVARCHAR(100),
	@Name NVARCHAR(100),
	@Surname NVARCHAR(100)

AS
BEGIN
	
	SET NOCOUNT ON;  

	SET @LoginName = ISNULL(@LoginName,'')
	SET	@Name = ISNULL(@Name,'')
	SET @Surname = ISNULL(@Surname,'')

	IF(@LoginName = '' AND @Name = '' AND @Surname = '')
	BEGIN
		
		SELECT		Id, 
					LoginName, 					
					[Name], 
					Surname, 
					Phone, 
					Email,
					CASE WHEN Active = 1 THEN 'Active' ELSE 'Inactive' END AS Active,
					Pin
		FROM        Users
		ORDER BY	LoginName
	END
	ELSE
	BEGIN
		
		SELECT		Id, 
					LoginName, 					
					[Name], 
					Surname, 
					Phone, 
					Email,
					CASE WHEN Active = 1 THEN 'Active' ELSE 'Inactive' END AS Active,
					Pin
		FROM        Users 
		WHERE		ISNULL(LoginName,'') LIKE '%'+@LoginName+'%'
		AND			ISNULL([Name],'') LIKE '%'+@Name+'%'
		AND			ISNULL([Surname],'') LIKE '%'+@Surname+'%'
		ORDER BY	LoginName
	END
		
END
GO
/****** Object:  StoredProcedure [dbo].[stpUsers_Update]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[stpUsers_Update]
	-- PARAMETERS
	
	@UserId UNIQUEIDENTIFIER,	
	@Name NVARCHAR(100),
	@Surname NVARCHAR(100),
	@Phone NVARCHAR(50),
	@Email NVARCHAR(250),
	@LoggedInUserId NVARCHAR(50),
	@Pin NCHAR(4)

AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRY
		BEGIN TRANSACTION						
			
			IF((SELECT ISNUMERIC(@Pin)) = 0)
			BEGIN
				RAISERROR('Pin has to be numeric',11,1)
			END
			IF EXISTS(SELECT 1 FROM Users WHERE Pin = @Pin)
			BEGIN
				RAISERROR('Pin already in use',11,1)
			END

			---History Log Params
			DECLARE @NameOld NVARCHAR(100),
					@SurnameOld NVARCHAR(100),
					@PhoneOld NVARCHAR(50),
					@EmailOld NVARCHAR(250),
					@LoginName NVARCHAR(100)
			
			SELECT	@NameOld = [Name],
					@SurnameOld = Surname,
					@PhoneOld = Phone,
					@EmailOld = Email,
					@LoginName = LoginName
			FROM	Users
			WHERE	Id = @UserId
			----------------------------

			IF(@Phone = '')
			BEGIN
				SET @Phone = NULL				
			END
			IF(@Email = '')
			BEGIN
				SET @Email = NULL
			END
			---------------------------------
			IF(ISNULL(@Name,'') = '')
			BEGIN
				RAISERROR('Name cannot be empty.',11,1)
			END
			ELSE IF(ISNULL(@Surname,'') = '')
			BEGIN
				RAISERROR('Surname cannot be empty.',11,1)
			END
			ELSE
			BEGIN
				UPDATE		A
				SET			[Name] = @Name,
							[Surname] = @Surname,
							Phone = @Phone,
							Email = @Email,
							Pin	= @Pin
				FROM		Users A
				WHERE		Id = @UserId
			END
			
			

			---------------------------------------
			-------History Log---------------------
			---------------------------------------
			DECLARE @To NVARCHAR(MAX) = '',
					@From NVARCHAR(MAX) = '',
					@Desc NVARCHAR(MAX) = ''

			IF(ISNULL(@Name,'') <> ISNULL(@NameOld,''))
			BEGIN
				SET @From = 'Name: '+@NameOld
				SET @To = 'Name: '+@Name
				SET @Desc = 'User Management: User '+@LoginName+' Updated'

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
											@Description = @Desc,
											@FromValue = @From,
											@ToValue = @To
			END					
			IF(ISNULL(@Surname,'') <> ISNULL(@SurnameOld,''))
			BEGIN
				SET @From = 'Surname: '+@SurnameOld
				SET @To = 'Surname: '+@Surname
				SET @Desc = 'User Management: User '+@LoginName+' Updated'

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
											@Description = @Desc,
											@FromValue = @From,
											@ToValue = @To
			END	
			IF(ISNULL(@Phone,'') <> ISNULL(@PhoneOld,''))
			BEGIN
				SET @From = 'Phone: '+@PhoneOld
				SET @To = 'Phone: '+@Phone
				SET @Desc = 'User Management: User '+@LoginName+' Updated'

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
											@Description = @Desc,
											@FromValue = @From,
											@ToValue = @To
			END	
			IF(ISNULL(@Email,'') <> ISNULL(@EmailOld,''))
			BEGIN
				SET @From = 'Email: '+@EmailOld
				SET @To = 'Email: '+@Email
				SET @Desc = 'User Management: User '+@LoginName+' Updated'

				EXEC stpHistoryLog_Insert	@UserId = @LoggedInUserId,	
											@Action = 'Update',
											@Description = @Desc,
											@FromValue = @From,
											@ToValue = @To
			END	

			
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
/****** Object:  StoredProcedure [dbo].[stpUsers_Values_Select]    Script Date: 2023/11/25 16:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stpUsers_Values_Select]
	
	@Id UNIQUEIDENTIFIER

AS
BEGIN	
	SET NOCOUNT ON;  
			
	SELECT		LoginName, 					
				[Name], 
				Surname, 
				Phone, 
				Email,
				Active,
				Pin
	FROM        Users 
	WHERE		Id = @Id
	
		
END
GO
USE [master]
GO
ALTER DATABASE [POSSystem] SET  READ_WRITE 
GO
