
SELECT * FROM PR.Contacts 
SELECT * FROM PR.CALLS
SELECT * FROM PR.Calendar
SELECT * FROM [PR].[PayrollActivities] 




ALTER PROCEDURE PR.GetAverageCallsData
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
	
	IF OBJECT_ID(N'tempdb.dbo.#temp_filtered_calls', N'U') IS NOT NULL
	BEGIN
		DROP TABLE #temp_filtered_calls
	END

	-- Estraggo i dati
	SELECT 
		C.ContactId				,		 
		C.Name					,		
		C.StateProvinceRegion	,
		C.City 					,
		C.PostalCode 			,
		C.Address  				,
		C.LastCallDate 			,
		C.Competence  			,
		C.RelativePotential 	,
		C.PersonalFidelity  	,
		C.ContactTypeName		,
		L.*						
	INTO 
		#temp_filtered_calls
	FROM 
		PR.Contacts AS C
		INNER JOIN PR.Calls AS L 
	ON 
		C.ContactId = L.RecipientId		
	WHERE
		L.EntityType = 'Contact'
		AND 
			L.CallDate BETWEEN @StartDate AND @EndDate 
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
	
	--select * from #temp_filtered_calls
	
		SELECT 'CALLS_ON_CONTACTS' AS Typology, SubscriberName, COUNT(DISTINCT CallId) AS Quantity 
			FROM #temp_filtered_calls 
			GROUP BY SubscriberName
		
		UNION ALL
		
		SELECT 'CALLS_WITH_PROMOTIONS' AS Typology, SubscriberName, COUNT(DISTINCT CallId) AS Quantity 
			FROM #temp_filtered_calls 
			WHERE #temp_filtered_calls.Promotion = 1
			GROUP BY SubscriberName

		UNION ALL
		
		SELECT 'CALLS_WITH_INTERVIEWS' AS Typology, SubscriberName, COUNT(DISTINCT CallId) AS Quantity 
			FROM #temp_filtered_calls 
			WHERE dbo.NullIfEmptyGuid(#temp_filtered_calls.CallArgumentId) IS NOT NULL
			GROUP BY SubscriberName

		UNION ALL
		
		SELECT 'WORKING_DAYS' AS Typology, SubscriberName, COUNT(DISTINCT T.CallDate) AS Quantity 
			FROM #temp_filtered_calls AS T
			INNER JOIN PR.Calendar AS C 
			ON  CAST(T.CallDate AS DATE) = CAST(C.Date AS DATE)
			WHERE
				C.Type = 'Work'
			GROUP BY SubscriberName
		
		UNION ALL

		SELECT 'INFORMATION_DAYS' AS Typology, SubscriberName, SUM(A.MorningScientificCall + A.AfternoonScientificCall) AS Quantity
	    FROM
			(select SubscriberId, SubscriberName, CallDate from  #temp_filtered_calls group by SubscriberId, SubscriberName, CallDate) AS SUBQ	
		INNER JOIN PR.PayrollActivities AS A 
			ON 
				SUBQ.SubscriberId = A.UserId 
				AND CAST(SUBQ.CallDate AS DATE) = CAST(A.Date AS DATE)		
		GROUP BY SubscriberName

		ORDER BY SubscriberName 
END


EXEC PR.GetAverageCallsData null, '2014-01-01', '2017-12-31', null, null, null, null, null, null



-- DEBUG
select C.*, A.* from PR.Calls AS C
INNER JOIN PR.PayrollActivities AS A 
	ON C.SubscriberId = A.UserId
	AND CAST(C.CallDate AS DATE) = CAST(A.Date AS DATE)					

where C.SubscriberName = 'OLGIATI ANDREA'
	AND
	C.CallDate between  '2014-01-01' and '2017-12-31'
	AND C.EntityType = 'Contact'


select * from PR.PayrollActivities 
	where UserId = '43A04BE7-A9B7-4251-9DC2-29A778F030D2'	-- OLGIATI ANDREA
	and Date = '20161216'
	

select userId, date, count(*) as tot from PR.PayrollActivities 
	group by UserId, date
	Having count(*) > 1


	select UserId,  Date, count(*) as tot
	from PR.PayrollActivities 
	where UserId = '43A04BE7-A9B7-4251-9DC2-29A778F030D2'
	group by UserId, Date