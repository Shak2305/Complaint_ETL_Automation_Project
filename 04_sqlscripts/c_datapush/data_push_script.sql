------------------------------------------------------------
-- DAILY LOAD SCRIPT: FACT_COMPLAINTS
-- Purpose:
--  • Replace truncate+insert with date-driven incremental load
--  • Only delete & reload the specific processing date
--  • Handle Excel serial dates (e.g., 45586 → 2024-10-01)
--  • Deduplicate staging rows (latest row wins)
--  • Load cleaned data into RAW table
--  • Output last 10 daily loads
------------------------------------------------------------


------------------------------------------------------------
-- STEP 0 — SET PROCESS DATE (DEFAULT = YESTERDAY)
------------------------------------------------------------
SET PROCESS_DATE = DATEADD('day', -1, CURRENT_DATE());

-- You may override manually for testing:
-- SET PROCESS_DATE = '2024-10-15';


------------------------------------------------------------
-- STEP 1 — REMOVE EXISTING STAGING DATA FOR PROCESS DATE
-- (Prevents duplicate loads for the same day)
------------------------------------------------------------
DELETE FROM stg_fact_complaints
WHERE TRY_TO_DATE(
        TO_DATE('1899-12-30') + TRY_TO_NUMBER(LOGGED_ON)
    ) = $PROCESS_DATE;


------------------------------------------------------------
-- STEP 2 — LOAD NEW CSV DATA
-- In real Snowflake pipelines this is done by COPY INTO.
-- For portfolio purposes this is assumed to be already loaded.
------------------------------------------------------------
-- Example (COMMENTED OUT):
-- COPY INTO stg_fact_complaints
-- FROM @complaints_stage
-- PATTERN = '.*fact_complaints_.*\.csv';


------------------------------------------------------------
-- STEP 3 — ADD SYNTHETIC LOAD TIMESTAMP
-- This creates a unique LOAD_TS value for deduplication.
------------------------------------------------------------
CREATE OR REPLACE TEMP TABLE stg_with_ts AS
SELECT
    *,
    CURRENT_TIMESTAMP() AS LOAD_TS
FROM stg_fact_complaints;


------------------------------------------------------------
-- STEP 4 — DEDUPLICATE STAGING DATA
-- Pick the most recent row per CASE_ID (latest LOAD_TS wins)
------------------------------------------------------------
CREATE OR REPLACE TEMP TABLE stg_clean AS
SELECT *
FROM stg_with_ts
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY CASE_ID
    ORDER BY LOAD_TS DESC
) = 1;


------------------------------------------------------------
-- STEP 5 — DELETE EXISTING RAW ROWS FOR PROCESS DATE
------------------------------------------------------------
DELETE FROM raw_tbl_fact_complaints
WHERE LOGGED_ON = $PROCESS_DATE;


------------------------------------------------------------
-- STEP 6 — INSERT CLEANED DATA INTO RAW
-- Includes:
--  • Excel serial → DATE conversion
--  • Numeric sanitisation (TRY_TO_NUMBER)
--  • Boolean casting
--  • Correct LOAD_DATE
------------------------------------------------------------
INSERT INTO raw_tbl_fact_complaints (
    CASE_ID,
    CLIENT_ID,
    LOGGED_ON,
    CLOSED_ON,
    AGE_DAYS,
    OPEN_DAYS,
    YEAR,
    MONTH,
    QUARTER,
    WEEK,
    CASE_STATUS,
    PRODUCT_LINE,
    INTAKE_SOURCE,
    CHANNEL,
    RISK_FLAG,
    REG_TYPE,
    DECISION_STATUS,
    OVERALL_OUTCOME,
    REOPEN_COUNT,
    ACK_SLA_MET,
    REVIEW_SLA_MET,
    FINAL_SLA_MET,
    VULNERABLE_FLAG,
    FIRST_CONTACT_RESOLVED,
    BOUNCE_FLAG,
    GOODWILL_AMOUNT,
    COMP_AMOUNT,
    ADJUSTMENT_AMOUNT,
    TOTAL_AMOUNT,
    EXTERNAL_TOTAL_COST,
    OWNER_ID,
    LOGGED_BY_ID,
    CLOSED_BY_ID,
    LOAD_DATE
)
SELECT
    CASE_ID,
    CLIENT_ID,

    -- Convert Excel serial → real DATE
    TRY_TO_DATE(TO_DATE('1899-12-30') + TRY_TO_NUMBER(LOGGED_ON)) AS LOGGED_ON,
    TRY_TO_DATE(TO_DATE('1899-12-30') + TRY_TO_NUMBER(CLOSED_ON)) AS CLOSED_ON,

    TRY_TO_NUMBER(AGE_DAYS),
    TRY_TO_NUMBER(OPEN_DAYS),
    TRY_TO_NUMBER(YEAR),
    TRY_TO_NUMBER(MONTH),
    TRY_TO_NUMBER(QUARTER),
    TRY_TO_NUMBER(WEEK),
    CASE_STATUS,
    PRODUCT_LINE,
    INTAKE_SOURCE,
    CHANNEL,

    RISK_FLAG,
    REG_TYPE,
    DECISION_STATUS,
    OVERALL_OUTCOME,
    TRY_TO_NUMBER(REOPEN_COUNT),

    ACK_SLA_MET,
    REVIEW_SLA_MET,
    FINAL_SLA_MET,
    VULNERABLE_FLAG,
    FIRST_CONTACT_RESOLVED,
    BOUNCE_FLAG,

    TRY_TO_NUMBER(GOODWILL_AMOUNT),
    TRY_TO_NUMBER(COMP_AMOUNT),
    TRY_TO_NUMBER(ADJUSTMENT_AMOUNT),
    TRY_TO_NUMBER(TOTAL_AMOUNT),
    TRY_TO_NUMBER(EXTERNAL_TOTAL_COST),

    OWNER_ID,
    LOGGED_BY_ID,
    CLOSED_BY_ID,

    CURRENT_DATE() AS LOAD_DATE

FROM stg_clean;


------------------------------------------------------------
-- STEP 7 — DAILY LOAD SUMMARY (LAST 10 DAYS)
------------------------------------------------------------
SELECT 
    LOGGED_ON,
    COUNT(*) AS ROWS_LOADED
FROM raw_tbl_fact_complaints
WHERE LOGGED_ON >= DATEADD('day', -10, CURRENT_DATE())
GROUP BY LOGGED_ON
ORDER BY LOGGED_ON DESC;
