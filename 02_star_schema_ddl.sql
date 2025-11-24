
-- PURPOSE: Creates the schema and tables for tracking pipeline execution, status, and logs.

-- 1. Create Schema for ETL Operations
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ETL')
    EXEC('CREATE SCHEMA ETL');
GO

-- 2. MASTER TABLE: PipelineControl
-- Defines the pipeline settings, current state, and watermarks.
IF OBJECT_ID('ETL.PipelineControl') IS NOT NULL DROP TABLE ETL.PipelineControl;
CREATE TABLE ETL.PipelineControl (
    PipelineID INT IDENTITY(1,1) PRIMARY KEY,
    PipelineName VARCHAR(100) NOT NULL UNIQUE, -- e.g., 'PL_EndToEnd_Crypto_Load'
    SourceSystem VARCHAR(50),
    WatermarkDate DATETIME NULL,               -- The "Business Date" of the last successful run
    CurrentRunID BIGINT NULL,                  -- Links to the currently running instance
    LastRunStatus VARCHAR(20) DEFAULT 'IDLE',  -- IDLE, RUNNING, SUCCESS, FAILED
    SLA_Threshold_Mins INT DEFAULT 60,         -- Alert if run takes > 60 mins
    LastSuccessTime DATETIME NULL
);

-- 3. HEADER TABLE: PipelineRunLog
-- Captures the start/end execution details of the WHOLE pipeline run.
IF OBJECT_ID('ETL.PipelineRunLog') IS NOT NULL DROP TABLE ETL.PipelineRunLog;
CREATE TABLE ETL.PipelineRunLog (
    RunID BIGINT IDENTITY(1,1) PRIMARY KEY,
    PipelineID INT FOREIGN KEY REFERENCES ETL.PipelineControl(PipelineID),
    ADF_RunID VARCHAR(50),                     -- The GUID from Data Factory
    StartTime DATETIME DEFAULT GETDATE(),
    EndTime DATETIME NULL,
    Status VARCHAR(20) DEFAULT 'RUNNING',      -- RUNNING, SUCCESS, FAILED
    TotalRecordsProcessed BIGINT DEFAULT 0,
    ErrorMessage NVARCHAR(MAX) NULL
);

-- 4. DETAIL TABLE: TaskLog
-- Captures execution details for individual steps (Bronze, Silver, Gold).
IF OBJECT_ID('ETL.TaskLog') IS NOT NULL DROP TABLE ETL.TaskLog;
CREATE TABLE ETL.TaskLog (
    TaskID BIGINT IDENTITY(1,1) PRIMARY KEY,
    RunID BIGINT FOREIGN KEY REFERENCES ETL.PipelineRunLog(RunID),
    TaskName VARCHAR(50),                      -- e.g., 'Bronze_Ingestion', 'Gold_Aggregation'
    StartTime DATETIME DEFAULT GETDATE(),
    EndTime DATETIME NULL,
    Status VARCHAR(20) DEFAULT 'RUNNING',
    TargetTable VARCHAR(100) NULL,             -- e.g., 'dbo.Fact_Daily_Market'
    RecordsAffected INT NULL
);
GO

PRINT '✅ Enterprise Control & Logging Framework Created Successfully';

-- ==================================================
-- SEED DATA (Run once to initialize the pipeline)
-- ==================================================
INSERT INTO ETL.PipelineControl (PipelineName, SourceSystem, WatermarkDate, SLA_Threshold_Mins)
VALUES ('PL_EndToEnd_Crypto_Load', 'Blob_LandingZone', '1900-01-01', 30);

PRINT '✅ Pipeline Control Table Seeded with ID 1';