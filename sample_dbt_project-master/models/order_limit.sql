/*
Custom generic tests:

Test : order limit not exceed to 500
NOTE : To add this test into production , add configuration in schema.yaml file.

*/






{% test order_limit(model, column_name) %}

with validation as (
    select
        {{ column_name }} as limit_field
    from {{ model }}
),

validation_errors as (
    select
        limit_field
    from validation
    where limit_field > 500
)

select *
from validation_errors

{% endtest %}
