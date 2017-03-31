
ALTER PROCEDURE [PR].[GetAverageCallsData]
	@UserId				uniqueidentifier		  ,
	@LineId				uniqueidentifier		  ,
	@IdentityId			uniqueidentifier		  ,	
	@StartDate			datetime				  ,			
	@EndDate			datetime				  ,			
	@CallArgument		nvarchar(60)		= null,
	@Protocol			nvarchar(60)		= null,
	@Competence			nvarchar(60)		= null,
	@RelativePotential	nvarchar(60)		= null,
	@PersonalFidelity	nvarchar(60)		= null,
	@Specialization		nvarchar(60)		= null	

AS
BEGIN

	-- Leggo gli utenti su cui ha visibilità l'utente loggato al sistema
	-- Se @UserId è guid.empty allora è un CAPO AREA per cui passo @IdentityId
	DECLARE @EffectiveUserId uniqueidentifier

	IF (dbo.NullIfEmptyGuid(@UserId) IS NULL)
		SET @EffectiveUserId = @IdentityId
	ELSE
		SET @EffectiveUserId = @UserId

	CREATE TABLE #VisibleUsers (UserId uniqueidentifier, UserName nvarchar(100), AreaManagerId uniqueidentifier, IsAm bit)	
	INSERT INTO #VisibleUsers EXEC [PR].[GetUsersOfCurrentHierarchy] @LineId, @EffectiveUserId

	;WITH CTECallsTable 
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
			INNER JOIN PR.Calls AS L ON C.ContactId = L.RecipientId	
			LEFT OUTER JOIN PR.ContactsVisibility V ON L.SubscriberId = V.UserId 
			INNER JOIN #VisibleUsers AS VU ON  VU.UserId = V.UserId
		WHERE
			L.EntityType = 'Contact'
			AND 
				CONVERT(Date, L.CallDate) BETWEEN @StartDate AND @EndDate	
			AND
				(@LineId IS NULL OR C.LineId = @LineId)
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

GO

EXEC [PR].[GetAverageCallsData] '00000000-0000-0000-0000-000000000000' ,'3A696314-1D76-48A5-B3C5-D86F9E2D5B1F', '3B80F857-E942-459A-ABE7-28015213896A',
	 '20160101', '20170131', null, null, null, null, null, null

-- 'E70F9B78-A0D0-430B-8D26-C4EBC19289B3'		Dott.ssa Besana
-- '3B80F857-E942-459A-ABE7-28015213896A'		Anzovino Capo Area

EXEC [PR].[GetUsersOfCurrentHierarchy] '3A696314-1D76-48A5-B3C5-D86F9E2D5B1F', '3B80F857-E942-459A-ABE7-28015213896A'


SELECT UserId, COUNT(ContactId) FROM PR.ContactsVisibility GROUP BY UserId ORDER BY 2 DESC

SELECT TOP 10 * FROM PR.Contacts 
SELECT TOP 10 * FROM PR.Calls	