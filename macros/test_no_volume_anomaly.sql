{#
    Generic, reusable anomaly-detection test: buckets `model` by day on
    `column_name` and flags any day whose row count deviates from the
    trailing rolling average by more than `stddev_threshold` standard
    deviations. This catches "volume fell off a cliff" / "volume spiked"
    situations that static row-count thresholds can't, without needing a
    separate historical-snapshot table.

    Honest caveat: with only ~3 weeks of seed data and a default 14-day
    lookback, this test is structurally correct but mostly inert here -
    there isn't enough history for the rolling stats to be meaningful yet.
    It's written the way it should run in production, not tuned to fire on
    purpose against the seeds (unlike the sequencing checks in
    models/marts/_marts.yml, which ARE tuned to fire on the seed data).
#}

{% test no_volume_anomaly(model, column_name, lookback_days=14, stddev_threshold=3) %}

with daily_counts as (

    select
        date_trunc('day', {{ column_name }}) as day,
        count(*) as row_count
    from {{ model }}
    where {{ column_name }} is not null
    group by 1

),

stats as (

    select
        day,
        row_count,
        avg(row_count) over (
            order by day
            rows between {{ lookback_days }} preceding and 1 preceding
        ) as rolling_avg,
        stddev(row_count) over (
            order by day
            rows between {{ lookback_days }} preceding and 1 preceding
        ) as rolling_stddev
    from daily_counts

)

select *
from stats
where rolling_stddev is not null
  and rolling_stddev > 0
  and abs(row_count - rolling_avg) > {{ stddev_threshold }} * rolling_stddev

{% endtest %}
