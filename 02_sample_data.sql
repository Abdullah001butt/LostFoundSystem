/* ============================================================
   Sample Data
   ============================================================ */
USE LostFoundSystem;
GO

INSERT INTO Users (FullName, Email, Phone, Role) VALUES
('Ali Raza',     'ali.raza@campus.edu',     '03001234567', 'Student'),
('Sara Khan',    'sara.khan@campus.edu',    '03011234567', 'Student'),
('Bilal Ahmed',  'bilal.ahmed@campus.edu',  '03021234567', 'Student'),
('Hina Malik',   'hina.malik@campus.edu',   '03031234567', 'Student'),
('Admin User',   'admin@campus.edu',        '03000000000', 'Admin');
GO

-- Lost items
INSERT INTO Items (Title, Description, Category, ItemType, Location, EventDate, ReportedBy) VALUES
('Black Wallet',       'Leather wallet with student ID inside', 'Wallet',      'Lost',  'Library',            '2026-07-01', 1),
('iPhone 13',          'Blue iPhone with cracked screen',       'Electronics', 'Lost',  'Cafeteria',          '2026-07-03', 2),
('Blue Water Bottle',  'Steel bottle with stickers',            'Bottle',      'Lost',  'Sports Ground',      '2026-07-05', 3);
GO

-- Found items
INSERT INTO Items (Title, Description, Category, ItemType, Location, EventDate, ReportedBy) VALUES
('Wallet Found',       'Black leather wallet found near reading hall', 'Wallet',      'Found', 'Library',       '2026-07-01', 4),
('Phone Found',        'Blue smartphone, screen cracked',              'Electronics', 'Found', 'Cafeteria',     '2026-07-04', 4),
('Water Bottle Found', 'Steel bottle found near football field',       'Bottle',      'Found', 'Sports Ground', '2026-07-05', 2);
GO
