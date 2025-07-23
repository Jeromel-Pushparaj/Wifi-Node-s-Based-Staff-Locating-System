CREATE TABLE staff_presence (
    staff_id VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    location VARCHAR(255),
    last_updated DATETIME,
    department VARCHAR(255),
    PRIMARY KEY (staff_id)
);

INSERT INTO staff_presence (staff_id, name, location, last_updated, department)
VALUES ('S123', 'Dr. Kesavaraja', 'Lab5', NOW(), 'CSE'),
('S124', 'Dr. Bavani', 'staffRoom', NOW(), 'CSE');

CREATE TABLE wifi_nodes (
    node_id VARCHAR(50) PRIMARY KEY,
    ssid VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    department VARCHAR(25)
);

INSERT INTO wifi_nodes (node_id, ssid, location, department) VALUES
('N1', 'Lab5', 'Lab 5', 'CSE'),
('N2', 'StaffRoom', 'Staff Room', 'CSE'),
('N3', 'Lab3', 'Lab 3', 'CSE');

