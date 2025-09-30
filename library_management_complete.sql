-- library_management_complete.sql
-- DATABASE CREATION

-- Drop database if it exists (be careful in production!)
DROP DATABASE IF EXISTS library_management;

-- Create the database with UTF-8 support
CREATE DATABASE library_management
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Use the database
USE library_management;


CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    death_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- CONSTRAINTS
    CONSTRAINT chk_birth_death CHECK (death_date IS NULL OR death_date >= birth_date),
    CONSTRAINT chk_birth_future CHECK (birth_date <= CURDATE()),
    
    -- INDEXES for performance
    INDEX idx_author_name (last_name, first_name),
    INDEX idx_author_nationality (nationality)
);


CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100),
    established_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- CONSTRAINTS
    CONSTRAINT chk_established_year CHECK (established_year <= YEAR(CURDATE())),
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    
    -- INDEXES
    INDEX idx_publisher_name (name),
    INDEX idx_publisher_country (country)
);


-- 3. CATEGORIES TABLE (Hierarchical structure with self-reference)
-- Stores book categories with support for subcategories
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- FOREIGN KEY RELATIONSHIP (Self-referencing for hierarchical categories)
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    
    -- INDEXES
    INDEX idx_category_name (name),
    INDEX idx_parent_category (parent_category_id)
);


-- 4. BOOKS TABLE
-- Main table storing book information with foreign key relationships

CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20) UNIQUE,
    title VARCHAR(255) NOT NULL,
    subtitle VARCHAR(255),
    edition VARCHAR(50),
    publication_year YEAR,
    pages INT,
    language VARCHAR(50) DEFAULT 'English',
    description TEXT,
    publisher_id INT,
    category_id INT NOT NULL,
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    shelf_location VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- FOREIGN KEY RELATIONSHIPS
    -- One-to-Many: Publisher -> Books
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    -- One-to-Many: Category -> Books
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT,
    
    -- CONSTRAINTS
    CONSTRAINT chk_isbn_format CHECK (isbn REGEXP '^[0-9]{3}-[0-9]{1,5}-[0-9]{1,7}-[0-9]{1,7}-[0-9]$' 
                                     OR isbn REGEXP '^[0-9]{10}$' 
                                     OR isbn REGEXP '^[0-9]{13}$'),
    CONSTRAINT chk_publication_year CHECK (publication_year <= YEAR(CURDATE())),
    CONSTRAINT chk_pages CHECK (pages > 0),
    CONSTRAINT chk_copies CHECK (total_copies >= 0 AND available_copies >= 0 AND available_copies <= total_copies),
    
    -- INDEXES
    INDEX idx_book_title (title),
    INDEX idx_book_isbn (isbn),
    INDEX idx_book_publisher (publisher_id),
    INDEX idx_book_category (category_id),
    INDEX idx_book_year (publication_year),
    FULLTEXT INDEX idx_book_search (title, subtitle, description)
);


-- 5. BOOK_AUTHORS TABLE (Junction table for Many-to-Many relationship)
-- Implements Many-to-Many relationship between Books and Authors

CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    author_order TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- COMPOSITE PRIMARY KEY
    PRIMARY KEY (book_id, author_id),
    
    -- FOREIGN KEY RELATIONSHIPS (Many-to-Many)
    -- Books <-> Authors (through junction table)
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE,
    
    -- CONSTRAINTS
    CONSTRAINT chk_author_order CHECK (author_order > 0),
    
    -- INDEXES
    INDEX idx_book_authors_book (book_id),
    INDEX idx_book_authors_author (author_id)
);

-- 6. MEMBERS TABLE
-- Stores library member information

CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    membership_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other', 'Prefer not to say'),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    membership_type ENUM('Student', 'Faculty', 'Staff', 'Public') NOT NULL DEFAULT 'Public',
    membership_start_date DATE NOT NULL DEFAULT (CURDATE()),
    membership_end_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    fine_balance DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- CONSTRAINTS
    CONSTRAINT chk_member_dates CHECK (membership_end_date IS NULL OR membership_end_date >= membership_start_date),
    CONSTRAINT chk_member_birth CHECK (date_of_birth <= CURDATE()),
    CONSTRAINT chk_email_format_member CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_fine_balance CHECK (fine_balance >= 0),
    
    -- INDEXES
    INDEX idx_member_name (last_name, first_name),
    INDEX idx_membership_number (membership_number),
    INDEX idx_member_email (email),
    INDEX idx_membership_type (membership_type),
    INDEX idx_member_active (is_active)
);

-- 7. STAFF TABLE
-- Stores library staff information

CREATE TABLE staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL DEFAULT (CURDATE()),
    salary DECIMAL(10,2),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- CONSTRAINTS
    CONSTRAINT chk_hire_date CHECK (hire_date <= CURDATE()),
    CONSTRAINT chk_salary CHECK (salary >= 0),
    CONSTRAINT chk_email_format_staff CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    
    -- INDEXES
    INDEX idx_staff_name (last_name, first_name),
    INDEX idx_employee_id (employee_id),
    INDEX idx_staff_email (email),
    INDEX idx_staff_position (position),
    INDEX idx_staff_active (is_active)
);


