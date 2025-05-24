DROP DATABASE IF EXISTS library_management_system;
CREATE DATABASE library_management_system 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;
USE library_management_system;

-- =====================================================
-- 1. CATEGORIES TABLE
-- Stores book categories and genres
-- =====================================================
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_categories PRIMARY KEY (category_id),
    CONSTRAINT uk_category_name UNIQUE (category_name),
    CONSTRAINT chk_category_name_length CHECK (LENGTH(TRIM(category_name)) >= 2)
);

-- =====================================================
-- 2. AUTHORS TABLE  
-- Stores author information and biography
-- =====================================================
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    death_date DATE NULL,
    nationality VARCHAR(50),
    biography TEXT,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_authors PRIMARY KEY (author_id),
    CONSTRAINT uk_author_email UNIQUE (email),
    CONSTRAINT chk_author_names CHECK (
        LENGTH(TRIM(first_name)) >= 1 AND 
        LENGTH(TRIM(last_name)) >= 1
    ),
    CONSTRAINT chk_birth_death_dates CHECK (
        death_date IS NULL OR death_date >= birth_date
    ),
    CONSTRAINT chk_author_email_format CHECK (
        email IS NULL OR 
        email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
    )
);

-- =====================================================
-- 3. PUBLISHERS TABLE
-- Stores publisher information
-- =====================================================
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT,
    publisher_name VARCHAR(150) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(200),
    established_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_publishers PRIMARY KEY (publisher_id),
    CONSTRAINT uk_publisher_name UNIQUE (publisher_name),
    CONSTRAINT uk_publisher_email UNIQUE (email),
    CONSTRAINT chk_publisher_name_length CHECK (LENGTH(TRIM(publisher_name)) >= 2),
    CONSTRAINT chk_established_year CHECK (
        established_year IS NULL OR 
        (established_year >= 1400 AND established_year <= YEAR(CURDATE()))
    ),
    CONSTRAINT chk_publisher_email_format CHECK (
        email IS NULL OR 
        email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
    )
);

