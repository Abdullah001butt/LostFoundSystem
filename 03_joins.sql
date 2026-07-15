/* ============================================================
   JOIN Queries
   ============================================================ */
USE LostFoundSystem;
GO

-- 1. All lost items with reporter details
SELECT i.ItemID, i.Title, i.Category, i.Location, i.EventDate,
       u.FullName AS ReportedBy, u.Email
FROM Items i
JOIN Users u ON i.ReportedBy = u.UserID
WHERE i.ItemType = 'Lost';
GO

-- 2. All suggested matches with both lost & found item details
SELECT m.MatchID,
       li.Title AS LostItemTitle, li.Location AS LostLocation,
       fi.Title AS FoundItemTitle, fi.Location AS FoundLocation,
       m.MatchScore, m.Status
FROM Matches m
JOIN Items li ON m.LostItemID  = li.ItemID
JOIN Items fi ON m.FoundItemID = fi.ItemID;
GO

-- 3. Claim requests with item and claimant details
SELECT c.ClaimID, i.Title AS ItemTitle, i.Category,
       u.FullName AS Claimant, u.Email,
       c.Status, c.RequestedAt
FROM ClaimRequests c
JOIN Items i ON c.ItemID = i.ItemID
JOIN Users u ON c.ClaimantID = u.UserID;
GO

-- 4. Admin dashboard: pending claims with reviewer info (LEFT JOIN since not yet reviewed)
SELECT c.ClaimID, i.Title, u.FullName AS Claimant,
       r.FullName AS ReviewedBy, c.Status
FROM ClaimRequests c
JOIN Items i ON c.ItemID = i.ItemID
JOIN Users u ON c.ClaimantID = u.UserID
LEFT JOIN Users r ON c.ReviewedBy = r.UserID
WHERE c.Status = 'Pending';
GO

-- 5. Count of items reported per user
SELECT u.FullName, COUNT(i.ItemID) AS TotalReports
FROM Users u
LEFT JOIN Items i ON u.UserID = i.ReportedBy
GROUP BY u.FullName;
GO

-- 6. Full audit trail joined with the affected item (where applicable)
SELECT a.LogID, a.ActionType, a.TableName, a.RecordID,
       a.ActionDetails, a.ActionAt
FROM AuditLog a
ORDER BY a.ActionAt DESC;
GO
