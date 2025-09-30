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

```
