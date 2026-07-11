###Marketing Data Pipeline — End-to-End Data Engineering Project###

A complete marketing data platform built from scratch, simulating the work of a first data engineer at a mid-sized retailer: from messy ad-platform exports and a transactional database to tested, documented analytics tables and a live dashboard.

📖 Full write-up: What Would You Build as a Retailer's First Data Engineer? Here's My Answer (Medium)

Architecture

┌─────────────────────────────────────────────────┐
                 │                    AIRFLOW (Astro / Docker)      │
                 │   daily @ 09:00 · retries · Cosmos dbt tasks     │
                 └─────────────────────────────────────────────────┘
                       │                │                 
   MySQL (OLTP)        ▼                ▼                 
 ┌──────────────┐   extract        dbt build          Looker Studio
 │ customers    │  ──────────►  ┌───────────────┐    ┌────────────┐
 │ products     │   watermark   │   SNOWFLAKE   │───►│ dashboards │
 │ transactions │   incremental │ BRONZE→SILVER │    │ (Snowflake │
 │ events (2M)  │               │     →GOLD     │    │ connector) │
 │ campaigns    │               └───────────────┘    └────────────┘
 └──────────────┘                dbt tests on every build


Flow: MySQL (source system) → Bronze (raw replica + _loaded_at lineage) → Silver (dbt views: cleaning, standardization, tests) → Gold (dbt tables: department marts) → Looker Studio (direct Snowflake connector).

Stack
<img width="586" height="451" alt="Screenshot 2026-07-11 at 12 52 41" src="https://github.com/user-attachments/assets/e709cac4-7777-4ca6-8cf5-e71eb0ac82be" />

Highlights


1.Naming convention as code. A one-page fill-in template for marketers plus a Python validator (extract_names.py) that rejects non-conformant campaign/adset/ad names with a NamingConventionError instead of guessing. Historical names cleaned once; future names enforced forever.
2.Incremental loading with a gate. The Airflow DAG compares MAX(order_ts) in MySQL vs. bronze and short-circuits the entire run when there's nothing new — new rows are appended, never re-loaded (a ShortCircuitOperator + high-watermark pattern).
3.Data quality as a build step. unique, not_null, relationships, and accepted_range tests run on every dbt build; a failing silver test blocks the gold models that depend on it.
4.Deliberate materialization split. Silver = views (always fresh, zero storage), gold = tables (fast dashboards) — plus a custom generate_schema_name macro so layers land in SILVER/GOLD instead of dbt's default concatenated schemas.
5.Real messy data. Product IDs arriving as floats, free-text campaign names, anonymous sessions, refunds — handled explicitly, not filtered away silently.


