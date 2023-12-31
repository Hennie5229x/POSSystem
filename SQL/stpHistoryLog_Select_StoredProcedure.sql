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
