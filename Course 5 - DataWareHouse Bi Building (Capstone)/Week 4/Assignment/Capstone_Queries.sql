/*Base Queries*/

/*Query 1*/
/*
CREATE VIEW BQ1 AS
SELECT W_JOB_F.Location_ID,Location_Name,W_SALES_CLASS_D.Sales_class_id,Sales_Class_Desc,Time_Year,Time_Month,Base_price,SUM(Quantity_Ordered) AS SUMQTY,SUM(Quantity_Ordered*Unit_Price) AS Job_Amount
FROM W_JOB_F,W_LOCATION_D,W_SALES_CLASS_D,W_TIME_D
WHERE W_JOB_F.Location_ID = W_LOCATION_D.Location_ID AND  W_JOB_F.Sales_class_id = W_SALES_CLASS_D.Sales_class_id AND W_TIME_D.Time_id = W_JOB_F.Contract_date 
GROUP BY W_JOB_F.Location_ID,Location_Name,W_SALES_CLASS_D.Sales_class_id,Sales_Class_Desc,Time_Year,Time_Month,Base_price;
*/
/*Query 2*/
/*
CREATE VIEW BQ2 AS
SELECT W_JOB_F.JOB_ID,W_JOB_F.Location_ID,W_Location_D.Location_Name,Unit_Price,Quantity_Ordered,Time_Year,Time_Month,SUM(Invoice_Amount) AS SUMINVAMT,SUM(Invoice_Quantity) AS SUMINVQTY
FROM W_JOB_F,W_LOCATION_D,W_TIME_D,W_INVOICELINE_F,W_SUB_JOB_F,W_JOB_SHIPMENT_F
WHERE W_JOB_F.Location_ID = W_LOCATION_D.Location_ID  AND W_TIME_D.Time_id = W_JOB_F.Contract_date 
AND W_Job_Shipment_F.Invoice_Id = W_InvoiceLine_F.Invoice_Id AND W_JOB_F.Job_Id = W_SUB_JOB_F.Job_Id  AND W_JOB_SHIPMENT_F.Sub_Job_Id = W_Sub_Job_F.Sub_Job_Id
GROUP BY W_JOB_F.JOB_ID,W_JOB_F.Location_ID,W_Location_D.Location_Name,Unit_Price,Quantity_Ordered,Time_Year,Time_Month;
*/

/* Query 3*/
/*
CREATE VIEW BQ3 AS 
SELECT JOB_ID,Location_ID,Location_Name,Time_Year,Time_Month,SUMLABOUR, SUMMATERIAL, SUMOVERHEAD,SUMMACHINE,SUMQTY,TOTALCOST,TOTALCOST/SUMQTY AS UNIT_PRICE
FROM (
SELECT W_SUB_JOB_F.JOB_ID,W_SUB_JOB_F.Location_ID,Location_Name,Time_Year,Time_Month,SUM(Cost_Labor) AS SUMLABOUR,SUM(Cost_Material) AS SUMMATERIAL,SUM(Cost_Overhead) AS SUMOVERHEAD,SUM(Machine_Hours*Rate_per_hour) AS SUMMACHINE,SUM(Quantity_produced) AS SUMQTY,
SUM(Cost_Labor+Cost_Material+Cost_Overhead+Machine_Hours*Rate_per_hour) AS TOTALCOST
FROM W_SUB_JOB_F,W_JOB_F,W_TIME_D,W_LOCATION_D,W_MACHINE_TYPE_D
WHERE W_SUB_JOB_F.Job_id = W_JOB_F.Job_id  AND W_location_d.location_id = W_SUB_JOB_F.Location_id AND W_Time_D.Time_id = W_Job_F.Contract_Date AND
W_SUB_JOB_F.Machine_Type_id = W_Machine_Type_D.Machine_Type_ID
GROUP BY W_SUB_JOB_F.JOB_ID,W_SUB_JOB_F.Location_ID,Location_Name,Time_Year,Time_Month);

*/

