
select distinct CustomerCategoryname from PR.Customers
select distinct AbsolutePotential from PR.Customers
select distinct RelativePotential from PR.Customers
select distinct ProductCategory from PR.Orders

select CustomerCategoryname, count(*) as Quantity from PR.Customers
	group by CustomerCategoryname

select top 10 * from [PR].[Customers]
select * from [PR].[Orders] where CustomerId = '84969CF4-BA25-4CBA-AE5F-0202A5ED185A'


ALTER PROCEDURE PR.GetCustomersReportData
	@UserId				uniqueidentifier			,
	@LineId				uniqueidentifier			,
	@StartDate			datetime			= null	,			
	@EndDate			datetime			= null	,			
	@CategoryName		nvarchar(60)		= null	,
	@AbsolutePotential	nvarchar(60)		= null	,
	@RelativePotential	nvarchar(60)		= null	

AS
BEGIN
	
	IF OBJECT_ID(N'tempdb.dbo.#temp_orders_customers', N'U') IS NOT NULL
	BEGIN
		DROP TABLE #temp_orders_customers
	END

	-- Estraggo i dati
	SELECT 		
		C.CustomerCode,
		C.BusinessName,
		C.AbsolutePotential,
		C.RelativePotential,
		O.*						
	INTO 
		#temp_orders_customers
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
			(CONVERT(date, O.CreationDate) BETWEEN @StartDate and @EndDate)

--	select * from #temp_orders_customers

		-- Raggruppo
		SELECT 'CATEGORIES' AS Typology, CustomerCategoryName AS Description, COUNT(*) AS Quantity 
			FROM PR.Customers 
			WHERE CustomerId IN (SELECT DISTINCT CustomerId FROM #temp_orders_customers)			
			GROUP BY CustomerCategoryName
		
		UNION ALL

		SELECT 'ABS_POTENTIAL' AS Typology, AbsolutePotential AS Description, COUNT(*) AS Quantity 
			FROM PR.Customers 
			WHERE CustomerId IN (SELECT DISTINCT CustomerId FROM #temp_orders_customers)			
			GROUP BY AbsolutePotential
		
		UNION ALL

		SELECT 'REL_POTENTIAL' AS Typology, RelativePotential AS Description, COUNT(*) AS Quantity 
			FROM PR.Customers 
			WHERE CustomerId IN (SELECT DISTINCT CustomerId FROM #temp_orders_customers)			
			GROUP BY RelativePotential

		UNION ALL
	
		SELECT 'PRODUCT_LINE' AS Typology, ProductLine AS Description, count(*) AS Quantity 
			FROM #temp_orders_customers
			GROUP BY ProductLine

		UNION ALL
			
		SELECT 'PRODUCT_GROUP' AS Typology, ProductGroup AS Description, count(*) AS Quantity 
			FROM #temp_orders_customers
			GROUP BY ProductGroup

		UNION ALL
			
		SELECT 'PRODUCT_CATEGORY' AS Typology, 	CASE ProductCategory
			WHEN '01' THEN 'EXTRA LISTINO + MERCHANDISING'
			WHEN '02' THEN 'LISTINO'				
			END AS Description, count(*) AS Quantity 
		FROM #temp_orders_customers
		GROUP BY ProductCategory

END

EXEC PR.GetCustomersReportData null, null,'20160101','20170101',null,null, null

update PR.Orders SET ProductCategory = '01' where substring(BeneficiaryName,1,1) = 'U'
update PR.Orders SET ProductCategory = '02' where substring(BeneficiaryName,1,1) = 'V'