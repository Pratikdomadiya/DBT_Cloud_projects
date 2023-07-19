/*
TITLE : RFM model with segmentation history
This example shows how you can build a model with a snapshot of the user attributes at the end of each month. The same could be built for a weekly model with minor adjustments.

*/


WITH payments AS(
    SELECT *
    FROM ref {{'fact_payments'}}
),
months AS(
    SELECT NOW() AS date_month
    UNION ALL
    SELECT DISTINCT date_month AS date_month
    FROM ref {{'dim_calendar'}}
),
payments_with_months AS(
    SELECT  user_id,
            date_month,
            payment_date,
            payment_id,
            payment_amount
    FROM months
        JOIN payments ON payment_date <= date_month 
),
rfm_values AS (
    SELECT  user_id,
            date_month,
            MAX(payment_date) AS max_payment_date,
            date_month - MAX(payment_date) AS recency,
            COUNT(DISTINCT payment_id) AS frequency,
            SUM(payment_amount) AS monetary
    FROM payments_with_months
    GROUP BY user_id, date_month
),
rfm_percentiles AS (
    SELECT  user_id,
            date_month,
            recency,
            frequency,
            monetary,
            PERCENT_RANK() OVER (ORDER BY recency DESC) AS recency_percentile,
            PERCENT_RANK() OVER (ORDER BY frequency ASC) AS frequency_percentile,
            PERCENT_RANK() OVER (ORDER BY monetary ASC) AS monetary_percentile
    FROM rfm_values
),
rfm_scores AS(
    SELECT  *,
            CASE
                WHEN recency_percentile >= 0.8 THEN 5
                WHEN recency_percentile >= 0.6 THEN 4
                WHEN recency_percentile >= 0.4 THEN 3
                WHEN recency_percentile >= 0.2 THEN 2
                ELSE 1
                END AS recency_score,
            CASE
                WHEN frequency_percentile >= 0.8 THEN 5
                WHEN frequency_percentile >= 0.6 THEN 4
                WHEN frequency_percentile >= 0.4 THEN 3
                WHEN frequency_percentile >= 0.2 THEN 2
                ELSE 1
                END AS frequency_score,
            CASE
                WHEN monetary_percentile >= 0.8 THEN 5
                WHEN monetary_percentile >= 0.6 THEN 4
                WHEN monetary_percentile >= 0.4 THEN 3
                WHEN monetary_percentile >= 0.2 THEN 2
                ELSE 1
                END AS monetary_score
    FROM rfm_percentiles
),
rfm_segment AS(
SELECT *,
        CASE
            WHEN recency_score <= 2
                AND frequency_score <= 2 THEN 'Hibernating'
            WHEN recency_score <= 2
                AND frequency_score <= 4 THEN 'At Risk'
            WHEN recency_score <= 2
                AND frequency_score <= 5 THEN 'Cannot Lose Them'
            WHEN recency_score <= 3
                AND frequency_score <= 2 THEN 'About to Sleep'
            WHEN recency_score <= 3
                AND frequency_score <= 3 THEN 'Need Attention'
            WHEN recency_score <= 4
                AND frequency_score <= 1 THEN 'Promising'
            WHEN recency_score <= 4
                AND frequency_score <= 3 THEN 'Potential Loyalists'
            WHEN recency_score <= 4
                AND frequency_score <= 5 THEN 'Loyal Customers'
            WHEN recency_score <= 5
                AND frequency_score <= 1 THEN 'New Customers'
            WHEN recency_score <= 5
                AND frequency_score <= 3 THEN 'Potential Loyalists'
            ELSE 'Champions'
        END AS rfm_segment
FROM  rfm_scores
)
SELECT *
FROM rfm_segment

/*
https://docs.getdbt.com/blog/historical-user-segmentation


*/
