-- finding the avverage of the price with the dietary preferences vegan and non vegan based on the category and sub category
use ddmban_sql_analysis;-- setting up the database

SELECT 
    *
FROM
    ddmban_data; -- selecting the columns from table 




WITH 			`ssp` AS (   -- setting the variable name with the 'with' clause
				SELECT 
				
                
                
                ID, category, subcategory, product,
               
                
                
                FORMAT (replace(price, '.', '')/100,2) AS new_price, -- converting all the prices to dollars
                
                
                
                vegan , glutenfree , ketofriendly , vegetarian , organic ,
                
				dairyfree , sugarconscious , paleofriendly , wholefoodsdiet , lowsodium ,
				kosher , lowfat , engine2, -- selecting all the dietary preferences listed in the table
			
                
                
				
				(vegan + glutenfree + ketofriendly + vegetarian + organic +
	dairyfree + sugarconscious + paleofriendly + wholefoodsdiet + lowsodium +
	
    kosher +lowfat + engine2 ) AS sum_diet_pref,
    
    
    
				caloriesperserving,
			
    
    
				CASE WHEN servingsizeunits = 'g' 	THEN FORMAT (servingsize,0) -- formating the size to g which is grams to equalise
				
			WHEN servingsizeunits = 'grams' THEN FORMAT  (servingsize,0) 
			
			WHEN servingsizeunits = 'oz'	 THEN FORMAT  (servingsize*28.3495,0) 
			
            WHEN servingsizeunits = 'ml' THEN FORMAT (servingsize,0) 
           
            WHEN servingsizeunits = 'lb' THEN FORMAT (servingsize*453.592,0) 
         
            END AS serv_size_per_g -- converting all the measurements to grams
          
            
            
            FROM ddmban_data
         
            
		),
            
            
            
		`testing` AS (SELECT 
		
					 ID, category, subcategory, product,
					
                     
                     
						new_price,
						
                        
                        
					vegan , glutenfree , ketofriendly , vegetarian , organic ,
					
				dairyfree , sugarconscious , paleofriendly , wholefoodsdiet , lowsodium ,
			
				kosher , lowfat , engine2,
				
                
                
					caloriesperserving,
			
                    
                    
                    serv_size_per_g,
                 
                    
                    
                    FORMAT(caloriesperserving / serv_size_per_g,2) AS cal_per_g
                    
                    
                    
                    FROM   `ssp` -- changing the calories per serving
                
                    
                    
                    WHERE serv_size_per_g IS NOT NULL), -- where the serving size is not 0 we convert it 
                 
                    
                    
			`vegan` AS (select * from `testing` WHERE vegan = 1 ),
		
            `nonvegan` AS (select * from `testing` WHERE vegan = 0 ), 
   
            
            
            `avg_v` AS ( SELECT FORMAT(AVG(new_price),2), category FROM `vegan` -- selecting the price with dollars and finding the avg price for each dietary preferance
           
							GROUP BY category),
           `avg_nonv` AS ( SELECT FORMAT(AVG(new_price),2), category FROM `nonvegan`
           
							GROUP BY category)   ,
                            
                            
                            
                            
			`vegetarian` AS (select * from `testing` WHERE vegetarian = 1 ), -- selecting the data which is vegetarian 
			
            `nonvegetarian` AS (select * from `testing` WHERE vegetarian = 0 ), -- selecting data which is not vegetarian
          
            
            
            `avg_vegetarian` AS ( SELECT FORMAT(AVG(new_price),2) AS avg_vegan_y, category FROM `vegan`
            
							GROUP BY category),
           `avg_nonvegetarian` AS ( SELECT FORMAT(AVG(new_price),2) AS avg_vegan_n, category FROM `nonvegan`
                  
							GROUP BY category)         
                            
SELECT * FROM   `avg_vegetarian`

LEFT JOIN `avg_nonvegetarian` -- joining the vegetarian column with non vegetarian column using category
using (category)

LEFT JOIN  `avg_nonv`

using (category)
LEFT JOIN   `avg_v`

using (category); -- using the category column

-- -------------------------

SELECT 
    (AVG(price * vegan) - AVG(price) * AVG(vegan)) / (SQRT(AVG(price * price) - AVG(price) * AVG(price)) * SQRT(AVG(vegan * vegan) - AVG(vegan) * AVG(vegan))) AS correlation_coefficient_vegan
