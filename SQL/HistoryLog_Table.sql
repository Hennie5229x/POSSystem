USE [POSSystem]
GO
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
