USE [POSSystem]
GO
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
