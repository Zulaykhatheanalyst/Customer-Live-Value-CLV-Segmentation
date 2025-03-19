CREATE TABLE Nexa_sat (
						Customer_ID Varchar,
						Gender text,
						Partner text,
	 					Dependents text,
						Senior_Citizen varchar,
						Call_Duration int,
						Data_Usage float,
						Plan_Type Text,
						Plan_Level text,
						Monthly_Bill_Amount float,
						Tenure_Months int,
						Multiple_Lines text,
						Tech_Support text, 
						Churn varchar
)

SELECT * from nexa_sat
		

--to confirm current schema
select current_schema()

--set path for queries
SET search_path to  "Nexa_Sat"

--DATA CLEANING
	
--check for duplicates
select * from nexa_sat 
group by Customer_ID, Gender , Partner , Dependents , Senior_Citizen ,
	Call_Duration ,	Data_Usage , Plan_Type , Plan_Level , Monthly_Bill_Amount , 
	Tenure_Months ,	Multiple_Lines , Tech_Support , Churn 
having count(*) >1      --This check for rows that duplicates

--check for null values
select * from nexa_sat 
where customer_id is NULL 
	OR Gender is NULL
	OR Partner is NULL
	OR Dependents is NULL
	OR Senior_Citizen is NULL
	OR Call_Duration is NULL
	OR Data_Usage is NULL
	OR Plan_Type is NULL
	OR Plan_Level is NULL 
	OR Monthly_Bill_Amount is NULL 
	OR Tenure_Months is NULL
	OR Multiple_Lines is NULL
	OR Tech_Support is NULL 
	OR Churn is NULL

--EDA

--How many user nexa_sat has currently
select count(customer_id) as current_user
from nexa_sat
where churn = 'false'

--total user per plan 
select plan_level,
	count(customer_id) as Total_user
from nexa_sat
GROUP BY 1

--TOTAL REVENUE
select round(sum(Monthly_Bill_Amount :: numeric),2)
from nexa_sat

SET select current_schema();
search_path to "Nexa_Sat"

--Revenue by payment plan
SELECT plan_level, 
ROUND(sum(monthly_bill_amount::numeric),2) AS revenue
from nexa_sat
GROUP BY 1
ORDER BY 2

--Churn  count by plan type and plan level 
SELECT plan_level ,
	   plan_type ,
	   count(*) AS total_customers,
	   sum(churn) AS Churn_count
from nexa_sat
GROUP BY 1,2 
ORDER BY 1

SELECT plan_level,
       plan_type,
       count(*) AS total_customers,
       sum(CASE WHEN churn = true THEN 1 ELSE 0 END) AS Churn_count
FROM nexa_sat
GROUP BY 1, 2
ORDER BY 1;

--Average Tenure by Plan_level
SELECT Plan_level , Round(avg(tenure_months),2) AS Avg_tenure
FROM nexa_sat
GROUP BY 1

--ANALYZING SEGMENT --CLV SEGMENTATION

--Marketing Segments

--Create Table for existing users only 
CREATE TABLE Existing_users AS 
SELECT * from nexa_sat
where churn = false

	--view new table
select * from Existing_users

--Calculate ARPU (Average Revenue per User)nfor existing customers 
SELECT Round(avg(monthly_bill_amount :: int),2) AS ARPU
FROM Existing_users

--Calculate CLV and add column
ALTER TABLE existing_users
ADD column CLV float

UPDATE Existing_users
SET CLV = monthly_bill_amount * tenure_months

--view the new column
Select customer_id , clv 
FROM existing_users

--CLV SCORE 	
--Assign monthly_bill as 40%, tenure = 30% , call_dduration = 10% , Data_usage =10%, PRemium = 10%
ALTER TABLE existing_users
ADD COLUMN clv_score NUMERIC(10,2)

UPDATE existing_users 
SET clv_score =
				(0.4 * monthly_bill_amount)+
				(0.3 * tenure_months) +
				(0.1 * call_duration) +
				(0.1 * Data_usage) +
				(0.1 * CASE WHEN plan_level = 'Premium'
								THEN 1 ELSE 0
						END)

--view new column
select customer_id , clv_score
FROM existing_users

--Now group the users into Segment base on their CLV_Score
--CREATE A NEW COLUMN clv_segments
ALTER TABLE existing_users
ADD COLUMN clv_segments VARCHAR

UPDATE existing_users 
SET clv_segments =
				 CASE WHEN clv_score > (SELECT Percentile_cont(0.85)
										WITHIN GROUP (ORDER BY clv_score)
										FROM existing_users) THEN 'High Value'
	
				      WHEN clv_score >= (SELECT Percentile_cont(0.5)
										WITHIN GROUP (ORDER BY clv_score)
										FROM existing_users) THEN 'Moderate Value'

                     WHEN clv_score <= (SELECT Percentile_cont(0.5)          
										WITHIN GROUP (ORDER BY clv_score)
										FROM existing_users) THEN 'Low Value'
					ELSE 'Churn Risk'   		
					END

--view our segment column
SELECT customer_id , clv , clv_score , clv_segments
FROM existing_users

