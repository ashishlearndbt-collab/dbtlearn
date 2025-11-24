{% macro log_model_run(status, inserted=0, updated=0, deleted=0, message="") %}

{% set run_type = "full-refresh" if flags.FULL_REFRESH else "incremental" %}

insert into ashish.audit.dbt_run_log (
    run_id,
    model_name,
    model_unique_id,
    tag,
    run_type,
    status,
    started_at,
    finished_at,

    inserted_rows,
    updated_rows,
    deleted_rows,
    message
)
select
    '{{ run_started_at }}' as run_id,
    '{{ model.name }}' as model_name,
    '{{ model.unique_id }}' as model_unique_id,
    '{{ model.tags | join(",") }}' as tag,
    '{{ run_type }}' as run_type,
    '{{ status }}' as status,
    '{{ run_started_at }}' as started_at,
    current_timestamp() as finished_at,

    {{ inserted }} as inserted_rows,
    {{ updated }} as updated_rows,
    {{ deleted }} as deleted_rows,
    '{{ message }}' as message

{% endmacro %}