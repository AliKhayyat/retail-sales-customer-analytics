SELECT current_database();

CREATE SCHEMA retail;

CREATE TABLE retail.customer_master (
    customer_id BIGINT PRIMARY KEY,
    recency DOUBLE PRECISION,
    frequency BIGINT,
    monetary NUMERIC(14, 2),
    average_interpurchase_days DOUBLE PRECISION,
    interpurchase_interval_count BIGINT,
    segment TEXT,
    timing_history_group TEXT,
    r_score INTEGER,
    f_score INTEGER,
    m_score INTEGER,
    rfm_score TEXT,
    purchase_timing_cluster INTEGER,
    rfm_cluster INTEGER,
    overdue_ratio DOUBLE PRECISION,
    overdue_status TEXT
);

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_ids,
    COUNT(*) FILTER (WHERE rfm_cluster IS NULL) AS missing_rfm_cluster,
    COUNT(*) FILTER (WHERE purchase_timing_cluster IS NULL) AS missing_timing_cluster
FROM retail.customer_master;

SELECT
    COUNT(*) AS total_customers,
    COUNT(r_score) AS customers_with_r_score,
    COUNT(f_score) AS customers_with_f_score,
    COUNT(m_score) AS customers_with_m_score,
    COUNT(rfm_score) AS customers_with_rfm_score,
    COUNT(rfm_cluster) AS customers_with_rfm_cluster,
    COUNT(purchase_timing_cluster) AS customers_with_timing_cluster
FROM retail.customer_master;

SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage,
    ROUND(SUM(monetary), 2) AS total_monetary,
    ROUND(AVG(monetary), 2) AS average_monetary,
    ROUND(
        SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER (),
        2
    ) AS monetary_percentage
FROM retail.customer_master
GROUP BY segment
ORDER BY total_monetary DESC;

SELECT
    rfm_cluster,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency)::numeric, 2) AS avg_recency,
    ROUND(AVG(frequency)::numeric, 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(SUM(monetary), 2) AS total_monetary,
    ROUND(
        SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER (),
        2
    ) AS monetary_percentage
FROM retail.customer_master
GROUP BY rfm_cluster
ORDER BY rfm_cluster;

SELECT
    rfm_cluster,
    overdue_status,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY rfm_cluster),
        2
    ) AS percentage_within_cluster,
    ROUND(AVG(recency)::numeric, 2) AS avg_recency,
    ROUND(AVG(overdue_ratio)::numeric, 2) AS avg_overdue_ratio,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM retail.customer_master
GROUP BY
    rfm_cluster,
    overdue_status
ORDER BY
    rfm_cluster,
    customer_count DESC;

	SELECT
    rfm_cluster,
    COALESCE(overdue_status, 'Insufficient Timing History') AS timing_status,
    COUNT(*) AS customer_count,
    ROUND(SUM(monetary), 2) AS total_monetary,
    ROUND(
        SUM(monetary) * 100.0 /
        SUM(SUM(monetary)) OVER (PARTITION BY rfm_cluster),
        2
    ) AS monetary_percentage_within_cluster
FROM retail.customer_master
GROUP BY
    rfm_cluster,
    overdue_status
ORDER BY
    rfm_cluster,
    total_monetary DESC;

	SELECT
    purchase_timing_cluster,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency)::numeric, 2) AS avg_recency,
    ROUND(AVG(average_interpurchase_days)::numeric, 2) AS avg_interpurchase_days,
    ROUND(AVG(overdue_ratio)::numeric, 2) AS avg_overdue_ratio,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(SUM(monetary), 2) AS total_monetary,
    ROUND(
        SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER (),
        2
    ) AS monetary_percentage
FROM retail.customer_master
WHERE purchase_timing_cluster IS NOT NULL
GROUP BY purchase_timing_cluster
ORDER BY purchase_timing_cluster;

SELECT
    purchase_timing_cluster,
    overdue_status,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY purchase_timing_cluster),
        2
    ) AS percentage_within_cluster,
    ROUND(AVG(recency)::numeric, 2) AS avg_recency,
    ROUND(AVG(overdue_ratio)::numeric, 2) AS avg_overdue_ratio,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM retail.customer_master
WHERE purchase_timing_cluster IS NOT NULL
GROUP BY
    purchase_timing_cluster,
    overdue_status
ORDER BY
    purchase_timing_cluster,
    customer_count DESC;

	SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'retail'
  AND table_name = 'customer_master'
ORDER BY ordinal_position;

CREATE TABLE retail.customer_master_backup AS
SELECT *
FROM retail.customer_master;

ALTER TABLE retail.customer_master
ADD COLUMN customer_value_cluster INTEGER,
ADD COLUMN purchase_behavior_cluster INTEGER;

