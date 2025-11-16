const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../frontend')));

// Database connection
const db = mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'ecommerce'
});

// Connect to database
db.connect((err) => {
    if (err) {
        console.error('Error connecting to database:', err);
        console.log('Please make sure MySQL is running and the database is created.');
    } else {
        console.log('Connected to MySQL database');
    }
});

// ==========================================
// API ROUTES
// ==========================================

// Get all products
app.get('/api/products', (req, res) => {
    const query = 'SELECT * FROM products WHERE stock > 0 ORDER BY created_at DESC';
    db.query(query, (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.json(results);
        }
    });
});

// Get product by ID
app.get('/api/products/:id', (req, res) => {
    const query = 'SELECT * FROM products WHERE product_id = ?';
    db.query(query, [req.params.id], (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else if (results.length === 0) {
            res.status(404).json({ error: 'Product not found' });
        } else {
            res.json(results[0]);
        }
    });
});

// Get products by category
app.get('/api/products/category/:category', (req, res) => {
    const query = 'SELECT * FROM products WHERE category = ? AND stock > 0';
    db.query(query, [req.params.category], (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.json(results);
        }
    });
});

// Get all categories
app.get('/api/categories', (req, res) => {
    const query = 'SELECT DISTINCT category FROM products ORDER BY category';
    db.query(query, (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.json(results.map(r => r.category));
        }
    });
});

// Get all customers
app.get('/api/customers', (req, res) => {
    const query = 'SELECT * FROM customers ORDER BY created_at DESC';
    db.query(query, (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.json(results);
        }
    });
});

// Get customer by ID
app.get('/api/customers/:id', (req, res) => {
    const query = 'SELECT * FROM customers WHERE customer_id = ?';
    db.query(query, [req.params.id], (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else if (results.length === 0) {
            res.status(404).json({ error: 'Customer not found' });
        } else {
            res.json(results[0]);
        }
    });
});

// Add new customer
app.post('/api/customers', (req, res) => {
    const { name, email, phone, address } = req.body;
    const query = 'CALL add_new_customer(?, ?, ?, ?)';

    db.query(query, [name, email, phone, address], (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.status(201).json({ message: 'Customer added successfully', customerId: results.insertId });
        }
    });
});

// Get all orders
app.get('/api/orders', (req, res) => {
    const query = `
        SELECT
            o.order_id,
            o.customer_id,
            c.name AS customer_name,
            o.order_date,
            o.total_amount,
            o.status
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        ORDER BY o.order_date DESC
    `;

    db.query(query, (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.json(results);
        }
    });
});

// Get order by ID with items
app.get('/api/orders/:id', (req, res) => {
    const orderQuery = `
        SELECT
            o.order_id,
            o.customer_id,
            c.name AS customer_name,
            c.email,
            c.phone,
            c.address,
            o.order_date,
            o.total_amount,
            o.status
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.order_id = ?
    `;

    const itemsQuery = `
        SELECT
            oi.item_id,
            oi.product_id,
            p.product_name,
            p.price,
            oi.quantity,
            oi.subtotal
        FROM order_items oi
        JOIN products p ON oi.product_id = p.product_id
        WHERE oi.order_id = ?
    `;

    db.query(orderQuery, [req.params.id], (err, orderResults) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else if (orderResults.length === 0) {
            res.status(404).json({ error: 'Order not found' });
        } else {
            db.query(itemsQuery, [req.params.id], (err, itemsResults) => {
                if (err) {
                    res.status(500).json({ error: err.message });
                } else {
                    res.json({
                        ...orderResults[0],
                        items: itemsResults
                    });
                }
            });
        }
    });
});

// Get customer orders
app.get('/api/customers/:id/orders', (req, res) => {
    const query = 'CALL get_customer_orders(?)';

    db.query(query, [req.params.id], (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.json(results[0]);
        }
    });
});

// Get customer statistics
app.get('/api/customers/:id/stats', (req, res) => {
    const totalOrdersQuery = 'SELECT get_total_orders(?) AS total_orders';
    const totalSpentQuery = 'SELECT get_customer_spent(?) AS total_spent';

    db.query(totalOrdersQuery, [req.params.id], (err, ordersResult) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            db.query(totalSpentQuery, [req.params.id], (err, spentResult) => {
                if (err) {
                    res.status(500).json({ error: err.message });
                } else {
                    res.json({
                        total_orders: ordersResult[0].total_orders,
                        total_spent: spentResult[0].total_spent
                    });
                }
            });
        }
    });
});

