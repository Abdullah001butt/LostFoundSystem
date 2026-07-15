/* ============================================================
   Lost & Found Campus System - Database Schema
   SQL Server (T-SQL)
   ============================================================ */

CREATE DATABASE LostFoundSystem;
GO
USE LostFoundSystem;
GO

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE Users (
    UserID          INT IDENTITY(1,1) PRIMARY KEY,
    FullName        VARCHAR(100)    NOT NULL,
    Email           VARCHAR(100)    NOT NULL UNIQUE,
    Phone           VARCHAR(20),
    Role            VARCHAR(20)     NOT NULL DEFAULT 'Student'
                        CHECK (Role IN ('Student', 'Admin')),
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- ITEMS  (single table for both lost & found, distinguished by ItemType)
-- ============================================================
CREATE TABLE Items (
    ItemID          INT IDENTITY(1,1) PRIMARY KEY,
    Title           VARCHAR(100)    NOT NULL,
    Description     VARCHAR(500),
    Category        VARCHAR(50)     NOT NULL,   -- e.g. Electronics, ID Card, Bag, Bottle
    ItemType        VARCHAR(10)     NOT NULL CHECK (ItemType IN ('Lost', 'Found')),
    Location        VARCHAR(150),
    EventDate       DATE            NOT NULL,   -- date lost / date found
    Status          VARCHAR(20)     NOT NULL DEFAULT 'Open'
                        CHECK (Status IN ('Open', 'Matched', 'ClaimPending', 'Claimed', 'Closed')),
    ReportedBy      INT             NOT NULL,
    ReportedAt      DATETIME        NOT NULL DEFAULT GETDATE(),
    ImageURL        VARCHAR(255),
    CONSTRAINT FK_Items_Users FOREIGN KEY (ReportedBy) REFERENCES Users(UserID)
);
GO

-- ============================================================
-- MATCHES  (links a Lost item to a candidate Found item)
-- ============================================================
CREATE TABLE Matches (
    MatchID         INT IDENTITY(1,1) PRIMARY KEY,
    LostItemID      INT             NOT NULL,
    FoundItemID     INT             NOT NULL,
    MatchScore      INT             NULL,       -- simple similarity score 0-100
    Status          VARCHAR(20)     NOT NULL DEFAULT 'Suggested'
                        CHECK (Status IN ('Suggested', 'Confirmed', 'Rejected')),
    MatchedAt       DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Matches_Lost  FOREIGN KEY (LostItemID)  REFERENCES Items(ItemID),
    CONSTRAINT FK_Matches_Found FOREIGN KEY (FoundItemID) REFERENCES Items(ItemID),
    CONSTRAINT UQ_Matches UNIQUE (LostItemID, FoundItemID)
);
GO

-- ============================================================
-- CLAIM REQUESTS
-- ============================================================
CREATE TABLE ClaimRequests (
    ClaimID         INT IDENTITY(1,1) PRIMARY KEY,
    ItemID          INT             NOT NULL,      -- the Found item being claimed
    ClaimantID      INT             NOT NULL,       -- user claiming it
    ProofDetails    VARCHAR(500),
    Status          VARCHAR(20)     NOT NULL DEFAULT 'Pending'
                        CHECK (Status IN ('Pending', 'Approved', 'Rejected')),
    RequestedAt     DATETIME        NOT NULL DEFAULT GETDATE(),
    ReviewedBy      INT             NULL,
    ReviewedAt      DATETIME        NULL,
    CONSTRAINT FK_Claims_Item     FOREIGN KEY (ItemID)     REFERENCES Items(ItemID),
    CONSTRAINT FK_Claims_Claimant FOREIGN KEY (ClaimantID) REFERENCES Users(UserID),
    CONSTRAINT FK_Claims_Reviewer FOREIGN KEY (ReviewedBy) REFERENCES Users(UserID)
);
GO

-- ============================================================
-- AUDIT LOG (populated by triggers)
-- ============================================================
CREATE TABLE AuditLog (
    LogID           INT IDENTITY(1,1) PRIMARY KEY,
    ActionType      VARCHAR(50)     NOT NULL,
    TableName       VARCHAR(50)     NOT NULL,
    RecordID        INT             NOT NULL,
    ActionDetails   VARCHAR(500),
    ActionAt        DATETIME        NOT NULL DEFAULT GETDATE()
);
GO
