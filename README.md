# Library Management System Database

## Overview
A comprehensive relational database system for managing a library's operations including books, members, staff, borrowing, reservations, and fines.

## Features
- **Book Management**: Track books, authors, publishers, and categories
- **Member Management**: Manage library members and their information
- **Staff Management**: Handle librarian and staff records
- **Borrowing System**: Track book checkouts and returns
- **Reservation System**: Allow members to reserve books
- **Fine Management**: Calculate and track overdue fines
- **Inventory Tracking**: Monitor book availability and location

## Database Schema
The system includes the following main entities:
- Authors
- Publishers
- Categories
- Books
- Members
- Staff
- Borrowing Records
- Reservations
- Fines

## Relationships
- **One-to-Many**: Author → Books, Publisher → Books, Category → Books
- **Many-to-Many**: Books ↔ Authors (through book_authors junction table)
- **One-to-Many**: Member → Borrowing Records, Member → Reservations
- **One-to-Many**: Staff → Borrowing Records (processed by)

## Files Structure
```
├── schema/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_create_indexes.sql
│   └── 04_create_triggers.sql
├── data/
│   ├── insert_sample_data.sql
│   └── bulk_data_import.sql
├── queries/
│   ├── basic_queries.sql
│   ├── advanced_queries.sql
│   └── reports.sql
├── procedures/
│   ├── stored_procedures.sql
│   └── functions.sql
└── views/
    └── create_views.sql
```

## Getting Started
1. Run the schema files in order (01-04)
2. Insert sample data using data/insert_sample_data.sql
3. Test with queries in the queries/ directory