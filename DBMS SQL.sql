USE ecommerce;
SELECT DATABASE();
SHOW TABLES;
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock INT
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    subtotal DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
SHOW TABLES;
DESC products;
DESC orders;
USE ecommerce;
INSERT INTO customers (name, email, phone, address) VALUES
('Ravi Kumar', 'ravi@example.com', '9876543210', 'Delhi'),
('Sneha Sharma', 'sneha@example.com', '9988776655', 'Mumbai'),
('Arjun Mehta', 'arjun@example.com', '9123456789', 'Bangalore');
INSERT INTO products (product_name, category, price, stock) VALUES
('iPhone 15', 'Mobiles', 79999.00, 10),
('Samsung Galaxy S24', 'Mobiles', 69999.00, 8),
('Lenovo Laptop', 'Laptops', 55000.00, 5),
('Sony Headphones', 'Accessories', 5999.00, 20);
INSERT INTO orders (customer_id, total_amount) VALUES
(1, 85998.00),   -- Ravi
(2, 55000.00);   -- Sneha
INSERT INTO order_items (order_id, product_id, quantity, subtotal) VALUES
(1, 1, 1, 79999.00),  -- Ravi bought 1 iPhone
(1, 4, 1, 5999.00),   -- Ravi bought 1 Headphone
(2, 3, 1, 55000.00);  -- Sneha bought 1 Laptop
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT 
    o.order_id,
    c.name AS customer_name,
    o.order_date,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
SELECT 
    oi.order_id,
    p.product_name,
    oi.quantity,
    oi.subtotal
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;
UPDATE customers
SET address = 'Hyderabad'
WHERE name = 'Sneha Sharma';
UPDATE products
SET stock = stock - 1
WHERE product_id = 1;
UPDATE customers
SET address = 'Hyderabad'
WHERE name = 'Sneha Sharma';
UPDATE customers SET address = 'Hyderabad';
SELECT * FROM customers;
UPDATE customers
SET address = 'Hyderabad'
WHERE customer_id = 2;
SELECT * FROM customers;
DELETE FROM products
WHERE product_name = 'Sony Headphones';
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT 
    o.order_id,
    c.name AS customer_name,
    o.order_date,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
SELECT 
    c.name AS customer_name,
    o.order_id,
    p.product_name,
    oi.quantity,
    oi.subtotal
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id;
SELECT SUM(total_amount) AS total_revenue FROM orders;
USE ecommerce;
DELIMITER //
CREATE FUNCTION get_total_orders(cust_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(order_id)
    INTO total
    FROM orders
    WHERE customer_id = cust_id;
    RETURN total;
END //
DELIMITER ;
SELECT get_total_orders(1) AS Total_Orders_For_Ravi;
DELIMITER //
CREATE FUNCTION get_customer_spent(cust_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE spent DECIMAL(10,2);
    SELECT SUM(total_amount)
    INTO spent
    FROM orders
    WHERE customer_id = cust_id;
    RETURN IFNULL(spent, 0);
END //
DELIMITER ;
SELECT get_customer_spent(1) AS sneha_Total_Spent; //total amount spent by customer 

DELIMITER //
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
DELIMITER ;
CALL add_new_customer('Priya Nair', 'priya@example.com', '9876000111', 'Chennai');
SELECT * FROM customers;

DELIMITER //         
CREATE PROCEDURE place_order(
    IN cust_id INT,
    IN prod_id INT,
    IN qty INT
)
BEGIN
    DECLARE product_price DECIMAL(10,2);
    DECLARE new_order_id INT;
    DECLARE subtotal DECIMAL(10,2);

    -- Get product price
    SELECT price INTO product_price FROM products WHERE product_id = prod_id;

    SET subtotal = product_price * qty;

    -- Create new order
    INSERT INTO orders (customer_id, total_amount)
    VALUES (cust_id, subtotal);

    SET new_order_id = LAST_INSERT_ID();

    -- Add order item
    INSERT INTO order_items (order_id, product_id, quantity, subtotal)
    VALUES (new_order_id, prod_id, qty, subtotal);

    -- Reduce stock
    UPDATE products
    SET stock = stock - qty
    WHERE product_id = prod_id;
END //
DELIMITER ;

CALL place_order(1, 2, 1);
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM products;

DELIMITER //
CREATE TRIGGER update_order_total
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total_amount = total_amount + NEW.subtotal
    WHERE order_id = NEW.order_id;
END //
DELIMITER ;

INSERT INTO order_items (order_id, product_id, quantity, subtotal)
VALUES (1, 4, 1, 5999);
SELECT * FROM orders;

DELIMITER //
CREATE TRIGGER prevent_negative_stock
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Stock cannot be negative!';
    END IF;
END //
DELIMITER ;

UPDATE products SET stock = 5 WHERE product_id = 1;
SELECT * FROM products;   

CREATE TABLE order_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER log_order_deletion
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_logs (order_id)
    VALUES (OLD.order_id);
END //
DELIMITER ;

DELETE FROM orders WHERE order_id = 2;
SELECT * FROM order_logs;



-- Add a new order item (make sure order_id exists)
INSERT INTO order_items (order_id, product_id, quantity, subtotal)
VALUES (1, 3, 1, 2999);

-- Now check if total updated automatically
SELECT * FROM orders WHERE order_id = 1;

SELECT * FROM orders; 


