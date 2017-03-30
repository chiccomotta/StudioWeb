USE [ASBusinessIntelligence.Guna]
GO

/****** Object:  StoredProcedure [PR].[GetAverageCallsData]    Script Date: 30/03/2017 11:07:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [PR].[GetAverageCallsData]
	@UserId				uniqueidentifier,
	@StartDate			datetime,			
	@EndDate			datetime,			
	@CallArgument		nvarchar(60)		= null,
	@Protocol			nvarchar(60)		= null,
	@Competence			nvarchar(60)		= null,
	@RelativePotential	nvarchar(60)		= null,
	@PersonalFidelity	nvarchar(60)		= null,
	@Specialization		nvarchar(60)		= null	

AS
BEGIN

	WITH CTECallsTable 
		(Name, Promotion, CallArgumentId, CallDate, CallId, SubscriberId, SubscriberName)
	AS
	(
		-- Estraggo i dati
		SELECT 
			C.Name				,		
			L.Promotion			,
			L.CallArgumentId	,
			L.CallDate			,
			L.CallId			,
			isnull(V.UserId, L.SubscriberId) as SubscriberId,
			isnull(V.UserName, L.SubscriberName) as SubscriberName
		FROM 
			PR.Contacts AS C
			INNER JOIN PR.Calls AS L
			LEFT OUTER JOIN PR.ContactsVisibility V on L.SubscriberId = V.UserId
		ON 
			C.ContactId = L.RecipientId		
		WHERE
			L.EntityType = 'Contact'
			AND 
				CONVERT(Date, L.CallDate) BETWEEN @StartDate AND @EndDate	
			AND
				(@Competence IS NULL OR C.Competence = @Competence)
			AND
				(@RelativePotential IS NULL OR C.RelativePotential = @RelativePotential)
			AND 
				(@PersonalFidelity IS NULL OR C.PersonalFidelity = @PersonalFidelity)					
			AND
				(dbo.NullIfEmptyGuid(@UserId) IS NULL OR (C.ContactId IN  (SELECT ContactId FROM PR.ContactsVisibility WHERE UserId = @UserId AND Reason = 1)))							
			AND 
				(@CallArgument IS NULL OR L.ArgumentTitle = @CallArgument)
			AND 
				(@Protocol IS NULL OR L.ProtocolTitle = @Protocol)					
			AND 
				(@Specialization IS NULL OR L.SpecializationName = @Specialization)					
	)	
	-- END CTE Definition	

		SELECT 'CALLS_ON_CONTACTS' AS Typology, SubscriberName, COUNT(DISTINCT CallId) AS Quantity 
			FROM CTECallsTable 
			GROUP BY SubscriberName
		
		UNION ALL
		
		SELECT 'CALLS_WITH_PROMOTIONS' AS Typology, SubscriberName, COUNT(DISTINCT CallId) AS Quantity 
			FROM CTECallsTable 
			WHERE CTECallsTable.Promotion = 1
			GROUP BY SubscriberName

		UNION ALL
		
		SELECT 'CALLS_WITH_INTERVIEWS' AS Typology, SubscriberName, COUNT(DISTINCT CallId) AS Quantity 
			FROM CTECallsTable 
			WHERE dbo.NullIfEmptyGuid(CTECallsTable.CallArgumentId) IS NOT NULL
			GROUP BY SubscriberName

		UNION ALL
		
		SELECT 'WORKING_DAYS' AS Typology, SubscriberName, COUNT(DISTINCT T.CallDate) AS Quantity 
			FROM CTECallsTable AS T
			INNER JOIN PR.Calendar AS C 
			ON  CAST(T.CallDate AS DATE) = CAST(C.Date AS DATE)
			WHERE
				C.Type = 'Work'
			GROUP BY SubscriberName
		
		UNION ALL

		--SELECT A.* 
	 --   FROM
		--	CTECallsTable AS T
		--INNER JOIN PR.PayrollActivities AS A 
		--	ON 
		--		T.SubscriberId = A.UserId 
		--		AND CAST(T.CallDate AS DATE) = CAST(A.Date AS DATE)		

		SELECT 'INFORMATION_DAYS' AS Typology, SubscriberName, SUM(A.MorningScientificCall + A.AfternoonScientificCall) AS Quantity
	    FROM
			CTECallsTable AS T
		INNER JOIN PR.PayrollActivities AS A 
			ON 
				T.SubscriberId = A.UserId 
				AND CAST(T.CallDate AS DATE) = CAST(A.Date AS DATE)		
		GROUP BY SubscriberName
		ORDER BY SubscriberName
END