--ANALYSING SEGMENTS
/*Avg bill and tenure per segment 
Tech support and multiple line count
Revenue per segment*/

--.Avg bill and tenure per segment
select clv_segments,
		Round(avg(monthly_bill_amount :: INT),2) AS avg_monthly_charges,
		ROUND(AVG(tenure_months :: INT), 2) AS avg_tenure
FROM existing_users
GROUP BY 1

--Tech support and multiple line count
SELECT 
    clv_segments,
    ROUND(AVG(CASE WHEN tech_support = 'yes' THEN 1 ELSE 0 END), 2) AS tech_support_pct,
    ROUND(AVG(CASE WHEN multiple_lines = 'yes' THEN 1 ELSE 0 END), 2) AS multiple_lines_pct
FROM existing_users
GROUP BY clv_segments;

--REVEUE BY SEGMENTcount the number of customer in each segment
SELECT 
    clv_segments,
    COUNT(customer_id) AS customer_count,
    CAST(SUM(monthly_bill_amount * tenure_month) AS NUMERIC(10,2)) AS total_revenue
FROM existing_users
GROUP BY clv_segments;

----UP-SELLING AND CROSS SELLING
/*COME UP WITH STRATEGIES TO SELL TO VARIOUS SEGMENTS
selling tech support to senior citizen who do not have independentss. We could offer them tech support
Especially those at the risk of churn or low value. They might have problem using technologies. 
we should offer all our customers services that could help */

/*HIGH RATE CUSTOMERS
cross selling because we are offering them a higher tier, just selling additioal services to them.

--CROSS SELLING TECH support to senior citizen */

SELECT customer_id
FROM existing_users
WHERE senior_citizen = TRUE -- Corrected to compare boolean value
  AND dependents = 'No' -- No dependents
  AND tech_support = 'No' -- Do not already have this service
  AND clv_segments IN ('Churn Risk', 'Low Value'); -- Match either 'Churn Risk' or 'low value'

--VIEW SEGMENTS
SELECT customer_id, clv, clv_score, clv_segments 
FROM existing_users

--CROSS SELLING: MULTIPLE LINES FOR PARTNERS ANDD DEPENDENTS
SELECT customer_id
FROM existing_users
WHERE multiple_lines = 'No'
AND dependents = 'Yes' OR Partner = 'Yes'
AND plan_level = 'Basic'

--UPSELLing
--Premium discount for basic user with churn risk
SELECT customer_id
FROM existing_users
WHERE clv_segments = 'Churn Risk'
AND plan_level = 'Basic'

--UPSELLING  : Basic to premium for longer lock in period and higher ARPU
SELECT plan_level,
		ROUND(AVG(monthly_bill_amount :: INT),2) AS avg_monthly_charge,
		ROUND(AVG(tenure_months :: INT),2) AS Avg_month_spent
FROM EXISTING_USERS
WHERE clv_segments = 'High Value'
OR clv_segments = 'Moderate Value'
GROUP BY 1

--SELECT CUSTOMERS
SELECT customer_id , monthly_bill_amount
FROM existing_users
WHERE plan_level = 'Basic'
AND clv_segments IN ('High value', 'Moderate Value')
AND monthly_bill_amount > 150 


--CREATE STORED PROCEDURE

--SNR CITIZEN WHO WILL BE OFFERED TECH SUPPORT

CREATE FUNCTION tech_support_snr_citizen()
	RETURNS TABLE (customer_id VARCHAR(50))
AS $$
BEGIN 
	return QUERY
	SELECT eu.customer_id
	FROM existing_users eu
	WHERE eu.senior_citizen = TRUE -- Corrected to compare boolean value
    AND eu.dependents = 'No' -- No dependents
  	AND eu.tech_support = 'No' -- Do not already have this service
  	AND eu.clv_segments IN ('Churn Risk', 'Low Value'); -- Match either 'Churn Risk' or 'low value'
END			
$$ LANGUAGE PLPGSQL

--customer at churn risk, who will be offered premium discount
CREATE FUNCTION churn_risk_discountt()
RETURNS TABLE (customer_id VARCHAR(50))
AS $$
BEGIN
    RETURN QUERY
    SELECT existing_users.customer_id  -- Qualify the column name with the table name
    FROM existing_users
    WHERE clv_segments = 'Churn Risk'
    AND plan_level = 'Basic';
END;
$$ LANGUAGE PLPGSQL;



--high usage customer who will be offer premium upgrade
CREATE FUNCTION High_usagee_basic()
RETURNS TABLE (customer_id VARCHAR(50), monthly_bill_amount DOUBLE PRECISION)
AS $$
BEGIN
    RETURN QUERY
    SELECT existing_users.customer_id, existing_users.monthly_bill_amount  -- Qualify the column names with the table name
    FROM existing_users
    WHERE plan_level = 'Basic'
    AND clv_segments IN ('High value', 'Moderate Value')
    AND existing_users.monthly_bill_amount > 150;  -- Qualify the column name here as well
END;
$$ LANGUAGE PLPGSQL;



--USE PROCEDURES

--churn_risk_discount
select * from churn_risk_discountt()

--high usage basic customer
select * from High_usagee_basic()

















































































				
























 



