FROM
    ddmban_data;
        -- correlation between Organic ketofriendly and Prices 
SELECT 
    (AVG(price * ketofriendly) - AVG(price) * AVG(ketofriendly)) / (SQRT(AVG(price * price) - AVG(price) * AVG(price)) * SQRT(AVG(ketofriendly * ketofriendly) - AVG(ketofriendly) * AVG(ketofriendly))) AS correlation_coefficient_ketofriendly
FROM
    ddmban_data;
	
SELECT 
    *
FROM
    ddmban_data;
-- Selecting correlation values between diet columns and price
Select category, subcategory, 
/*correlation between gluten free and Prices */
Round((Count(*)*Sum(glutenfree *price)-Sum(organic)*Sum(price))/
         (sqrt(Count()*Sum(glutenfree*glutenfree)-Sum(glutenfree)*Sum(glutenfree))
          sqrt(Count(*)*Sum(price*price)-Sum(price)*Sum(price))),2) AS glutenfree_Correlation;
SELECT 
    (AVG(price * glutenfree) - AVG(price) * AVG(glutenfree)) / (SQRT(AVG(price * price) - AVG(price) * AVG(price)) * SQRT(AVG(glutenfree * glutenfree) - AVG(glutenfree) * AVG(glutenfree))) AS correlation_coefficient_glutenfree
FROM
    ddmban_data;
    -- checking the max, avg and range of the organic products price
SELECT 
    category,
    subcategory,
    AVG(price) AS average_organic_price,
    MAX(price) AS costly_organic_price
FROM
    ddmban_data
WHERE
    organic = 1
GROUP BY category , subcategory;
SELECT 
    category,
    subcategory,
    AVG(price) AS average_nonorganic_price,
    MAX(price) AS costly_nonorganic_price
FROM
    ddmban_data
WHERE
    organic != 1
GROUP BY category , subcategory;
    
    -- correlation between organic food and price
SELECT 
    (AVG(price * organic) - AVG(price) * AVG(organic)) / (SQRT(AVG(price * price) - AVG(price) * AVG(price)) * SQRT(AVG(organic * organic) - AVG(organic) * AVG(organic))) AS correlation_coefficient_organic
FROM
    ddmban_data;
-- Selecting correlation values between diet columns and price
SELECT 
    *
FROM
    ddmban_data;

SELECT 
    category,
    subcategory,
    CASE
        WHEN
            COUNT(subcategory) < 2
                OR COUNT(subcategory)
        THEN
            'less data points for correlation'
        ELSE 'Data for correlation is perfect'
    END AS Data_Points
FROM
    ddmban_data
WHERE
    price != 0 AND category != 'NULL'
        AND (SELECT 
            COUNT(subcategory)
        FROM
            ddmban_data) > 1
GROUP BY category , subcategory;
-- ----- performing the t test for gluten free and price checking is there is significant difference
SELECT 
    (AVG(glutenfree) - AVG(price)) / (SQRT((STDDEV(glutenfree) ^ 2 / COUNT(glutenfree)) + (STDDEV(price) ^ 2 / COUNT(price)))) AS t_value
FROM
    ddmban_data
WHERE
    glutenfree = 1
;-- the degree of freedom is 51 for the gluten free hence when we check the t table the p value is 0
-- t test between price of low fat and keto --
SELECT 
    (AVG(ketofriendly) - AVG(price)) / (SQRT((STDDEV(ketofriendly) ^ 2 / COUNT(ketofriendly)) + (STDDEV(price) ^ 2 / COUNT(price)))) AS t_value
FROM
    ddmban_data
WHERE
    ketofriendly = 1
        AND (SELECT -- using the subquery at the where clause to find the t test value 
            (AVG(lowfat) - AVG(price)) / (SQRT((STDDEV(lowfat) ^ 2 / COUNT(lowfat)) + (STDDEV(price) ^ 2 / COUNT(price)))) AS t_value
        FROM
            ddmban_data
        WHERE
            lowfat = 1); -- comparing the prices between the keto and low fat 
-- the resulted t test value is compared with df and the p value is 0.004


