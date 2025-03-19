# Customer-Live-Value-CLV-Segmentation
Highlighting oppurtunities for up-selling  and cross-selling in a telecom company.

## INTRODUCTION 

This is a SQL project on Customer Lifetime Value (CLV) segmentation. CLV allow businesses to identify and priotize high-value customer segments , thereby enabling targeted marketing effects and tailored service offering. By understanding the unique needs and behaviour of each segment , company can optimize resources allocation , maximize revenue and foster stronger customer relationships. The adoption of CLV segmentation directly addresses the primary challenge : unlocking up-selling and cross-selling oppurtunities within their customer base.

**_Data Source_** : Nexa_Sat Telecommunication

## Problem Statement 
1. Pressing challenges in optimizing their marketing strategies and resource allocation.
2. The company has  diverse customer base which has led to inefficiencies in the customer engagement effort
3. Intensified competition in the telecommunication  sector 
4. Challemged with crafting offer that actually align with the customer preferences and usage pattern 
5. Nexa_Sat posses a ealth of customer data but lack a systematic methodoloy to harness these isight effectively
   

## Exploratory Data Analysis (EDA)
Feature engineering and segment profiling , ensuring each customer segment receives personlized attention.

# Aim of the project 
The primary ai of implementing CLV segmentation at Nexa_Sat is to drive strategic revenue growth through targeted upselling and cross-selling initiatives . This CLV appproach will not only maximize the average revenue but also enhance customer satisfaction and loyalty . 

## Project Scope
### 1. Exploratory Data Analysis
      Conduct a thorough examination of customer dataset , including demographic iformation and usage patterns. This will provide crucial insights in customer behaviour and preferences.
### 2. Feature Engineering 
      Engineer relevant feature such as CLV and CLV score. This will serve as key input for the CLV segmentation model.
### 3. Segmentation 
      Assign customer to different segment based on CLV score. Further segment users based on demographic data , usage patterns and service plans.
### 4. Segment Profiling and strategy Formulation 
      Understand the unique traits tha define each segment and decide the kind of attention each segment require. Develop personalized marketing and communication strategies for each           segment.

## Data Cleaning 
I check for duplicates and null values

## Exploratory Data Analysis
- I checked number of current users at Nexa_sat , 4,272 are active from a total of 7,043
- Total user by plan level reveal that 3,580 are premium while 3,463 are basic users.
- The total revenue generated is 1,054,953.70. Basic user generated 426,622.00 while Premium user generated 628,331.70
- Number of Churned customer and their plan type
  Plan Level   | Plan Type      | Total Customers | Churn Customers
  :-----------:|:--------------:|:---------------:|:--------------:
  Basic          Prepaid           1,108              623
  Basic          Postpaid           2,355             1,583
  Premium        Prepaid            1,832             220
  Premium         Postpaid           1,748            345

- Average tenure by plan level
  Plan Level   | Average Tenure (Months)
  :-----------:|:----------------------:
  Premium        32.16
  Basic          16.61

### Analysing Segment
I group my customers based on clv score . when clv is > 1 then ‘high value’ , when CLV score >= 0.5 then ‘moderate value’ , when CLV <= 0.25 the ‘low value’ others ‘Churn risk’


## Recommendation
### - Come up with strategies to sell to various segment 
  Selling tech support to senior citizen who do not have dependent . We could have offer them tech support especially those at the risk of churn or low value . They might have problem using technologies . We should offer them services that could help.
### - Selling tech support to senior citizen who do not have dependent . 
 We could have offer them tech support especially those at the risk of churn or low value . They might have problem using technologies . We should offer them services that could help.
### - Cross-selling to high rate customers 
  We are not offering them  a higher tier , just selling additional services to them
### - Upselling 
  - Offer discount to basic users who are at churn risk (to make the deal sweeter) 50% off for 3 month.
  - Offer basic user who are at high and moderate segment , we can offer them premium plan level considering the average tenure month. we do this to lock them in. some might prefer to 
  stick to the premium package
### - Average bill and average tenure per plan_type
-premium has average bill of 200.97 and average tenure of 35.17
 Basic has average bill of 241.42 and average tenure of 17.18
-this shows premium spent avery long ti me with the company but less average bill compare to basic users. To extend the time of basic user , offer them premium package to increase the ARPU.
