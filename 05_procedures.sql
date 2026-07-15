/* ============================================================
   Stored Procedures
   ============================================================ */
USE LostFoundSystem;
GO

-- ------------------------------------------------------------
-- SP1: Report a new lost or found item
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_ReportItem
    @Title       VARCHAR(100),
    @Description VARCHAR(500),
    @Category    VARCHAR(50),
    @ItemType    VARCHAR(10),
    @Location    VARCHAR(150),
    @EventDate   DATE,
    @ReportedBy  INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Items (Title, Description, Category, ItemType, Location, EventDate, ReportedBy)
    VALUES (@Title, @Description, @Category, @ItemType, @Location, @EventDate, @ReportedBy);

    SELECT SCOPE_IDENTITY() AS NewItemID;
END;
GO

-- ------------------------------------------------------------
-- SP2: Auto-match Lost items to Found items
--      (same category + same location, found date >= lost date,
--       within 7 days) that don't already have a suggested match.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_MatchItems
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Matches (LostItemID, FoundItemID, MatchScore, Status)
    SELECT l.ItemID, f.ItemID,
           CASE WHEN l.Location = f.Location THEN 80 ELSE 50 END AS MatchScore,
           'Suggested'
    FROM Items l
    JOIN Items f
        ON l.Category = f.Category
       AND l.ItemType = 'Lost'
       AND f.ItemType = 'Found'
       AND f.EventDate BETWEEN l.EventDate AND DATEADD(DAY, 7, l.EventDate)
    WHERE l.Status = 'Open'
      AND f.Status = 'Open'
      AND NOT EXISTS (
          SELECT 1 FROM Matches m
          WHERE m.LostItemID = l.ItemID AND m.FoundItemID = f.ItemID
      );

    UPDATE Items
    SET Status = 'Matched'
    WHERE ItemID IN (SELECT LostItemID FROM Matches WHERE Status = 'Suggested')
       OR ItemID IN (SELECT FoundItemID FROM Matches WHERE Status = 'Suggested');
END;
GO

-- ------------------------------------------------------------
-- SP3: Admin approves or rejects a claim (single entry point,
--      wraps the trigger-driven side effects in a transaction)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_ReviewClaim
    @ClaimID   INT,
    @AdminID   INT,
    @Decision  VARCHAR(20)   -- 'Approved' or 'Rejected'
AS
BEGIN
    SET NOCOUNT ON;

    IF @Decision NOT IN ('Approved', 'Rejected')
    BEGIN
        RAISERROR ('Decision must be Approved or Rejected.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

    UPDATE ClaimRequests
    SET Status = @Decision,
        ReviewedBy = @AdminID,
        ReviewedAt = GETDATE()
    WHERE ClaimID = @ClaimID;

    COMMIT TRANSACTION;
END;
GO

-- ------------------------------------------------------------
-- SP4: Get all reports (lost + found) submitted by a given user
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_GetUserReports
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ItemID, Title, Category, ItemType, Location, EventDate, Status
    FROM Items
    WHERE ReportedBy = @UserID
    ORDER BY ReportedAt DESC;
END;
GO
