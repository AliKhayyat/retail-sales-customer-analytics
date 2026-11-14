# Retail Sales & Customer Analytics

End-to-end customer analytics project built on the **Online Retail II** dataset (2009–2011), combining SQL, Python, machine learning, and Power BI to analyze customer value, purchasing behavior, purchase timing, and customer segmentation.

## Project Overview

The project transforms transactional retail data into an analytical customer layer and an interactive Power BI dashboard.

The workflow includes:

- Data exploration and preparation
- Customer-level feature engineering
- RFM analysis and segmentation
- Purchase timing analysis
- Customer value analysis
- Purchase behavior analysis
- Unsupervised customer clustering
- Model comparison using silhouette score
- SQL-based analytical modeling
- Interactive Power BI reporting

## Customer Analytics

The final customer master contains **5,881 customers** and includes:

- Recency
- Frequency
- Monetary value
- RFM scores
- RFM segment
- Average interpurchase days
- Overdue behavior
- Purchase timing cluster
- RFM cluster
- Customer value cluster
- Purchase behavior cluster

Customers without sufficient purchase history for timing analysis are retained with a missing timing cluster rather than being incorrectly assigned to a segment.

## Clustering Models

Four customer clustering approaches were evaluated on a common fair comparison subset of **4,396 customers**:

| Model | Silhouette Score |
|---|---:|
| Purchase Timing | 0.4214 |
| RFM | 0.4164 |
| Customer Value | 0.3340 |
| Purchase Behavior | 0.3251 |

The model comparison evaluates the separation quality of different behavioral perspectives rather than assuming that a single segmentation approach is universally optimal.

## Power BI Dashboard

The final dashboard contains five analytical pages:

1. **Executive Overview** — Overall customer and business performance.
2. **RFM Segment Analysis** — Customer segmentation based on recency, frequency, and monetary value.
3. **Purchase Timing Analytics** — Customer purchasing intervals, overdue behavior, and timing patterns.
4. **Purchase Behavior Analysis** — Product diversity, purchase intensity, and behavioral characteristics.
5. **Model Diagnostics** — Comparison and visualization of the customer clustering models.

## Project Structure

```text
retail-sales-customer-analytics/
|
|-- data/
|   |-- raw/
|   |-- processed/
|
|-- notebooks/
|   |-- 01_retail_customer_analytics.ipynb
|
|-- powerbi/
|   |-- Report.pbip
|   |-- Report.Report/
|   |-- Report.SemanticModel/
|   |-- Dashboard.pbix
|
|-- retail_final_outputs/
|   |-- final_customer_master_table.csv
|   |-- cluster_scatter_data.csv
|   |-- other analytical outputs
|
|-- sql/
|   |-- SQL.sql
|
|-- reports/
|   |-- dashboard screenshots
|
|-- .gitignore
|-- README.md
```

## Technologies

- Python
- pandas
- NumPy
- scikit-learn
- Jupyter Notebook
- PostgreSQL
- SQL
- Power BI
- DAX
- Power Query
- Git / GitHub

## Reproducibility

The raw Online Retail II dataset is not included in this repository.

Large generated transaction-level outputs and temporary model artifacts are also excluded from version control.

The analytical workflow and project structure are provided so the main processing steps can be reviewed and reproduced from the source notebook and SQL layer.

## Dataset

The project is based on the **Online Retail II** dataset containing UK-based online retail transactions from 2009–2011.

The original dataset should be obtained separately and placed in the appropriate local data directory before reproducing the analysis.

## Notes

This repository contains the final analytical project and Power BI deliverables. Large raw and generated data files are intentionally excluded to keep the repository lightweight and suitable for GitHub.
