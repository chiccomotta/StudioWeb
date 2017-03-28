
select top 10 * from PR.Customers
select top 10 * from PR.Orders


ALTER PROCEDURE PR.GetCustomersReportDetailsData
	@UserId				uniqueidentifier			,
	@LineId				uniqueidentifier			,
	@StartDate			datetime			= null	,			
	@EndDate			datetime			= null	,			
	@CategoryName		nvarchar(60)		= null	,
	@AbsolutePotential	nvarchar(60)		= null	,
	@RelativePotential	nvarchar(60)		= null	,
	@ProductCategory	nvarchar(100)		= null	,
	@ProductGroup		nvarchar(100)		= null	,
	@ProductLine		nvarchar(100)		= null	


AS
BEGIN
	
	IF OBJECT_ID(N'tempdb.dbo.#temp_revenue_customers', N'U') IS NOT NULL
	BEGIN
		DROP TABLE #temp_revenue_customers
	END

	-- Estraggo i dati
	SELECT 		
		C.CustomerCode,
		C.BusinessName,
		C.AbsolutePotential,
		C.RelativePotential,
		O.*						
	INTO 
		#temp_revenue_customers
	FROM 
		PR.Customers AS C 
		INNER JOIN PR.Orders AS O 
		ON C.CustomerId = O.CustomerId
	WHERE						
			(dbo.NullIfEmptyGuid(@UserId) IS NULL OR O.BeneficiaryId = @UserId)	
		AND
			(dbo.NullIfEmptyGuid(@LineId) IS NULL OR O.LineId = @LineId)
		AND 
			(@CategoryName IS NULL OR C.CustomerCategoryName = @CategoryName)
		AND 
			(@AbsolutePotential IS NULL OR C.AbsolutePotential = @AbsolutePotential)
		AND 
			(@RelativePotential IS NULL OR C.RelativePotential = @RelativePotential)		
		AND 
			(@ProductCategory IS NULL OR O.ProductCategory = @ProductCategory)
		AND 
			(@ProductGroup IS NULL OR O.ProductGroup = @ProductGroup)
		AND 
			(@ProductLine IS NULL OR O.ProductLine = @ProductLine)		

	DECLARE @TotalRevenueCustomers AS MONEY
	SET @TotalRevenueCustomers = (SELECT SUM(NetAmount) AS TotalRevenue FROM #temp_revenue_customers 
								  WHERE  CONVERT(date, CreationDate) BETWEEN @StartDate and @EndDate)
	
		SELECT TOP 30 C.BusinessName, C.CustomerCode, C.CustomerErpCode, 
			FatturatoAC = CASE WHEN F1.Typology = 'FATTURATO_AC' THEN F1.Revenue END,
			FatturatoAP = CASE WHEN F2.Typology = 'FATTURATO_AP' THEN F2.Revenue END, 
			F1.TotalRevenue, DeltaRevenue = ROUND((F1.Revenue - F2.Revenue) / (F1.Revenue) * 100, 2), 
			DeltaWeightRevenue = ROUND(F1.Revenue / F1.TotalRevenue * 100, 2)
			FROM PR.Customers AS C
			INNER JOIN
			(
				-- Fatturato anno selezionato
				SELECT 'FATTURATO_AC' AS Typology, CustomerId, SUM(NetAmount) AS Revenue, @TotalRevenueCustomers AS TotalRevenue 
					FROM #temp_revenue_customers
					WHERE  CONVERT(date, CreationDate) BETWEEN @StartDate and @EndDate
					GROUP BY CustomerId
			) AS F1
			ON C.CustomerId = F1.CustomerId
			INNER JOIN 
			(
				-- Fatturato anno precedente all'anno selezionato
				select 'FATTURATO_AP' AS Typology, Customerid, SUM(NetAmount) AS Revenue, @TotalRevenueCustomers AS TotalRevenue
					FROM #temp_revenue_customers
					WHERE  CONVERT(date, CreationDate) BETWEEN DATEADD(Year, -1, @StartDate) and DATEADD(Year, -1, @EndDate)
					GROUP BY CustomerId
			) AS F2
			ON C.CustomerId = F2.CustomerId
			ORDER BY F1.Revenue DESC

			-- Debug
			--select * from #temp_revenue_customers WHERE
			--CONVERT(Date, CreationDate) BETWEEN DATEADD(Year, -1, @StartDate) and DATEADD(Year, -1, @EndDate)

END

EXEC PR.GetCustomersReportDetailsData null, null,'20160101','20161231',null,null, null, null, null,null

SELECT CONVERT(Date, DATEADD(Year,-1,getdate())) AS DateYearAgo




