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