/*Query 4*/
/*
CREATE VIEW BQ4 AS
SELECT W_InvoiceLine_F.Location_Id, Location_Name,W_InvoiceLine_F.Sales_Class_Id, Sales_Class_Desc,Time_Year, Time_Month,
  SUM ( Quantity_shipped - Invoice_Quantity ) as QTYRETURNED,SUM ( (Quantity_shipped - Invoice_quantity) * (Invoice_amount/Invoice_quantity) ) AS SUMAMTRETURNED
 FROM W_INVOICELINE_F,W_Location_D ,W_Sales_Class_D,W_TIME_D    
 WHERE quantity_shipped - invoice_quantity > 0 
 AND W_INVOICELINE_F.INVOICE_SENT_DATE = W_TIME_D.TIME_ID AND W_INVOICELINE_F.Location_Id = W_Location_D.Location_Id
 AND W_INVOICELINE_F.Sales_Class_Id = W_Sales_Class_D.Sales_Class_Id
 GROUP BY W_InvoiceLine_F.Location_Id, Location_Name,W_InvoiceLine_F.Sales_Class_Id, Sales_Class_Desc,Time_Year, Time_Month;
*/


/* Query 5*/

/*Date Diff function */
/*
create or replace function getBusDaysDiff
(
-- Time_Id parameters
time_ID1 number,
time_ID2 number
-- time_id1 must be greater than time_id2
)
return number
IS

v_timne_ID1 integer;
v_timne_ID2 integer;
transTimeID integer;
difference integer;

Begin

v_timne_ID1 := time_ID1;
v_timne_ID2 := time_ID2;

if ( v_timne_ID1 = v_timne_ID2 ) then
return 0;
elsif ( v_timne_ID1 > v_timne_ID2 ) then 
transTimeID := v_timne_ID1;
v_timne_ID1 := v_timne_ID2;
v_timne_ID2 := transTimeID;
end if;

  execute immediate ' select count(*) from w_time_D where time_ID <= ' ||  v_timne_ID2 ||' and time_ID > ' || v_timne_ID1 into difference  ;

  if ( difference = '' or difference is null )then
    raise_application_error(-20011, ' An error occurred calculating the difference');
  else
    return  difference ;
  end if;
END;
*/

/*Query 5*/
/*
CREATE VIEW BQ5 AS
SELECT
Job_id,Location_ID,Location_Name,Sales_class_id,sales_class_desc,
Date_Promised,Quantity_Ordered,LastShipDate,SUMSHIPQTY,
getBusDaysDiff(LastShipDate,Date_Promised) AS DaysDiff
FROM
(
SELECT W_JOB_F.Job_id,W_JOB_F.Location_ID,Location_Name,W_JOB_F.Sales_class_id,sales_class_desc,
Date_Promised,Quantity_Ordered,MAX(Actual_Ship_Date) AS LastShipDate,SUM(Actual_Quantity) AS SUMSHIPQTY
FROM W_JOB_F,W_LOCATION_D,W_SALES_CLASS_D,W_SUB_JOB_F,W_JOB_SHIPMENT_F
WHERE Actual_Ship_Date > Date_Promised
AND W_JOB_F.Location_id =  W_LOCATION_D.Location_id AND W_Job_F.Sales_Class_Id = W_Sales_Class_D.Sales_Class_Id
AND W_SUB_JOB_F.SUB_JOB_ID = W_JOB_SHIPMENT_F.SUB_JOB_ID AND W_Job_F.Job_Id = W_SUB_JOB_F.JOB_ID
GROUP BY W_JOB_F.Job_id,W_JOB_F.Location_ID,Location_Name,W_JOB_F.Sales_class_id,sales_class_desc,
Date_Promised,Quantity_Ordered
)
WHERE LastShipDate > Date_Promised;
*/


