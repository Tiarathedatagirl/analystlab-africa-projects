# Customer Churn Analysis Dashboard

## Week 5 – Business Analytics Case Study

### Project Overview

For this project, I analyzed the IBM Telco Customer Churn dataset to understand why customers leave the company's services. The goal was to identify the main factors contributing to churn and provide practical recommendations that could help improve customer retention.

The dashboard was built in Power BI and presents important business metrics and trends through interactive visualizations.

---

## Business Problem

Customer churn affects business growth and revenue. This project focuses on identifying the characteristics of customers who are more likely to leave and highlighting areas where the business can improve customer retention.

---

## Dataset

* **Dataset:** IBM Telco Customer Churn Dataset
* **Source:** Kaggle
* **Total Records:** 7,043 customers
* **Total Columns:** 21

---

## Data Cleaning

Before building the dashboard, I cleaned the dataset in Power Query.

The cleaning process included:

* Checking for missing values.
* Identifying 11 missing values in the **TotalCharges** column.
* Confirming that the affected customers had a tenure of 0 months.
* Replacing the missing **TotalCharges** values with 0.
* Confirming that there were no duplicate Customer IDs.
* Verifying that each column had the correct data type.

---

## Tools Used

* Power BI
* Power Query
* DAX

---

## Dashboard Highlights

The dashboard includes:

* Total Customers
* Churned Customers
* Active Customers
* Churn Rate
* Churn by Contract Type
* Churn by Payment Method
* Churn by Internet Service
* Churn by Tech Support
* Customer Tenure Analysis
* Interactive Filters

---

## Key Findings

* The company has 7,043 customers with an overall churn rate of 26.5%.
* Customers on Month-to-Month contracts are more likely to churn than those on longer contracts.
* Electronic Check customers have the highest churn rate among all payment methods.
* Customers without Tech Support are much more likely to leave.
* Fiber Optic customers show a higher churn rate compared to DSL customers.
* Most customers who churn have been with the company for a relatively short period.

---

## Recommendations

* Encourage customers to move to longer-term contracts by offering incentives.
* Improve support and engagement for new customers during their first year.
* Promote automatic payment methods instead of Electronic Check.
* Offer Tech Support packages to customers who do not currently have them.
* Investigate the reasons behind the higher churn among Fiber Optic customers.

---

## Repository Contents

* README.md
* Customer_Churn_Dashboard.pbix
*customer churn analysist.docx
*Customer churn alaysis.pptx
* Dashboard_Screenshot.png

---

## Author

**Damilola Owolabi**

AnalystLab Africa Data Analytics Internship – Week 5 Business Analytics Case Study

