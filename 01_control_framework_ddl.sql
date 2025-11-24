-- PURPOSE: Creates Star Schema DDL (Gold Layer) the destination Fact and Dimension tables for the final aggregated data.

-- 1. Create Dimension Tables (Lookups)

-- Dim_Exchange: Stores unique exchange names.
IF OBJECT_ID('dbo.Dim_Exchange') IS NOT NULL DROP TABLE dbo.Dim_Exchange;
CREATE TABLE dbo.Dim_Exchange (
    ExchangeID INT IDENTITY(1,1) PRIMARY KEY,
    ExchangeName NVARCHAR(50) UNIQUE NOT NULL,
    LoadedDate DATETIME DEFAULT GETDATE()
);

-- Dim_CurrencyPair: Stores unique currency pairs (e.g., BTC-USD).
IF OBJECT_ID('dbo.Dim_CurrencyPair') IS NOT NULL DROP TABLE dbo.Dim_CurrencyPair;
CREATE TABLE dbo.Dim_CurrencyPair (
    PairID INT IDENTITY(1,1) PRIMARY KEY,
    PairName NVARCHAR(50) UNIQUE NOT NULL,
    BaseCurrency NVARCHAR(10),
    QuoteCurrency NVARCHAR(10),
    LoadedDate DATETIME DEFAULT GETDATE()
);

-- 2. Create Fact Table (Measurements)

-- Fact_Daily_Market: Stores daily aggregated trading metrics.
-- Has Foreign Keys linking back to the Dimension tables.
IF OBJECT_ID('dbo.Fact_Daily_Market') IS NOT NULL DROP TABLE dbo.Fact_Daily_Market;
CREATE TABLE dbo.Fact_Daily_Market (
    FactID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TradeDate DATE NOT NULL,
    ExchangeID INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Exchange(ExchangeID),
    PairID INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_CurrencyPair(PairID),
    TotalVolume DECIMAL(18, 8),
    TotalValueUSD DECIMAL(18, 8),
    VWAP DECIMAL(18, 8),       -- Volume Weighted Average Price
    TradeCount INT,
    LoadedDate DATETIME DEFAULT GETDATE()
);
GO

PRINT '✅ Star Schema (Fact & Dimensions) Created Successfully';