// Place an order
app.post('/api/orders', (req, res) => {
    const { customer_id, product_id, quantity } = req.body;

    if (!customer_id || !product_id || !quantity) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const query = 'CALL place_order(?, ?, ?)';

    db.query(query, [customer_id, product_id, quantity], (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.status(201).json({ message: 'Order placed successfully' });
        }
    });
});

// Place order with multiple items
app.post('/api/orders/multi', (req, res) => {
    const { customer_id, items } = req.body;

    if (!customer_id || !items || items.length === 0) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    db.beginTransaction((err) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        // Create order
        const createOrderQuery = 'INSERT INTO orders (customer_id, total_amount) VALUES (?, 0)';
        db.query(createOrderQuery, [customer_id], (err, result) => {
            if (err) {
                return db.rollback(() => {
                    res.status(500).json({ error: err.message });
                });
            }

            const orderId = result.insertId;
            let completed = 0;
            let hasError = false;

            // Add each item
            items.forEach((item) => {
                const { product_id, quantity } = item;

                // Get product price
                const priceQuery = 'SELECT price, stock FROM products WHERE product_id = ?';
                db.query(priceQuery, [product_id], (err, priceResult) => {
                    if (err || hasError) {
                        hasError = true;
                        return;
                    }

                    if (priceResult.length === 0 || priceResult[0].stock < quantity) {
                        hasError = true;
                        return db.rollback(() => {
                            res.status(400).json({ error: 'Product not available or insufficient stock' });
                        });
                    }

                    const subtotal = priceResult[0].price * quantity;

                    // Insert order item
                    const itemQuery = 'INSERT INTO order_items (order_id, product_id, quantity, subtotal) VALUES (?, ?, ?, ?)';
                    db.query(itemQuery, [orderId, product_id, quantity, subtotal], (err) => {
                        if (err || hasError) {
                            hasError = true;
                            return;
                        }

                        // Update stock
                        const updateStockQuery = 'UPDATE products SET stock = stock - ? WHERE product_id = ?';
                        db.query(updateStockQuery, [quantity, product_id], (err) => {
                            if (err || hasError) {
                                hasError = true;
                                return;
                            }

                            completed++;

                            if (completed === items.length && !hasError) {
                                db.commit((err) => {
                                    if (err) {
                                        return db.rollback(() => {
                                            res.status(500).json({ error: err.message });
                                        });
                                    }
                                    res.status(201).json({
                                        message: 'Order placed successfully',
                                        orderId: orderId
                                    });
                                });
                            }
                        });
                    });
                });
            });
        });
    });
});

// Update order status
app.patch('/api/orders/:id/status', (req, res) => {
    const { status } = req.body;
    const query = 'UPDATE orders SET status = ? WHERE order_id = ?';

    db.query(query, [status, req.params.id], (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else if (results.affectedRows === 0) {
            res.status(404).json({ error: 'Order not found' });
        } else {
            res.json({ message: 'Order status updated successfully' });
        }
    });
});

// Get dashboard stats
app.get('/api/stats', (req, res) => {
    const queries = {
        totalRevenue: 'SELECT SUM(total_amount) AS total_revenue FROM orders',
        totalOrders: 'SELECT COUNT(*) AS total_orders FROM orders',
        totalCustomers: 'SELECT COUNT(*) AS total_customers FROM customers',
        totalProducts: 'SELECT COUNT(*) AS total_products FROM products',
        lowStock: 'SELECT COUNT(*) AS low_stock FROM products WHERE stock < 5'
    };

    const stats = {};
    let completed = 0;

    Object.keys(queries).forEach(key => {
        db.query(queries[key], (err, results) => {
            if (!err) {
                stats[key] = results[0][Object.keys(results[0])[0]];
            }
            completed++;

            if (completed === Object.keys(queries).length) {
                res.json(stats);
            }
        });
    });
});

// Serve frontend
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

// Start server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
    console.log(`Visit http://localhost:${PORT} to view the application`);
});
