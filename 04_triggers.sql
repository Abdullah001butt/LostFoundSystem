/* ============================================================
   Triggers
   ============================================================ */
USE LostFoundSystem;
GO

-- ------------------------------------------------------------
-- TR1: When a claim request is inserted, mark the item as
--      'ClaimPending' so it's no longer shown as freely available.
-- ------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_ClaimRequest_Insert
ON ClaimRequests
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE i
    SET i.Status = 'ClaimPending'
    FROM Items i
    JOIN inserted ins ON i.ItemID = ins.ItemID;

    INSERT INTO AuditLog (ActionType, TableName, RecordID, ActionDetails)
    SELECT 'INSERT', 'ClaimRequests', ins.ClaimID,
           'Claim request created for ItemID ' + CAST(ins.ItemID AS VARCHAR)
    FROM inserted ins;
END;
GO

-- ------------------------------------------------------------
-- TR2: When a claim is approved, mark the item as 'Claimed' and
--      auto-reject any other pending claims on the same item.
-- ------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_ClaimRequest_Approved
ON ClaimRequests
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Status)
    BEGIN
        -- item becomes Claimed
        UPDATE i
        SET i.Status = 'Claimed'
        FROM Items i
        JOIN inserted ins ON i.ItemID = ins.ItemID
        WHERE ins.Status = 'Approved';

        -- reject other pending claims on the same item
        UPDATE cr
        SET cr.Status = 'Rejected',
            cr.ReviewedAt = GETDATE()
        FROM ClaimRequests cr
        JOIN inserted ins ON cr.ItemID = ins.ItemID
        WHERE ins.Status = 'Approved'
          AND cr.ClaimID <> ins.ClaimID
          AND cr.Status = 'Pending';

        INSERT INTO AuditLog (ActionType, TableName, RecordID, ActionDetails)
        SELECT 'UPDATE', 'ClaimRequests', ins.ClaimID,
               'Claim status changed to ' + ins.Status
        FROM inserted ins;
    END
END;
GO

-- ------------------------------------------------------------
-- TR3: Prevent a user from claiming their own found-item report.
-- ------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_ClaimRequest_PreventSelfClaim
ON ClaimRequests
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted ins
        JOIN Items i ON ins.ItemID = i.ItemID
        WHERE i.ReportedBy = ins.ClaimantID
    )
    BEGIN
        RAISERROR ('You cannot claim an item you reported yourself.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