/*Query 6*/
/*
CREATE VIEW BQ6 AS
SELECT
Job_id,Location_ID,Location_Name,Sales_class_id,sales_class_desc,
Date_Ship_By,FirstShipDate,getBusDaysDiff(FirstShipDate,Date_Ship_By) AS DaysDiff
FROM
(
SELECT W_JOB_F.Job_id,W_JOB_F.Location_ID,Location_Name,W_JOB_F.Sales_class_id,sales_class_desc,
Date_Ship_By,MIN(Actual_Ship_Date) AS FirstShipDate
FROM W_JOB_F,W_LOCATION_D,W_SALES_CLASS_D,W_SUB_JOB_F,W_JOB_SHIPMENT_F
WHERE W_JOB_F.Location_id =  W_LOCATION_D.Location_id AND W_Job_F.Sales_Class_Id = W_Sales_Class_D.Sales_Class_Id
AND W_SUB_JOB_F.SUB_JOB_ID = W_JOB_SHIPMENT_F.SUB_JOB_ID AND W_Job_F.Job_Id = W_SUB_JOB_F.JOB_ID
GROUP BY W_JOB_F.Job_id,W_JOB_F.Location_ID,Location_Name,W_JOB_F.Sales_class_id,sales_class_desc,
Date_Ship_By
)
WHERE FirstShipDate > Date_Ship_By;

*/


/* Analytic Queries */
/* AQ1 */
/*
SELECT Location_Name,Time_Year,Time_Month,SUM(Quantity_Ordered*Unit_Price) AS AMT,
SUM(SUM(Quantity_Ordered*Unit_Price)) OVER (Partition by Location_Name,Time_Year Order By Time_Month ROWS UNBOUNDED PRECEDING) AS CUMSUMAMT
FROM W_JOB_F,W_LOCATION_D,W_TIME_D
WHERE W_JOB_F.Location_ID = W_LOCATION_D.Location_ID 
AND W_TIME_D.Time_id = W_JOB_F.Contract_date 
GROUP BY Location_Name,Time_Year,Time_Month;
*/

/* AQ2 */
/*
SELECT Location_Name,Time_Year,Time_Month,AVG(Quantity_Ordered*Unit_Price) AS AVGAMT,
AVG(AVG(Quantity_Ordered*Unit_Price)) OVER (Partition by Location_Name Order By Time_Year,Time_Month ROWS 11 PRECEDING) AS AVGSUMAMT
FROM W_JOB_F,W_LOCATION_D,W_TIME_D
WHERE W_JOB_F.Location_ID = W_LOCATION_D.Location_ID 
AND W_TIME_D.Time_id = W_JOB_F.Contract_date 
GROUP BY Location_Name,Time_Year,Time_Month;
*/

/*AQ3*/
/*
Select BQ2.Location_Name,BQ2.Time_Year,BQ2.Time_Month,SUM(SUMINVAMT - TOTALCOST) AS Profit,
RANK() OVER(Partition By BQ2.Time_Year Order by SUM(SUMINVAMT - TOTALCOST) DESC) AS Rank
FROM BQ2,BQ3
WHERE BQ2.Job_id = BQ3.Job_id
GROUP BY BQ2.Location_Name,BQ2.Time_Year,BQ2.Time_Month;
*/

/*AQ4*/
/*
Select BQ2.Location_Name,BQ2.Time_Year,BQ2.Time_Month,SUM(SUMINVAMT - TOTALCOST)/SUM(SUMINVAMT) AS ProfitMargin,
RANK() OVER(Partition By BQ2.Time_Year Order by SUM(SUMINVAMT - TOTALCOST)/SUM(SUMINVAMT) DESC) AS Rank
FROM BQ2,BQ3
WHERE BQ2.Job_id = BQ3.Job_id
GROUP BY BQ2.Location_Name,BQ2.Time_Year,BQ2.Time_Month;
*/

/*AQ5*/
/*
Select BQ2.Job_Id,BQ2.Location_Name,BQ2.Time_Year,BQ2.Time_Month,SUM(SUMINVAMT - TOTALCOST)/SUM(SUMINVAMT) AS ProfitMargin,
PERCENT_RANK()  OVER(Order by SUM(SUMINVAMT - TOTALCOST)/SUM(SUMINVAMT) DESC) AS PercentRank
FROM BQ2,BQ3
WHERE BQ2.Job_id = BQ3.Job_id
GROUP BY BQ2.Job_Id,BQ2.Location_Name,BQ2.Time_Year,BQ2.Time_Month;
*/


