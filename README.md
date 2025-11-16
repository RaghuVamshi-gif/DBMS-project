# E-Commerce Website - DBMS Project

A complete e-commerce web application built with MySQL, Node.js/Express, and vanilla JavaScript.

## Features

- **Product Management**: Browse products by category, view details, and manage inventory
- **Customer Management**: Add customers and track their purchase history
- **Order Processing**: Place orders with automatic stock updates and total calculations
- **Shopping Cart**: Add items to cart and checkout
- **Database Functions**: Custom MySQL functions for customer statistics
- **Stored Procedures**: Automated order placement and customer management
- **Triggers**: Automatic order total updates, stock validation, and order logging

## Database Features

### Tables
- `customers` - Store customer information
- `products` - Product catalog with stock management
- `orders` - Order records with customer references
- `order_items` - Individual items in each order
- `order_logs` - Audit trail for deleted orders

### Functions
- `get_total_orders(customer_id)` - Returns total orders for a customer
- `get_customer_spent(customer_id)` - Returns total amount spent by a customer
- `check_stock(product_id, quantity)` - Checks if sufficient stock is available

### Stored Procedures
- `add_new_customer` - Add a new customer to the database
- `place_order` - Place an order with stock validation and updates
- `get_customer_orders` - Retrieve customer order history

### Triggers
- `update_order_total` - Automatically calculates order total when items are added
- `prevent_negative_stock` - Prevents stock from going below zero
- `log_order_deletion` - Logs deleted orders for audit purposes
- `validate_stock_before_order` - Validates stock availability before creating order items

## Technology Stack

- **Backend**: Node.js, Express.js
- **Database**: MySQL 8.0+
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **API**: RESTful API

## Prerequisites

- Node.js (v14 or higher)
- MySQL (v8.0 or higher)
- npm or yarn

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd DBMS-project
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Setup MySQL Database**

   **For Windows PowerShell (Recommended):**
   ```powershell
   # This script automatically finds MySQL and sets up the database
   .\setup-database-manual.ps1
   ```

   > **Note:** If you get "mysql is not recognized" error, the script above will automatically find your MySQL installation. See [setup-mysql-path.md](setup-mysql-path.md) for adding MySQL to PATH permanently.

   **For Windows Command Prompt:**
   ```cmd
   setup-database.bat
   ```

   **For Linux/Mac (Bash):**
   ```bash
   mysql -u root -p < database/schema.sql
   ```

   **If MySQL is already in your PATH:**
   ```powershell
   Get-Content database/schema.sql | mysql -u root -p
   ```

4. **Configure Environment Variables**

   Copy `.env.example` to `.env` and update with your MySQL credentials:
   ```bash
   cp .env.example .env
   ```

   Edit `.env`:
   ```
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=your_password
   DB_NAME=ecommerce
   PORT=3000
   ```

5. **Start the server**
   ```bash
   npm start
   ```

   For development with auto-reload:
   ```bash
   npm run dev
   ```

6. **Access the application**

   Open your browser and go to:
   ```
   http://localhost:3000
   ```

## Project Structure

```
DBMS-project/
├── backend/
│   ├── server.js          # Express server and API routes
│   └── config.js          # Database configuration
├── frontend/
│   ├── index.html         # Main HTML file
│   ├── styles.css         # CSS styles
│   └── app.js             # Frontend JavaScript
├── database/
│   └── schema.sql         # Database schema with tables, functions, procedures, and triggers
├── DBMS SQL.sql           # Original SQL file
├── package.json           # Node.js dependencies
├── .env.example           # Environment variables template
├── .gitignore            # Git ignore file
└── README.md             # This file
```

## API Endpoints

### Products
- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get product by ID
- `GET /api/products/category/:category` - Get products by category
- `GET /api/categories` - Get all categories

### Customers
- `GET /api/customers` - Get all customers
- `GET /api/customers/:id` - Get customer by ID
- `POST /api/customers` - Add new customer
- `GET /api/customers/:id/orders` - Get customer orders
- `GET /api/customers/:id/stats` - Get customer statistics

### Orders
- `GET /api/orders` - Get all orders
- `GET /api/orders/:id` - Get order by ID with items
- `POST /api/orders` - Place a single-item order
- `POST /api/orders/multi` - Place a multi-item order
- `PATCH /api/orders/:id/status` - Update order status

### Statistics
- `GET /api/stats` - Get dashboard statistics

## SQL Fixes Applied

1. **Added customers table** - Was referenced but not created in original SQL
2. **Fixed trigger logic** - Updated `update_order_total` trigger to calculate total correctly
3. **Added stock validation** - New trigger to validate stock before order item insertion
4. **Improved procedures** - Enhanced `place_order` procedure with better error handling
5. **Added new functions** - Created `check_stock` function for stock validation
6. **Fixed delimiter issues** - Properly used DELIMITER for all functions and procedures
7. **Added CASCADE deletes** - Proper foreign key constraints with cascade deletion
8. **Fixed double-counting** - Resolved issue where order total was calculated twice

## Usage

### Adding a Customer
1. Navigate to the Customers page
2. Click "Add Customer"
3. Fill in the customer details
4. Submit the form

### Placing an Order
1. Browse products on the Products page
2. Click "Add to Cart" for desired items
3. Navigate to Cart page
4. Click "Checkout"
5. Select a customer
6. Confirm the order

### Viewing Statistics
- Dashboard (Home page) shows overall statistics
- Customer cards display individual customer statistics (total orders and total spent)

## Troubleshooting

### Database Connection Issues
- Ensure MySQL is running
- Check credentials in `.env` file
- Verify database `ecommerce` exists

### Port Already in Use
- Change the PORT in `.env` file
- Or stop the process using port 3000

### Module Not Found
- Run `npm install` to install all dependencies

## Future Enhancements

- User authentication and authorization
- Product images upload
- Order status tracking
- Payment integration
- Search and filtering
- Pagination for large datasets
- Admin dashboard
- Email notifications

## License

This project is created for educational purposes as part of a DBMS course project.