-- =====================================================
-- 4. BOOKS TABLE
-- Main book catalog with metadata
-- =====================================================
CREATE TABLE books (
    book_id INT AUTO_INCREMENT,
    isbn VARCHAR(17) NOT NULL,
    title VARCHAR(300) NOT NULL,
    subtitle VARCHAR(300),
    author_id INT NOT NULL,
    category_id INT NOT NULL,
    publisher_id INT NOT NULL,
    publication_year YEAR,
    edition VARCHAR(50) DEFAULT '1st Edition',
    pages INT,
    language VARCHAR(50) DEFAULT 'English',
    price DECIMAL(10,2),
    description TEXT,
    cover_image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_books PRIMARY KEY (book_id),
    CONSTRAINT uk_books_isbn UNIQUE (isbn),
    CONSTRAINT fk_books_author FOREIGN KEY (author_id) 
        REFERENCES authors(author_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_books_category FOREIGN KEY (category_id) 
        REFERENCES categories(category_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_books_publisher FOREIGN KEY (publisher_id) 
        REFERENCES publishers(publisher_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Check constraints
    CONSTRAINT chk_isbn_format CHECK (
        isbn REGEXP '^[0-9]{3}-[0-9]{1}-[0-9]{3}-[0-9]{5}-[0-9]{1}$'
    ),
    CONSTRAINT chk_title_length CHECK (LENGTH(TRIM(title)) >= 1),
    CONSTRAINT chk_pages_positive CHECK (pages IS NULL OR pages > 0),
    CONSTRAINT chk_price_positive CHECK (price IS NULL OR price >= 0),
    CONSTRAINT chk_publication_year CHECK (
        publication_year IS NULL OR 
        (publication_year >= 1400 AND publication_year <= YEAR(CURDATE()) + 1)
    )
);

-- =====================================================
-- 5. BOOK_COPIES TABLE
-- Individual physical copies of books
-- =====================================================
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT,
    book_id INT NOT NULL,
    barcode VARCHAR(50) NOT NULL,
    copy_number VARCHAR(20) NOT NULL,
    condition_status ENUM('Excellent', 'Good', 'Fair', 'Poor', 'Damaged') DEFAULT 'Good',
    location_shelf VARCHAR(50),
    location_section VARCHAR(50),
    acquisition_date DATE DEFAULT (CURRENT_DATE),
    acquisition_cost DECIMAL(10,2),
    is_available BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_book_copies PRIMARY KEY (copy_id),
    CONSTRAINT uk_barcode UNIQUE (barcode),
    CONSTRAINT uk_book_copy_number UNIQUE (book_id, copy_number),
    CONSTRAINT fk_copies_book FOREIGN KEY (book_id) 
        REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Check constraints
    CONSTRAINT chk_acquisition_cost CHECK (
        acquisition_cost IS NULL OR acquisition_cost >= 0
    ),
    CONSTRAINT chk_copy_number_format CHECK (
        copy_number REGEXP '^[A-Z0-9-]+$'
    )
);

-- =====================================================
-- 6. MEMBER_TYPES TABLE
-- Different membership categories and their rules
-- =====================================================
CREATE TABLE member_types (
    type_id INT AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL,
    max_books_allowed INT NOT NULL DEFAULT 5,
    loan_duration_days INT NOT NULL DEFAULT 14,
    fine_per_day DECIMAL(5,2) NOT NULL DEFAULT 0.50,
    membership_fee DECIMAL(8,2) DEFAULT 0.00,
    description TEXT,
    
    -- Constraints
    CONSTRAINT pk_member_types PRIMARY KEY (type_id),
    CONSTRAINT uk_type_name UNIQUE (type_name),
    CONSTRAINT chk_max_books_positive CHECK (max_books_allowed > 0),
    CONSTRAINT chk_loan_duration_positive CHECK (loan_duration_days > 0),
    CONSTRAINT chk_fine_positive CHECK (fine_per_day >= 0),
    CONSTRAINT chk_membership_fee_positive CHECK (membership_fee >= 0)
);

-- =====================================================
-- 7. MEMBERS TABLE
-- Library member information and profiles
-- =====================================================
CREATE TABLE members (
    member_id INT AUTO_INCREMENT,
    member_number VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(10),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other', 'Prefer not to say'),
    member_type_id INT NOT NULL,
    registration_date DATE DEFAULT (CURRENT_DATE),
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_members PRIMARY KEY (member_id),
    CONSTRAINT uk_member_number UNIQUE (member_number),
    CONSTRAINT uk_member_email UNIQUE (email),
    CONSTRAINT fk_members_type FOREIGN KEY (member_type_id) 
        REFERENCES member_types(type_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Check constraints
    CONSTRAINT chk_member_names CHECK (
        LENGTH(TRIM(first_name)) >= 1 AND 
        LENGTH(TRIM(last_name)) >= 1
    ),
    CONSTRAINT chk_member_email_format CHECK (
        email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT chk_member_number_format CHECK (
        member_number REGEXP '^[A-Z0-9]+$'
    ),
    CONSTRAINT chk_expiry_after_registration CHECK (
        expiry_date IS NULL OR expiry_date >= registration_date
    )
);

-- =====================================================
-- 8. STAFF TABLE
-- Library staff information with hierarchy
-- =====================================================
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT,
    employee_id VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    hire_date DATE DEFAULT (CURRENT_DATE),
    salary DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    supervisor_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_staff PRIMARY KEY (staff_id),
    CONSTRAINT uk_employee_id UNIQUE (employee_id),
    CONSTRAINT uk_staff_email UNIQUE (email),
    CONSTRAINT fk_staff_supervisor FOREIGN KEY (supervisor_id) 
        REFERENCES staff(staff_id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Check constraints
    CONSTRAINT chk_staff_names CHECK (
        LENGTH(TRIM(first_name)) >= 1 AND 
        LENGTH(TRIM(last_name)) >= 1
    ),
    CONSTRAINT chk_staff_email_format CHECK (
        email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT chk_salary_positive CHECK (salary IS NULL OR salary >= 0)
);

-- =====================================================
-- 9. LOAN_TRANSACTIONS TABLE
-- Book borrowing and return records
-- =====================================================
CREATE TABLE loan_transactions (
    transaction_id INT AUTO_INCREMENT,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    staff_id INT NOT NULL,
    loan_date DATE DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE NULL,
    returned_by_staff_id INT NULL,
    renewal_count INT DEFAULT 0,
    fine_amount DECIMAL(10,2) DEFAULT 0.00,
    fine_paid DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('Active', 'Returned', 'Overdue', 'Lost', 'Damaged') DEFAULT 'Active',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_loan_transactions PRIMARY KEY (transaction_id),
    CONSTRAINT fk_loans_member FOREIGN KEY (member_id) 
        REFERENCES members(member_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loans_copy FOREIGN KEY (copy_id) 
        REFERENCES book_copies(copy_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loans_staff FOREIGN KEY (staff_id) 
        REFERENCES staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loans_return_staff FOREIGN KEY (returned_by_staff_id) 
        REFERENCES staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Check constraints
    CONSTRAINT chk_due_after_loan CHECK (due_date >= loan_date),
    CONSTRAINT chk_return_after_loan CHECK (
        return_date IS NULL OR return_date >= loan_date
    ),
    CONSTRAINT chk_renewal_count CHECK (renewal_count >= 0),
    CONSTRAINT chk_fine_amounts CHECK (
        fine_amount >= 0 AND 
        fine_paid >= 0 AND 
        fine_paid <= fine_amount
    )
);

-- =====================================================
-- 10. RESERVATIONS TABLE
-- Book reservation system (Many-to-Many: Members-Books)
-- =====================================================
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    reservation_date DATE DEFAULT (CURRENT_DATE),
    expiry_date DATE NOT NULL,
    status ENUM('Active', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Active',
    priority_number INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_reservations PRIMARY KEY (reservation_id),
    CONSTRAINT fk_reservations_member FOREIGN KEY (member_id) 
        REFERENCES members(member_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reservations_book FOREIGN KEY (book_id) 
        REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Unique constraint for active reservations
    CONSTRAINT uk_active_reservation UNIQUE (member_id, book_id, status),
    
    -- Check constraints
    CONSTRAINT chk_expiry_after_reservation CHECK (expiry_date >= reservation_date),
    CONSTRAINT chk_priority_positive CHECK (
        priority_number IS NULL OR priority_number > 0
    )
);

-- =====================================================
-- 11. BOOK_AUTHORS TABLE
-- Many-to-Many relationship: Books can have multiple authors
-- =====================================================
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_role ENUM('Primary Author', 'Co-Author', 'Editor', 'Translator', 'Illustrator') 
        DEFAULT 'Primary Author',
    author_order INT DEFAULT 1,
    
    -- Constraints
    CONSTRAINT pk_book_authors PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_authors_book FOREIGN KEY (book_id) 
        REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_book_authors_author FOREIGN KEY (author_id) 
        REFERENCES authors(author_id) ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Check constraint
    CONSTRAINT chk_author_order_positive CHECK (author_order > 0)
);

-- =====================================================
-- 12. FINE_PAYMENTS TABLE
-- Fine payment tracking and receipts
-- =====================================================
CREATE TABLE fine_payments (
    payment_id INT AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_date DATE DEFAULT (CURRENT_DATE),
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Check', 'Online') NOT NULL,
    staff_id INT NOT NULL,
    receipt_number VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_fine_payments PRIMARY KEY (payment_id),
    CONSTRAINT uk_receipt_number UNIQUE (receipt_number),
    CONSTRAINT fk_payments_transaction FOREIGN KEY (transaction_id) 
        REFERENCES loan_transactions(transaction_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_payments_staff FOREIGN KEY (staff_id) 
        REFERENCES staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Check constraint
    CONSTRAINT chk_payment_amount_positive CHECK (payment_amount > 0)
);

-- =====================================================
-- PERFORMANCE INDEXES
-- =====================================================

-- Books table indexes
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_books_author ON books(author_id);
CREATE INDEX idx_books_category ON books(category_id);
CREATE INDEX idx_books_publisher ON books(publisher_id);

-- Members table indexes
CREATE INDEX idx_members_email ON members(email);
CREATE INDEX idx_members_number ON members(member_number);
CREATE INDEX idx_members_name ON members(last_name, first_name);
CREATE INDEX idx_members_type ON members(member_type_id);

-- Book copies indexes
CREATE INDEX idx_copies_barcode ON book_copies(barcode);
CREATE INDEX idx_copies_available ON book_copies(is_available);
CREATE INDEX idx_copies_book ON book_copies(book_id);

-- Loan transactions indexes
CREATE INDEX idx_loans_status ON loan_transactions(status);
CREATE INDEX idx_loans_due_date ON loan_transactions(due_date);
CREATE INDEX idx_loans_member ON loan_transactions(member_id);
CREATE INDEX idx_loans_copy ON loan_transactions(copy_id);
CREATE INDEX idx_loans_dates ON loan_transactions(loan_date, due_date);

-- Reservations indexes
CREATE INDEX idx_reservations_status ON reservations(status);
CREATE INDEX idx_reservations_member ON reservations(member_id);
CREATE INDEX idx_reservations_book ON reservations(book_id);

-- Authors table indexes
CREATE INDEX idx_authors_name ON authors(last_name, first_name);
CREATE INDEX idx_authors_email ON authors(email);

-- Staff table indexes
CREATE INDEX idx_staff_email ON staff(email);
CREATE INDEX idx_staff_employee_id ON staff(employee_id);

-- =====================================================
-- SAMPLE DATA INSERTION
-- =====================================================

-- Insert Member Types
INSERT INTO member_types (type_name, max_books_allowed, loan_duration_days, fine_per_day, membership_fee, description) VALUES
('Student', 5, 14, 0.25, 0.00, 'For registered students with valid student ID'),
('Faculty', 10, 30, 0.50, 0.00, 'For faculty members and teaching staff'),
('Staff', 7, 21, 0.50, 0.00, 'For library and university staff members'),
('Public', 3, 14, 1.00, 25.00, 'For general public members'),
('Senior', 5, 21, 0.25, 10.00, 'For senior citizens aged 65 and above'),
('Child', 3, 7, 0.00, 0.00, 'For children under 12 years old'),
('Premium', 15, 45, 0.25, 100.00, 'Premium membership with extended privileges');

-- Insert Categories
INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Fictional literature including novels, short stories, and novellas'),
('Non-Fiction', 'Factual books including biographies, history, science, and self-help'),
('Science & Technology', 'Books related to scientific subjects, technology, and engineering'),
('History & Politics', 'Historical books, political science, and government studies'),
('Biography & Memoir', 'Life stories, autobiographies, and personal memoirs'),
('Children & Young Adult', 'Books specifically written for children and teenagers'),
('Reference', 'Dictionaries, encyclopedias, atlases, and reference materials'),
('Arts & Literature', 'Books about fine arts, music, theater, and literary criticism'),
('Health & Medicine', 'Medical books, health guides, and wellness literature'),
('Business & Economics', 'Business management, finance, economics, and entrepreneurship'),
('Philosophy & Religion', 'Philosophical works, religious texts, and spiritual literature'),
('Science Fiction & Fantasy', 'Speculative fiction, fantasy novels, and futuristic literature');

-- Insert Publishers
INSERT INTO publishers (publisher_name, address, phone, email, website, established_year) VALUES
('Penguin Random House', '1745 Broadway, New York, NY 10019', '212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com', 1927),
('HarperCollins Publishers', '195 Broadway, New York, NY 10007', '212-207-7000', 'info@harpercollins.com', 'www.harpercollins.com', 1989),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', '212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com', 1924),
('Macmillan Publishers', '120 Broadway, New York, NY 10271', '646-307-5151', 'info@macmillan.com', 'www.macmillan.com', 1843),
('Hachette Book Group', '1290 Avenue of the Americas, New York, NY 10104', '212-364-1100', 'info@hbgusa.com', 'www.hachettebookgroup.com', 1837),
('Scholastic Corporation', '557 Broadway, New York, NY 10012', '212-343-6100', 'info@scholastic.com', 'www.scholastic.com', 1920),
('Oxford University Press', '198 Madison Avenue, New York, NY 10016', '212-726-6000', 'info@oup.com', 'www.oup.com', 1586),
('Cambridge University Press', '1 Liberty Plaza, New York, NY 10006', '212-924-3900', 'info@cambridge.org', 'www.cambridge.org', 1534);

-- Insert Authors
INSERT INTO authors (first_name, last_name, birth_date, death_date, nationality, email, biography) VALUES
('George', 'Orwell', '1903-06-25', '1950-01-21', 'British', 'george.orwell@classic.com', 'English novelist, essayist, and journalist known for dystopian fiction'),
('Jane', 'Austen', '1775-12-16', '1817-07-18', 'British', 'jane.austen@classic.com', 'English novelist known for romantic fiction and social commentary'),
('Isaac', 'Asimov', '1920-01-02', '1992-04-06', 'American', 'isaac.asimov@scifi.com', 'American writer and professor known for science fiction and popular science'),
('Agatha', 'Christie', '1890-09-15', '1976-01-12', 'British', 'agatha.christie@mystery.com', 'English writer known for detective novels featuring Hercule Poirot'),
('Stephen', 'King', '1947-09-21', NULL, 'American', 'stephen.king@horror.com', 'American author of horror, supernatural fiction, and fantasy novels'),
('J.K.', 'Rowling', '1965-07-31', NULL, 'British', 'jk.rowling@magic.com', 'British author best known for the Harry Potter fantasy series'),
('Harper', 'Lee', '1926-04-28', '2016-02-19', 'American', 'harper.lee@classic.com', 'American novelist known for To Kill a Mockingbird'),
('Mark', 'Twain', '1835-11-30', '1910-04-21', 'American', 'mark.twain@classic.com', 'American writer, humorist, and lecturer'),
('Maya', 'Angelou', '1928-04-04', '2014-05-28', 'American', 'maya.angelou@poetry.com', 'American poet, memoirist, and civil rights activist'),
('Neil', 'Gaiman', '1960-11-10', NULL, 'British', 'neil.gaiman@fantasy.com', 'English author of short fiction, novels, comic books, and films');

-- Insert Books
INSERT INTO books (isbn, title, subtitle, author_id, category_id, publisher_id, publication_year, pages, price, description) VALUES
('978-0-452-28423-4', '1984', NULL, 1, 1, 1, 1949, 328, 15.99, 'Dystopian social science fiction novel about totalitarian surveillance'),
('978-0-141-43951-8', 'Pride and Prejudice', NULL, 2, 1, 1, 1813, 432, 12.99, 'Romantic novel exploring themes of love, reputation, and class'),
('978-0-553-29335-7', 'Foundation', NULL, 3, 12, 2, 1951, 244, 14.99, 'Science fiction novel about psychohistory and the fall of galactic empire'),
('978-0-062-07348-8', 'And Then There Were None', NULL, 4, 1, 3, 1939, 272, 13.99, 'Mystery novel about ten strangers trapped on an island'),
('978-1-501-14297-0', 'The Shining', NULL, 5, 1, 4, 1977, 447, 16.99, 'Horror novel about a family isolated in a haunted hotel'),
('978-0-439-70818-8', 'Harry Potter and the Philosopher\'s Stone', NULL, 6, 6, 6, 1997, 223, 18.99, 'First book in the magical Harry Potter series'),
('978-0-061-12008-4', 'To Kill a Mockingbird', NULL, 7, 1, 3, 1960, 376, 14.99, 'Novel about racial injustice in the American South'),
('978-0-486-28061-8', 'The Adventures of Tom Sawyer', NULL, 8, 6, 2, 1876, 274, 11.99, 'Classic American novel about a young boy\'s adventures'),
('978-0-345-33973-3', 'I Know Why the Caged Bird Sings', NULL, 9, 5, 1, 1969, 289, 13.99, 'Autobiographical work about overcoming racism and trauma'),
('978-0-380-97365-0', 'American Gods', NULL, 10, 12, 3, 2001, 635, 17.99, 'Fantasy novel about old gods in modern America');

-- Insert Book-Author relationships
INSERT INTO book_authors (book_id, author_id, author_role, author_order) VALUES
(1, 1, 'Primary Author', 1),
(2, 2, 'Primary Author', 1),
(3, 3, 'Primary Author', 1),
(4, 4, 'Primary Author', 1),
(5, 5, 'Primary Author', 1),
(6, 6, 'Primary Author', 1),
(7, 7, 'Primary Author', 1),
(8, 8, 'Primary Author', 1),
(9, 9, 'Primary Author', 1),
(10, 10, 'Primary Author', 1);

-- Insert Book Copies
INSERT INTO book_copies (book_id, barcode, copy_number, condition_status, location_shelf, location_section, acquisition_cost) VALUES
(1, 'LIB001001', 'C001-1', 'Excellent', 'A1-001', 'Fiction', 15.99),
(1, 'LIB001002', 'C001-2', 'Good', 'A1-001', 'Fiction', 15.99),
(1, 'LIB001003', 'C001-3', 'Good', 'A1-001', 'Fiction', 15.99),
(2, 'LIB002001', 'C002-1', 'Excellent', 'A1-002', 'Fiction', 12.99),
(2, 'LIB002002', 'C002-2', 'Good', 'A1-002', 'Fiction', 12.99),
(3, 'LIB003001', 'C003-1', 'Excellent', 'B1-001', 'Science Fiction', 14.99),
(4, 'LIB004001', 'C004-1', 'Fair', 'A1-003', 'Fiction', 13.99),
(5, 'LIB005001', 'C005-1', 'Good', 'A1-004', 'Fiction', 16.99),
(6, 'LIB006001', 'C006-1', 'Excellent', 'C1-001', 'Children', 18.99),
(6, 'LIB006002', 'C006-2', 'Good', 'C1-001', 'Children', 18.99),
(7, 'LIB007001', 'C007-1', 'Good', 'A1-005', 'Fiction', 14.99),
(8, 'LIB008001', 'C008-1', 'Excellent', 'C1-002', 'Children', 11.99),
(9, 'LIB009001', 'C009-1', 'Good', 'B2-001', 'Biography', 13.99),
(10, 'LIB010001', 'C010-1', 'Excellent', 'B1-002', 'Science Fiction', 17.99);

-- Insert Staff
INSERT INTO staff (employee_id, first_name, last_name, email, position, department, salary, supervisor_id) VALUES
('EMP001', 'Alice', 'Johnson', 'alice.johnson@library.edu', 'Head Librarian', 'Administration', 65000.00, NULL),
('EMP002', 'Bob', 'Smith', 'bob.smith@library.edu', 'Reference Librarian', 'Reference Services', 45000.00, 1),
('EMP003', 'Carol', 'Davis', 'carol.davis@library.edu', 'Circulation Assistant', 'Circulation', 35000.00, 1),
('EMP004', 'David', 'Wilson', 'david.wilson@library.edu', 'Technical Services Librarian', 'Cataloging', 40000.00, 1),
('EMP005', 'Emma', 'Brown', 'emma.brown@library.edu', 'Children\'s Librarian', 'Children Services', 42000.00, 2),
('EMP006', 'Frank', 'Miller', 'frank.miller@library.edu', 'IT Support Specialist', 'Technology', 48000.00, 1),
('EMP007', 'Grace', 'Taylor', 'grace.taylor@library.edu', 'Acquisitions Librarian', 'Collection Development', 46000.00, 2);

-- Insert Members
INSERT INTO members (member_number, first_name, last_name, email, phone, address, city, state, zip_code, date_of_birth, gender, member_type_id, expiry_date) VALUES
('MEM001', 'John', 'Doe', 'john.doe@email.com', '555-0101', '123 Main St', 'Springfield', 'IL', '62701', '1990-05-15', 'Male', 1, '2025-12-31'),
('MEM002', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '555-0102', '456 Oak Ave', 'Springfield', 'IL', '62702', '1985-08-22', 'Female', 2, '2025-12-31'),
('MEM003', 'Mike', 'Brown', 'mike.brown@email.com', '555-0103', '789 Pine Rd', 'Springfield', 'IL', '62703', '1995-12-10', 'Male', 1, '2025-12-31'),
('MEM004', 'Emily', 'Davis', 'emily.davis@email.com', '555-0104', '321 Elm St', 'Springfield', 'IL', '62704', '1988-03-07', 'Female', 4, '2025-12-31'),
('MEM005', 'Robert', 'Wilson', 'robert.wilson@email.com', '555-0105', '654 Maple Dr', 'Springfield', 'IL', '62705', '1992-11-18', 'Male', 1, '2025-12-31'),
('MEM006', 'Lisa', 'Anderson', 'lisa.anderson@email.com', '555-0106', '987 Cedar Ln', 'Springfield', 'IL', '62706', '1978-09-03', 'Female', 3, '2025-12-31'),
('MEM007', 'James', 'Martinez', 'james.martinez@email.com', '555-0107', '147 Birch St', 'Springfield', 'IL', '62707', '2010-02-14', 'Male', 6, '2025-12-31'),
('MEM008', 'Maria', 'Garcia', 'maria.garcia@email.com', '555-0108', '258 Walnut Ave', 'Springfield', 'IL', '62708', '1955-11-20', 'Female', 5, '2025-12-31');

-- Insert Loan Transactions
INSERT INTO loan_transactions (member_id, copy_id, staff_id, loan_date, due_date, status) VALUES
(1, 1, 3, '2025-01-01', '2025-01-15', 'Active'),
(2, 6, 3, '2025-01-05', '2025-02-04', 'Active'),
(3, 2, 3, '2024-12-20', '2025-01-03', 'Overdue'),
(4, 7, 3, '2025-01-10', '2025-01-24', 'Active'),
(5, 8, 3, '2024-12-15', '2024-12-29', 'Returned'),
(6, 9, 3, '2025-01-08', '2025-01-29', 'Active'),
(7, 10, 5, '2025-01-12', '2025-01-19', 'Active'),
(8, 11, 3, '2025-01-06', '2025-01-27', 'Active');

-- Update some transactions as returned
UPDATE loan_transactions 
SET return_date = '2024-12-28', returned_by_staff_id = 3, status = 'Returned' 
WHERE transaction_id = 5;

-- Update book copy availability
UPDATE book_copies 
SET is_available = FALSE 
WHERE copy_id IN (1, 2, 6, 7, 9, 10, 11);

-- Insert Reservations
INSERT INTO reservations (member_id, book_id, expiry_date, priority_number, status) VALUES
(1, 5, '2025-02-01', 1, 'Active'),
(3, 6, '2025-02-05', 1, 'Active'),
(4, 1, '2025-01-30', 2, 'Active'),
(5, 3, '2025-02-10', 1, 'Active');

-- Insert Fine Payments (for demonstration)
INSERT INTO fine_payments (transaction_id, payment_amount, payment_method, staff_id, receipt_number) VALUES
(3, 5.00, 'Cash', 3, 'REC001'),
(5, 2.50, 'Credit Card', 3, 'REC002');

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Display database creation summary
SELECT 'Library Management System Database Created Successfully!' AS Status;

-- Show table count and structure
SELECT 
    TABLE_NAME as 'Table Name',
    TABLE_ROWS as 'Estimated Rows',
    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'library_management_system'
ORDER BY TABLE_NAME;

-- Show relationship summary
SELECT 
    'Total Tables' as Metric, 
    COUNT(*) as Count
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'library_management_system'
UNION ALL
SELECT 
    'Foreign Key Constraints' as Metric,
    COUNT(*) as Count
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'library_management_system' 
AND REFERENCED_TABLE_NAME IS NOT NULL
UNION ALL
SELECT 
    'Total Books' as Metric,
    COUNT(*) as Count
FROM books
UNION ALL
SELECT 
    'Total Members' as Metric,
    COUNT(*) as Count
FROM members
UNION ALL
SELECT 
    'Active Loans' as Metric,
    COUNT(*) as Count
FROM loan_transactions
WHERE status = 'Active';