/* AQ6 */
/*
Select * 
FROM
(
Select BQ2.Job_Id,BQ2.Location_Name,BQ2.Time_Year,BQ2.Time_Month,SUM(SUMINVAMT - TOTALCOST)/SUM(SUMINVAMT) AS ProfitMargin,
PERCENT_RANK()  OVER(Order by SUM(SUMINVAMT - TOTALCOST)/SUM(SUMINVAMT) DESC) AS PercentRank
FROM BQ2,BQ3
WHERE BQ2.Job_id = BQ3.Job_id
GROUP BY BQ2.Job_Id,BQ2.Location_Name,BQ2.Time_Year,BQ2.Time_Month
)
WHERE PercentRank < 0.05;
*/

/*AQ7*/
/*
CREATE VIEW AQ7 AS
SELECT  Sales_Class_Desc,Time_Year,
  SUM ( Quantity_shipped - Invoice_Quantity ) as QTYRETURNED,
  RANK() OVER(Partition By Time_Year Order By SUM ( Quantity_shipped - Invoice_Quantity ) DESC) AS Rank
 FROM W_INVOICELINE_F,W_Sales_Class_D,W_TIME_D    
 WHERE quantity_shipped - invoice_quantity > 0 
 AND W_INVOICELINE_F.INVOICE_SENT_DATE = W_TIME_D.TIME_ID 
 AND W_INVOICELINE_F.Sales_Class_Id = W_Sales_Class_D.Sales_Class_Id
 GROUP BY Sales_Class_Desc,Time_Year;
 */
 /* AQ8 */
 /*
 CREATE VIEW AQ8 AS
 SELECT  Sales_Class_Desc,Time_Year,
  SUM ( Quantity_shipped - Invoice_Quantity ) as QTYRETURNED,
  RATIO_TO_REPORT(SUM ( Quantity_shipped - Invoice_Quantity ))OVER(Partition By Time_Year)  AS Ratio
 FROM W_INVOICELINE_F,W_Sales_Class_D,W_TIME_D    
 WHERE quantity_shipped - invoice_quantity > 0 
 AND W_INVOICELINE_F.INVOICE_SENT_DATE = W_TIME_D.TIME_ID 
 AND W_INVOICELINE_F.Sales_Class_Id = W_Sales_Class_D.Sales_Class_Id
 GROUP BY Sales_Class_Desc,Time_Year
 ORDER BY Time_Year,QTYRETURNED;
*/

/* AQ9*/
/*
SELECT Location_Name,W_Time_D.Time_Year,SUM(DAYSDIFF) AS SUMDAYSDIFF,
RANK() OVER(Partition By W_Time_D.Time_Year Order By SUM(DAYSDIFF) DESC) AS Rank,
DENSE_RANK() OVER(Partition By W_Time_D.Time_Year Order By SUM(DAYSDIFF) DESC) AS DenseRank
FROM BQ6,W_Time_D
WHERE W_Time_D.Time_Id = BQ6.Date_Ship_By
GROUP BY Location_Name,W_Time_D.Time_Year;
*/

/* AQ10 */
/*
SELECT Location_Name,W_Time_D.Time_Year,SUM(DAYSDIFF) AS SUMDAYSDIFF,Count(*) AS NoofJobs,
SUM(Quantity_Ordered - SumShipQty) / SUM(Quantity_Ordered) AS Delay_Rate,
RANK() OVER(Partition By W_Time_D.Time_Year Order By SUM(Quantity_Ordered - SumShipQty) / SUM(Quantity_Ordered) DESC) AS Rank
FROM BQ5,W_Time_D
WHERE W_Time_D.Time_Id = BQ5.Date_Promised
GROUP BY Location_Name,W_Time_D.Time_Year;
*/