SELECT
    customer_value_cluster,
    COUNT(*) AS customer_count,
    ROUND(AVG(frequency)::numeric, 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(AVG(monetary / NULLIF(frequency, 0)), 2) AS avg_aov,
    ROUND(SUM(monetary), 2) AS total_monetary,
    ROUND(
        SUM(monetary) * 100.0 /
        SUM(SUM(monetary)) OVER (),
        2
    ) AS monetary_percentage
FROM retail.customer_master
WHERE customer_value_cluster IS NOT NULL
GROUP BY customer_value_cluster
ORDER BY customer_value_cluster;

SELECT
    purchase_behavior_cluster,
    COUNT(*) AS customer_count,
    ROUND(AVG(frequency)::numeric, 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(AVG(monetary / NULLIF(frequency, 0)), 2) AS avg_aov,
    ROUND(AVG(average_interpurchase_days)::numeric, 2) AS avg_interpurchase_days,
    ROUND(SUM(monetary), 2) AS total_monetary,
    ROUND(
        SUM(monetary) * 100.0 /
        SUM(SUM(monetary)) OVER (),
        2
    ) AS monetary_percentage
FROM retail.customer_master
WHERE purchase_behavior_cluster IS NOT NULL
GROUP BY purchase_behavior_cluster
ORDER BY purchase_behavior_cluster;

SELECT
    customer_value_cluster,
    purchase_behavior_cluster,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY customer_value_cluster),
        2
    ) AS percentage_within_value_cluster,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM retail.customer_master
WHERE customer_value_cluster IS NOT NULL
  AND purchase_behavior_cluster IS NOT NULL
GROUP BY
    customer_value_cluster,
    purchase_behavior_cluster
ORDER BY
    customer_value_cluster,
    purchase_behavior_cluster;


	SELECT
    customer_value_cluster,
    rfm_cluster,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY customer_value_cluster
        ),
        2
    ) AS percentage_within_value_cluster,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM retail.customer_master
WHERE customer_value_cluster IS NOT NULL
GROUP BY
    customer_value_cluster,
    rfm_cluster
ORDER BY
    customer_value_cluster,
    rfm_cluster;

	SELECT
    purchase_behavior_cluster,
    rfm_cluster,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY purchase_behavior_cluster
        ),
        2
    ) AS percentage_within_behavior_cluster,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM retail.customer_master
WHERE purchase_behavior_cluster IS NOT NULL
GROUP BY
    purchase_behavior_cluster,
    rfm_cluster
ORDER BY
    purchase_behavior_cluster,
    rfm_cluster;

	SELECT
    purchase_behavior_cluster,
    overdue_status,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY purchase_behavior_cluster
        ),
        2
    ) AS percentage_within_behavior_cluster,
    ROUND(AVG(recency)::numeric, 2) AS avg_recency,
    ROUND(AVG(overdue_ratio)::numeric, 2) AS avg_overdue_ratio,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM retail.customer_master
WHERE purchase_behavior_cluster IS NOT NULL
GROUP BY
    purchase_behavior_cluster,
    overdue_status
ORDER BY
    purchase_behavior_cluster,
    overdue_status;

	SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE customer_value_cluster NOT IN (0, 1, 2)
    ) AS invalid_customer_value_clusters,
    COUNT(*) FILTER (
        WHERE purchase_behavior_cluster NOT IN (0, 1, 2)
    ) AS invalid_purchase_behavior_clusters,
    COUNT(*) FILTER (
        WHERE customer_value_cluster IS NULL
          AND purchase_behavior_cluster IS NULL
    ) AS missing_both_clusters,
    COUNT(*) FILTER (
        WHERE customer_value_cluster IS NULL
          AND purchase_behavior_cluster IS NOT NULL
    ) AS missing_value_only,
    COUNT(*) FILTER (
        WHERE customer_value_cluster IS NOT NULL
          AND purchase_behavior_cluster IS NULL
    ) AS missing_behavior_only
FROM retail.customer_master;

SELECT
    customer_value_cluster,
    overdue_status,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY customer_value_cluster
        ),
        2
    ) AS percentage_within_value_cluster,
    ROUND(AVG(recency)::numeric, 2) AS avg_recency,
    ROUND(AVG(overdue_ratio)::numeric, 2) AS avg_overdue_ratio,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM retail.customer_master
WHERE customer_value_cluster IS NOT NULL
GROUP BY
    customer_value_cluster,
    overdue_status
ORDER BY
    customer_value_cluster,
    overdue_status;

	SELECT
    purchase_timing_cluster,
    customer_value_cluster,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY purchase_timing_cluster
        ),
        2
    ) AS percentage_within_timing_cluster,
    ROUND(AVG(recency)::numeric, 2) AS avg_recency,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM retail.customer_master
WHERE purchase_timing_cluster IS NOT NULL
  AND customer_value_cluster IS NOT NULL
GROUP BY
    purchase_timing_cluster,
    customer_value_cluster
