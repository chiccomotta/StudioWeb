ALTER PROCEDURE PR.GetSummaryReportData
	@UserId				uniqueidentifier,
	@StartDate			datetime,			
	@EndDate			datetime,			
	@CallArgument		nvarchar(60)		= null,
	@Protocol			nvarchar(60)		= null,
	@Competence			nvarchar(60)		= null,
	@RelativePotential	nvarchar(60)		= null,
	@PersonalFidelity	nvarchar(60)		= null,
	@Specialization		nvarchar(60)		= null,
	@queryType			nvarchar(20)		= null

AS
BEGIN
	
	IF OBJECT_ID(N'tempdb.dbo.#temp_calls_table', N'U') IS NOT NULL
	BEGIN
		DROP TABLE #temp_calls_table
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
		#temp_calls_table
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


	IF @queryType = 'Group' 
	-- Raggruppo
		SELECT 'ARGUMENT' AS Typology, ArgumentTitle AS Description, COUNT(DISTINCT CallId) AS Quantity FROM #temp_calls_table GROUP BY ArgumentTitle
		UNION ALL
		SELECT 'PROTOCOL' AS Typology, ProtocolTitle AS Description, COUNT(DISTINCT CallId) AS Quantity FROM #temp_calls_table GROUP BY ProtocolTitle
		UNION ALL
		SELECT 'RELATIVE_POTENTIAL' AS Typology, RelativePotential AS Description, COUNT(DISTINCT CallId) AS Quantity FROM #temp_calls_table GROUP BY RelativePotential
		UNION ALL
		SELECT 'COMPETENCE' AS Typology, Competence AS Description, COUNT(DISTINCT CallId) AS Quantity FROM #temp_calls_table GROUP BY Competence
		UNION ALL
		SELECT 'PERSONAL_FIDELITY' AS Typology, PersonalFidelity AS Description, COUNT(DISTINCT CallId) AS Quantity FROM #temp_calls_table GROUP BY PersonalFidelity
		UNION ALL
		SELECT 'SPECIALIZATIONS' AS Typology, SpecializationName AS Description, COUNT(DISTINCT CallId) AS Quantity FROM #temp_calls_table GROUP BY SpecializationName
		
	ELSE IF @queryType = 'List' 
		select * from #temp_calls_table	
END


EXEC PR.GetSummaryReportData null, '2015-01-01', '2017-12-31', null, null, null, null, null, 'DIABETOLOGO', 'List'
