-- models/trips_per_property.sql

WITH stations AS (
  SELECT
    station_id, council_district,
    CASE
      WHEN property_type IN ('parkland', 'sidewalk', 'nonmetered_parking') THEN 'free_parking'
      ELSE property_type
    END AS property_type,
  FROM
    `bigquery-public-data.austin_bikeshare.bikeshare_stations`
  WHERE
    property_type IN (
      'parkland',
      'sidewalk',
      'nonmetered_parking',
      'paid_parking'
    )
),
trips AS (
  SELECT
    start_station_id
  FROM
    `bigquery-public-data.austin_bikeshare.bikeshare_trips`
  WHERE
    start_station_id is NOT NULL
)
SELECT
  stations.property_type,
  COUNT(*) AS trips,
FROM
  trips
  JOIN stations ON trips.start_station_id = stations.station_id
GROUP BY
  stations.property_type
