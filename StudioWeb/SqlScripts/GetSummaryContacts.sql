USE [ASBusinessIntelligence.Dev]
GO

/****** Object:  StoredProcedure [PR].[GetSummaryContacts]    Script Date: 16/03/2017 11:25:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  procedure [PR].[GetSummaryContacts]
	 @UserId		Uniqueidentifier,
	 @LineId		UniqueIdentifier,
	 @Startdate		datetime,
	 @EndDate		datetime

AS
	-- controllo esistenza tabella temporanea (se esiste la elimino)
	IF OBJECT_ID(N'tempdb..#master_t', N'U') IS NOT NULL
	BEGIN
		DROP TABLE #master_t
	END

-- Totale righe
DECLARE @TotalContacts INT 
SET @TotalContacts = (select count(*) from PR.Contacts)

-- Creo la tabella temporanea
SELECT TOP 0 * INTO #master_t FROM PR.Contacts

-- UserId Not empty ?
IF @UserId = CAST(CAST(0 as BINARY) AS UNIQUEIDENTIFIER)
	BEGIN

		INSERT INTO #master_t 
			SELECT *
			FROM PR.Contacts 
			WHERE 
				RelativePotential <> 'Unknown' 
				AND Competence <> 'Unknown' 
				AND PersonalFidelity <> 'Unknown'
				AND ((LastCallDate  BETWEEN @StartDate AND @EndDate) OR LastCallDate IS NULL)
				AND LineId = @LineId
	END

ELSE
	BEGIN
		
		INSERT INTO #master_t 
			SELECT *
			FROM PR.Contacts 
			WHERE 
				RelativePotential <> 'Unknown' 
				AND Competence <> 'Unknown' 
				AND PersonalFidelity <> 'Unknown'
				AND ((LastCallDate  BETWEEN @StartDate AND @EndDate) OR LastCallDate IS NULL)
				AND LineId = @LineId
				AND ContactId IN  (SELECT ContactId FROM PR.ContactsVisibility WHERE UserId = @UserId AND Reason = 1)
	END


-- pulitura dati
UPDATE #master_t SET RelativePotential = 'Low' where RelativePotential = 'MediumLow'
UPDATE #master_t SET RelativePotential = 'High' where RelativePotential = 'MediumHigh'
UPDATE #master_t SET Competence = 'Low' where Competence = 'MediumLow'
UPDATE #master_t SET Competence = 'High' where Competence = 'MediumHigh'
UPDATE #master_t SET PersonalFidelity = 'Low' where PersonalFidelity = 'MediumLow'
UPDATE #master_t SET PersonalFidelity = 'High' where PersonalFidelity = 'MediumHigh'

select Competence, RelativePotential, PersonalFidelity, count(*) as Quantity, count(LastCallDate) as Visited, @TotalContacts as TotalContacts
from #master_t
group by Competence, RelativePotential, PersonalFidelity

GO