ORDER BY
    purchase_timing_cluster,
    customer_value_cluster;

	SELECT
    purchase_timing_cluster,
    rfm_cluster,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY purchase_timing_cluster
        ),
        2
    ) AS percentage_within_timing_cluster,
    ROUND(AVG(recency)::numeric, 2) AS avg_recency,
    ROUND(AVG(frequency)::numeric, 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM retail.customer_master
WHERE purchase_timing_cluster IS NOT NULL
GROUP BY
    purchase_timing_cluster,
    rfm_cluster
ORDER BY
    purchase_timing_cluster,
    rfm_cluster;

	SELECT
    purchase_timing_cluster,
    purchase_behavior_cluster,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY purchase_timing_cluster
        ),
        2
    ) AS percentage_within_timing_cluster,
    ROUND(AVG(recency)::numeric, 2) AS avg_recency,
    ROUND(AVG(frequency)::numeric, 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM retail.customer_master
WHERE purchase_timing_cluster IS NOT NULL
  AND purchase_behavior_cluster IS NOT NULL
GROUP BY
    purchase_timing_cluster,
    purchase_behavior_cluster
ORDER BY
    purchase_timing_cluster,
    purchase_behavior_cluster;

	SELECT
    rfm_cluster,
    customer_value_cluster,
    purchase_timing_cluster,
    purchase_behavior_cluster,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency)::numeric, 2) AS avg_recency,
    ROUND(AVG(frequency)::numeric, 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM retail.customer_master
WHERE customer_value_cluster IS NOT NULL
  AND purchase_timing_cluster IS NOT NULL
  AND purchase_behavior_cluster IS NOT NULL
GROUP BY
    rfm_cluster,
    customer_value_cluster,
    purchase_timing_cluster,
    purchase_behavior_cluster
ORDER BY customer_count DESC;

SELECT
    COUNT(*) AS total_customers,
    COUNT(rfm_cluster) AS rfm_clustered,
    COUNT(customer_value_cluster) AS customer_value_clustered,
    COUNT(purchase_timing_cluster) AS purchase_timing_clustered,
    COUNT(purchase_behavior_cluster) AS purchase_behavior_clustered,
    COUNT(*) FILTER (
        WHERE rfm_cluster IS NOT NULL
          AND customer_value_cluster IS NOT NULL
          AND purchase_timing_cluster IS NOT NULL
          AND purchase_behavior_cluster IS NOT NULL
    ) AS all_four_clusters_available,
    COUNT(*) FILTER (
        WHERE rfm_cluster IS NULL
           OR customer_value_cluster IS NULL
           OR purchase_timing_cluster IS NULL
           OR purchase_behavior_cluster IS NULL
    ) AS incomplete_cluster_records
FROM retail.customer_master;

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE recency IS NULL) AS null_recency,
    COUNT(*) FILTER (WHERE frequency IS NULL) AS null_frequency,
    COUNT(*) FILTER (WHERE monetary IS NULL) AS null_monetary,
    COUNT(*) FILTER (WHERE average_interpurchase_days IS NULL) AS null_interpurchase_days,
    COUNT(*) FILTER (WHERE overdue_ratio IS NULL) AS null_overdue_ratio,
    COUNT(*) FILTER (WHERE frequency <= 0) AS non_positive_frequency,
    COUNT(*) FILTER (WHERE recency < 0) AS negative_recency,
    COUNT(*) FILTER (WHERE monetary < 0) AS negative_monetary,
    ROUND(MIN(recency)::numeric, 2) AS min_recency,
    ROUND(MAX(recency)::numeric, 2) AS max_recency,
    ROUND(MIN(monetary), 2) AS min_monetary,
    ROUND(MAX(monetary), 2) AS max_monetary
FROM retail.customer_master;

SELECT
    COUNT(*) AS matched_customers,
    COUNT(*) FILTER (
        WHERE main.customer_id IS DISTINCT FROM backup.customer_id
           OR main.recency IS DISTINCT FROM backup.recency
           OR main.frequency IS DISTINCT FROM backup.frequency
           OR main.monetary IS DISTINCT FROM backup.monetary
           OR main.average_interpurchase_days IS DISTINCT FROM backup.average_interpurchase_days
           OR main.interpurchase_interval_count IS DISTINCT FROM backup.interpurchase_interval_count
           OR main.segment IS DISTINCT FROM backup.segment
           OR main.timing_history_group IS DISTINCT FROM backup.timing_history_group
           OR main.r_score IS DISTINCT FROM backup.r_score
           OR main.f_score IS DISTINCT FROM backup.f_score
           OR main.m_score IS DISTINCT FROM backup.m_score
           OR main.rfm_score IS DISTINCT FROM backup.rfm_score
           OR main.purchase_timing_cluster IS DISTINCT FROM backup.purchase_timing_cluster
           OR main.rfm_cluster IS DISTINCT FROM backup.rfm_cluster
           OR main.overdue_ratio IS DISTINCT FROM backup.overdue_ratio
           OR main.overdue_status IS DISTINCT FROM backup.overdue_status
    ) AS changed_original_records
FROM retail.customer_master AS main
JOIN retail.customer_master_backup AS backup
    ON main.customer_id = backup.customer_id;

	SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'retail'
  AND table_name = 'customer_master'
ORDER BY ordinal_position;

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(customer_value_cluster) AS value_clustered,
    COUNT(purchase_timing_cluster) AS timing_clustered,
    COUNT(purchase_behavior_cluster) AS behavior_clustered
FROM retail.customer_master;