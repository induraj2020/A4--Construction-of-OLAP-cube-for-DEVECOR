# Construction-of-OLAP-cube-for-DEVECOR

## Introduction:
   Given the DEVECOR dataset, In this project, I develop a OLAP cube from the raw data and transform the data as tables using PLSQL for further data integration and visualization
   The purpose of this project is to implement the learnings from PL/SQL and apply it to demo case of DEVECOR. Our objective is to build operational database do the ETL and build warehouse with DataMart’s. But for this case we replicate the framework of data warehouse with 2 databases and pushing the data after cleaning and then building the small tables needed by the respective department.

## Objective: 
  * To integrate data's such that OLAP cube is formed
  * To master PLSQL language and the concept of OLAP cube
  * Visualize the OLAP cube using QLIKSENSE

## Procedure used
1. Operational database for company,
   * The script for creating tables in the operational database
   * The script of my procedure that will generate the dataset.
   * And finally you give the privileges to the session 2 to read the contents of the created tables
 
 2. Decisional database for the management of the company
      * The script for creating the tables of the decision database
      * The script of the procedure that will select to give them from the operational database to put them in the decision-making database (ETL).

3. Expression of needs The sales manager wants:
      * To study the turnover and sales volume
      * By product and Family.
      * Per week, month and year.
      * By department and region.
      
4. A procedure to generate
      * Supply chain analysis (Inventory, sales in a given time period)

## PLSQL code
  To See Full plsql code [click here](https://github.com/induraj2020/A4--OLAP-cube-PLSQL-supermarket-dataset-/blob/master/2019.12.28%20-%20PLSQL.pdf)
  
  screenshot of sample of code:
  ![](plsql_sample.PNG)

## OLAP Cube visualization in QLIK Sense

  screenshot of sample visualization:
  
  ![](olap_sample.PNG)
  
  ![](sample_analysis.PNG)
  