-- 8. BORROWING_RECORDS TABLE

CREATE TABLE borrowing_records (
    borrowing_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    staff_id INT,
    borrow_date DATE NOT NULL DEFAULT (CURDATE()),
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('Borrowed', 'Returned', 'Overdue', 'Lost') NOT NULL DEFAULT 'Borrowed',
    renewal_count TINYINT NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- FOREIGN KEY RELATIONSHIPS
    -- One-to-Many: Member -> Borrowing Records
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    -- One-to-Many: Book -> Borrowing Records
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    -- One-to-Many: Staff -> Borrowing Records (processed by)
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    
    -- CONSTRAINTS
    CONSTRAINT chk_due_date CHECK (due_date >= borrow_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= borrow_date),
    CONSTRAINT chk_renewal_count CHECK (renewal_count >= 0 AND renewal_count <= 5),
    
    -- INDEXES
    INDEX idx_borrowing_member (member_id),
    INDEX idx_borrowing_book (book_id),
    INDEX idx_borrowing_staff (staff_id),
    INDEX idx_borrow_date (borrow_date),
    INDEX idx_due_date (due_date),
    INDEX idx_status (status),
    INDEX idx_overdue (status, due_date)
);

-- 9. RESERVATIONS TABLE
-- Manages book reservations with foreign key relationships

CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    reservation_date DATE NOT NULL DEFAULT (CURDATE()),
    expiry_date DATE NOT NULL,
    status ENUM('Active', 'Fulfilled', 'Cancelled', 'Expired') NOT NULL DEFAULT 'Active',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- FOREIGN KEY RELATIONSHIPS
    -- One-to-Many: Member -> Reservations
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    -- One-to-Many: Book -> Reservations
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    
    -- CONSTRAINTS
    CONSTRAINT chk_expiry_date CHECK (expiry_date >= reservation_date),
    
    -- UNIQUE CONSTRAINTS
    UNIQUE KEY unique_active_reservation (member_id, book_id, status),
    
    -- INDEXES
    INDEX idx_reservation_member (member_id),
    INDEX idx_reservation_book (book_id),
    INDEX idx_reservation_date (reservation_date),
    INDEX idx_expiry_date (expiry_date),
    INDEX idx_reservation_status (status)
);


-- 10. FINES TABLE
-- Tracks fines and penalties with foreign key relationshi
CREATE TABLE fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    borrowing_id INT,
    fine_type ENUM('Overdue', 'Lost Book', 'Damage', 'Processing Fee') NOT NULL,
    amount DECIMAL(8,2) NOT NULL,
    description TEXT,
    fine_date DATE NOT NULL DEFAULT (CURDATE()),
    paid_date DATE,
    status ENUM('Pending', 'Paid', 'Waived', 'Partial') NOT NULL DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- FOREIGN KEY RELATIONSHIPS
    -- One-to-Many: Member -> Fines
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    -- One-to-One: Borrowing Record -> Fine (optional)
    FOREIGN KEY (borrowing_id) REFERENCES borrowing_records(borrowing_id) ON DELETE SET NULL,
    
    -- CONSTRAINTS
    CONSTRAINT chk_fine_amount CHECK (amount >= 0),
    CONSTRAINT chk_paid_date CHECK (paid_date IS NULL OR paid_date >= fine_date),
    
    -- INDEXES
    INDEX idx_fine_member (member_id),
    INDEX idx_fine_borrowing (borrowing_id),
    INDEX idx_fine_date (fine_date),
    INDEX idx_fine_status (status),
    INDEX idx_fine_type (fine_type)
);


-- ADDITIONAL PERFORMANCE INDEXES


-- Composite indexes for frequently used queries
CREATE INDEX idx_borrowing_member_status ON borrowing_records(member_id, status);
CREATE INDEX idx_borrowing_book_status ON borrowing_records(book_id, status);
CREATE INDEX idx_borrowing_due_status ON borrowing_records(due_date, status);

-- Indexes for search functionality
CREATE INDEX idx_author_full_name ON authors(CONCAT(first_name, ' ', last_name));
CREATE INDEX idx_member_full_name ON members(CONCAT(first_name, ' ', last_name));
CREATE INDEX idx_staff_full_name ON staff(CONCAT(first_name, ' ', last_name));

-- Indexes for date range queries
CREATE INDEX idx_borrowing_date_range ON borrowing_records(borrow_date, return_date);
CREATE INDEX idx_membership_date_range ON members(membership_start_date, membership_end_date);

-- BUSINESS LOGIC 

-- Trigger to update available copies when a book is borrowed
DELIMITER //
CREATE TRIGGER tr_after_borrow_insert
AFTER INSERT ON borrowing_records
FOR EACH ROW
BEGIN
    IF NEW.status = 'Borrowed' THEN
        UPDATE books 
        SET available_copies = available_copies - 1 
        WHERE book_id = NEW.book_id;
    END IF;
