/* ============================================================
   Demo Script - run after 01-05 to show everything working
   ============================================================ */
USE LostFoundSystem;
GO

-- Run the auto-matcher
EXEC sp_MatchItems;
GO

SELECT * FROM Matches;
GO

-- A student (UserID 2) claims the found wallet reported by UserID 4 (ItemID 4)
INSERT INTO ClaimRequests (ItemID, ClaimantID, ProofDetails)
VALUES (4, 2, 'It has my student ID card and a red bookmark inside');
GO

-- trigger trg_ClaimRequest_Insert should have flipped Items.Status to 'ClaimPending'
SELECT ItemID, Title, Status FROM Items WHERE ItemID = 4;
GO

-- Admin (UserID 5) approves the claim via the procedure
EXEC sp_ReviewClaim @ClaimID = 1, @AdminID = 5, @Decision = 'Approved';
GO

-- trigger trg_ClaimRequest_Approved should have flipped Items.Status to 'Claimed'
SELECT ItemID, Title, Status FROM Items WHERE ItemID = 4;
SELECT * FROM ClaimRequests;
GO

-- Rejected-claim scenario: a student (UserID 3) claims the found bottle
-- reported by UserID 2 (ItemID 6)
INSERT INTO ClaimRequests (ItemID, ClaimantID, ProofDetails)
VALUES (6, 3, 'Steel bottle with a dent near the base and my initials scratched on it');
GO

SELECT ItemID, Title, Status FROM Items WHERE ItemID = 6;
GO

EXEC sp_ReviewClaim @ClaimID = 2, @AdminID = 5, @Decision = 'Rejected';
GO

-- item should revert from ClaimPending back to Open
SELECT ItemID, Title, Status FROM Items WHERE ItemID = 6;
GO

-- confirms sp_ReviewClaim now refuses to re-review a non-Pending claim (raises an error)
EXEC sp_ReviewClaim @ClaimID = 2, @AdminID = 5, @Decision = 'Approved';
GO

-- Self-claim prevention: UserID 4 reported ItemID 5, attempts to claim it themselves
-- Expected to fail: trigger raises an error and rolls back the insert
INSERT INTO ClaimRequests (ItemID, ClaimantID, ProofDetails)
VALUES (5, 4, 'trying to claim my own report');
GO

SELECT * FROM ClaimRequests WHERE ItemID = 5;
GO
-- Try to claim your own reported item (should fail via trg_ClaimRequest_PreventSelfClaim)
-- UserID 4 reported ItemID 5 (Phone Found) -- attempt self-claim:
-- INSERT INTO ClaimRequests (ItemID, ClaimantID, ProofDetails)
-- VALUES (5, 4, 'trying to claim my own report');

-- View a user's report history via procedure
EXEC sp_GetUserReports @UserID = 1;
GO

-- Audit trail
SELECT * FROM AuditLog ORDER BY ActionAt DESC;
GO
