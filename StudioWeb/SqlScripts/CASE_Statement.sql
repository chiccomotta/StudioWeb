

SELECT top 10 name, 
	CASE SUBSTRING(Name, 1, 1) 
		WHEN 'A'      
		THEN 'name inizia per A'
                       WHEN 'B' THEN 'name inizia B'
				ELSE 'non lo so...'
       END AS msg
FROM PR.Contacts
