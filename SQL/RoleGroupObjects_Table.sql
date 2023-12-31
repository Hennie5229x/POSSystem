USE [POSSystem]
GO
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
