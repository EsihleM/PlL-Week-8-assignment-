# Library Management System Database

A comprehensive database design for managing a library system with books, members, authors, and loan transactions.

## 📋 Project Description

This project implements a complete relational database schema for a library management system. The database handles:

- **Book Management**: Catalog of books with multiple copies, authors, and categories
- **Member Management**: Library member registration and information
- **Loan System**: Book checkout, return, and overdue tracking
- **Inventory Control**: Track book copies, availability, and condition

## 🗄️ Database Schema

### Core Tables

1. **categories** - Book classification system
2. **authors** - Author information and biography
3. **books** - Book catalog with metadata
4. **book_copies** - Individual book copies and their status
5. **members** - Library member information
6. **loan_transactions** - Book borrowing and return records

### Key Features

- ✅ Referential integrity with foreign key constraints
- ✅ Optimized with strategic indexes
- ✅ Sample data for testing
- ✅ Useful views for common queries
- ✅ Stored procedures for business logic
- ✅ Comprehensive commenting

## 🚀 Setup Instructions

### Prerequisites
- MySQL 8.0+ or MariaDB 10.3+
- Database client (MySQL Workbench, phpMyAdmin, or command line)

### Installation Steps

1. **Clone or download** the `library-management-system.sql` file

2. **Connect to your MySQL server**:
   ```bash
   mysql -u your_username -p
   ```

3. **Create a new database**:
   ```sql
   CREATE DATABASE library_system;
   USE library_system;
   ```

4. **Import the SQL file**:
   ```bash
   mysql -u your_username -p library_system < library-management-system.sql
   ```

   Or copy and paste the SQL content directly into your database client.

5. **Verify installation**:
   ```sql
   SHOW TABLES;
   SELECT COUNT(*) FROM books;
   ```

## 📊 Entity Relationship Diagram (ERD)

![Library Management System ERD](https://via.placeholder.com/800x600/2563eb/ffffff?text=ERD+Diagram)
