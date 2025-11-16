-- E-commerce Database Schema
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS order_logs;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- Create customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    description TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Create order_items table
CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- Create order_logs table
CREATE TABLE order_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    action VARCHAR(50),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample customers
INSERT INTO customers (name, email, phone, address) VALUES
('Ravi Kumar', 'ravi@example.com', '9876543210', 'Delhi'),
('Sneha Sharma', 'sneha@example.com', '9988776655', 'Mumbai'),
('Arjun Mehta', 'arjun@example.com', '9123456789', 'Bangalore'),
('Priya Nair', 'priya@example.com', '9876000111', 'Chennai');

-- Insert sample products
INSERT INTO products (product_name, category, price, stock, description) VALUES
('iPhone 15', 'Mobiles', 79999.00, 10, 'Latest iPhone with advanced features'),
('Samsung Galaxy S24', 'Mobiles', 69999.00, 8, 'Premium Samsung smartphone'),
('Lenovo Laptop', 'Laptops', 55000.00, 5, 'High-performance laptop for work'),
('Sony Headphones', 'Accessories', 5999.00, 20, 'Noise-cancelling headphones'),
('Dell Monitor', 'Accessories', 15000.00, 15, '27-inch 4K monitor'),
('Wireless Mouse', 'Accessories', 1299.00, 50, 'Ergonomic wireless mouse'),
('MacBook Pro', 'Laptops', 125000.00, 3, 'Professional laptop for creators'),
('OnePlus 12', 'Mobiles', 54999.00, 12, 'Fast charging smartphone');

-- ==========================================
-- FUNCTIONS
-- ==========================================

DELIMITER //

-- Function to get total orders for a customer
DROP FUNCTION IF EXISTS get_total_orders//
CREATE FUNCTION get_total_orders(cust_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total INT;
    SELECT COUNT(order_id)
    INTO total
    FROM orders
    WHERE customer_id = cust_id;
    RETURN IFNULL(total, 0);
END //

-- Function to get total amount spent by a customer
DROP FUNCTION IF EXISTS get_customer_spent//
CREATE FUNCTION get_customer_spent(cust_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE spent DECIMAL(10,2);
    SELECT SUM(total_amount)
    INTO spent
    FROM orders
    WHERE customer_id = cust_id;
    RETURN IFNULL(spent, 0.00);
END //

-- Function to check product availability
DROP FUNCTION IF EXISTS check_stock//
CREATE FUNCTION check_stock(prod_id INT, qty INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE current_stock INT;
    SELECT stock INTO current_stock FROM products WHERE product_id = prod_id;
    RETURN (current_stock >= qty);
END //

DELIMITER ;

-- ==========================================
-- STORED PROCEDURES
-- ==========================================

DELIMITER //

-- Procedure to add a new customer
DROP PROCEDURE IF EXISTS add_new_customer//
CREATE PROCEDURE add_new_customer(
    IN cname VARCHAR(100),
    IN cemail VARCHAR(100),
    IN cphone VARCHAR(15),
    IN caddress VARCHAR(255)
)
BEGIN
    INSERT INTO customers (name, email, phone, address)
    VALUES (cname, cemail, cphone, caddress);
END //

-- Fixed procedure to place an order (without double-counting total)
DROP PROCEDURE IF EXISTS place_order//
CREATE PROCEDURE place_order(
    IN cust_id INT,
    IN prod_id INT,
    IN qty INT
)
BEGIN
    DECLARE product_price DECIMAL(10,2);
    DECLARE new_order_id INT;
    DECLARE subtotal DECIMAL(10,2);
    DECLARE current_stock INT;

    -- Check if product exists and get price and stock
    SELECT price, stock INTO product_price, current_stock
    FROM products
    WHERE product_id = prod_id;

    -- Check if enough stock
    IF current_stock < qty THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Insufficient stock!';
    END IF;

    SET subtotal = product_price * qty;

    -- Create new order with initial total of 0 (trigger will update it)
    INSERT INTO orders (customer_id, total_amount)
    VALUES (cust_id, 0);

    SET new_order_id = LAST_INSERT_ID();

    -- Add order item (trigger will update order total)
    INSERT INTO order_items (order_id, product_id, quantity, subtotal)
    VALUES (new_order_id, prod_id, qty, subtotal);

    -- Reduce stock
    UPDATE products
    SET stock = stock - qty
    WHERE product_id = prod_id;
END //

-- Procedure to get customer order history
DROP PROCEDURE IF EXISTS get_customer_orders//
CREATE PROCEDURE get_customer_orders(IN cust_id INT)
BEGIN
    SELECT
        o.order_id,
        o.order_date,
        o.total_amount,
        o.status,
        GROUP_CONCAT(p.product_name SEPARATOR ', ') AS products
    FROM orders o
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN products p ON oi.product_id = p.product_id
    WHERE o.customer_id = cust_id
    GROUP BY o.order_id
    ORDER BY o.order_date DESC;
END //

DELIMITER ;

-- ==========================================
-- TRIGGERS
-- ==========================================

DELIMITER //

-- Trigger to update order total when order items are added
DROP TRIGGER IF EXISTS update_order_total//
CREATE TRIGGER update_order_total
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT SUM(subtotal)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END //

-- Trigger to prevent negative stock
DROP TRIGGER IF EXISTS prevent_negative_stock//
CREATE TRIGGER prevent_negative_stock
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Stock cannot be negative!';
    END IF;
END //

-- Trigger to log order deletions
DROP TRIGGER IF EXISTS log_order_deletion//
CREATE TRIGGER log_order_deletion
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_logs (order_id, action)
    VALUES (OLD.order_id, 'DELETED');
END //

-- Trigger to validate stock before inserting order items
DROP TRIGGER IF EXISTS validate_stock_before_order//
CREATE TRIGGER validate_stock_before_order
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;
    SELECT stock INTO current_stock FROM products WHERE product_id = NEW.product_id;

    IF current_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Insufficient stock for this product!';
    END IF;
END //

DELIMITER ;

-- Display all tables
SHOW TABLES;