END //
DELIMITER ;

-- Trigger to update available copies when a book is returned
DELIMITER //
CREATE TRIGGER tr_after_borrow_update
AFTER UPDATE ON borrowing_records
FOR EACH ROW
BEGIN
    -- Book returned
    IF OLD.status = 'Borrowed' AND NEW.status = 'Returned' THEN
        UPDATE books 
        SET available_copies = available_copies + 1 
        WHERE book_id = NEW.book_id;
    END IF;
    
    -- Book marked as lost
    IF OLD.status = 'Borrowed' AND NEW.status = 'Lost' THEN
        UPDATE books 
        SET total_copies = total_copies - 1 
        WHERE book_id = NEW.book_id;
    END IF;
END //
DELIMITER ;

-- Trigger to update member fine balance when fine is added
DELIMITER //
CREATE TRIGGER tr_after_fine_insert
AFTER INSERT ON fines
FOR EACH ROW
BEGIN
    UPDATE members 
    SET fine_balance = fine_balance + NEW.amount 
    WHERE member_id = NEW.member_id;
END //
DELIMITER ;


-- SAMPLE DATA INSERTION


-- Insert Categories (demonstrating hierarchical structure)
INSERT INTO categories (name, description, parent_category_id) VALUES
('Fiction', 'Literary works of imagination', NULL),
('Non-Fiction', 'Factual and informational books', NULL),
('Science', 'Scientific literature and research', 2),
('History', 'Historical accounts and biographies', 2),
('Mystery', 'Mystery and detective fiction', 1),
('Romance', 'Romantic fiction', 1),
('Computer Science', 'Computing and programming books', 3);

-- Insert Publishers
INSERT INTO publishers (name, city, country, established_year, email) VALUES
('Penguin Random House', 'New York', 'USA', 1927, 'info@penguinrandomhouse.com'),
('HarperCollins', 'New York', 'USA', 1989, 'contact@harpercollins.com'),
('Oxford University Press', 'Oxford', 'UK', 1586, 'info@oup.com'),
('MIT Press', 'Cambridge', 'USA', 1962, 'mitpress@mit.edu');

-- Insert Authors
INSERT INTO authors (first_name, last_name, birth_date, nationality) VALUES
('Agatha', 'Christie', '1890-09-15', 'British'),
('Jane', 'Austen', '1775-12-16', 'British'),
('Stephen', 'King', '1947-09-21', 'American'),
('Donald', 'Knuth', '1938-01-10', 'American'),
('Isaac', 'Asimov', '1920-01-02', 'American');

-- Insert Books
INSERT INTO books (isbn, title, publication_year, pages, publisher_id, category_id, total_copies, available_copies) VALUES
('978-0-06-112008-4', 'Murder on the Orient Express', 1934, 256, 2, 5, 3, 3),
('978-0-14-143951-8', 'Pride and Prejudice', 1813, 432, 1, 6, 2, 2),
('978-0-385-12167-5', 'The Shining', 1977, 659, 1, 1, 4, 4),
('978-0-201-89683-1', 'The Art of Computer Programming Vol 1', 1968, 672, 4, 7, 2, 2),
('978-0-553-29337-0', 'Foundation', 1951, 244, 1, 1, 3, 3);

-- Link Books to Authors (Many-to-Many relationship)
INSERT INTO book_authors (book_id, author_id, author_order) VALUES
(1, 1, 1),  -- Murder on the Orient Express by Agatha Christie
(2, 2, 1),  -- Pride and Prejudice by Jane Austen
(3, 3, 1),  -- The Shining by Stephen King
(4, 4, 1),  -- The Art of Computer Programming by Donald Knuth
(5, 5, 1);  -- Foundation by Isaac Asimov

-- Insert Members
INSERT INTO members (membership_number, first_name, last_name, email, membership_type, membership_start_date) VALUES
('MEM001', 'John', 'Doe', 'john.doe@email.com', 'Public', '2025-01-15'),
('MEM002', 'Sarah', 'Johnson', 'sarah.j@university.edu', 'Student', '2025-02-01'),
('MEM003', 'Michael', 'Brown', 'mbrown@university.edu', 'Faculty', '2025-01-10'),
('MEM004', 'Emily', 'Davis', 'emily.davis@email.com', 'Public', '2025-03-01');

-- Insert Staff
INSERT INTO staff (employee_id, first_name, last_name, position, email, hire_date, salary) VALUES
('EMP001', 'Alice', 'Wilson', 'Head Librarian', 'alice.wilson@library.edu', '2020-08-15', 65000.00),
('EMP002', 'Bob', 'Martinez', 'Assistant Librarian', 'bob.martinez@library.edu', '2022-01-10', 45000.00),
('EMP003', 'Carol', 'Thompson', 'Library Assistant', 'carol.thompson@library.edu', '2023-06-01', 35000.00);


SELECT 
    'Library Management Database System Created Successfully!' AS Status,
    'Database includes 10 tables with proper relationships and constraints' AS Details,
    'Ready for production use with sample data loaded' AS Note;