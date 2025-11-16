// API Base URL
const API_URL = 'http://localhost:3000/api';

// Shopping cart
let cart = [];

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    setupNavigation();
    loadStats();
    loadCategories();
    loadProducts();
    loadOrders();
    loadCustomers();
    loadCart();
    setupForms();
});

// Navigation
function setupNavigation() {
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const page = e.target.dataset.page;
            showPage(page);
        });
    });
}

function showPage(pageName) {
    // Hide all pages
    document.querySelectorAll('.page').forEach(page => {
        page.classList.remove('active');
    });

    // Show selected page
    document.getElementById(`${pageName}-page`).classList.add('active');

    // Update nav links
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
        if (link.dataset.page === pageName) {
            link.classList.add('active');
        }
    });

    // Load page data
    if (pageName === 'home') {
        loadStats();
        loadCategories();
    } else if (pageName === 'products') {
        loadProducts();
    } else if (pageName === 'orders') {
        loadOrders();
    } else if (pageName === 'customers') {
        loadCustomers();
    } else if (pageName === 'cart') {
        renderCart();
    }
}

// Load Dashboard Stats
async function loadStats() {
    try {
        const response = await fetch(`${API_URL}/stats`);
        const stats = await response.json();

        document.getElementById('stat-revenue').textContent = `₹${formatNumber(stats.totalRevenue || 0)}`;
        document.getElementById('stat-orders').textContent = stats.totalOrders || 0;
        document.getElementById('stat-customers').textContent = stats.totalCustomers || 0;
        document.getElementById('stat-products').textContent = stats.totalProducts || 0;
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

// Load Categories
async function loadCategories() {
    try {
        const response = await fetch(`${API_URL}/categories`);
        const categories = await response.json();

        const categoriesList = document.getElementById('categories-list');
        const categoryFilter = document.getElementById('category-filter');

        categoriesList.innerHTML = '';
        categoryFilter.innerHTML = '<option value="">All Categories</option>';

        categories.forEach(category => {
            // Category cards
            const card = document.createElement('div');
            card.className = 'category-card';
            card.innerHTML = `<h4>${category}</h4>`;
            card.onclick = () => filterByCategory(category);
            categoriesList.appendChild(card);

            // Filter dropdown
            const option = document.createElement('option');
            option.value = category;
            option.textContent = category;
            categoryFilter.appendChild(option);
        });

        // Category filter change event
        categoryFilter.addEventListener('change', (e) => {
            filterByCategory(e.target.value);
        });
    } catch (error) {
        console.error('Error loading categories:', error);
    }
}

// Filter products by category
function filterByCategory(category) {
    showPage('products');
    document.getElementById('category-filter').value = category;
    loadProducts(category);
}

// Load Products
async function loadProducts(category = '') {
    try {
        const url = category
            ? `${API_URL}/products/category/${category}`
            : `${API_URL}/products`;

        const response = await fetch(url);
        const products = await response.json();

        const productsList = document.getElementById('products-list');
        productsList.innerHTML = '';

        if (products.length === 0) {
            productsList.innerHTML = '<p class="empty-message">No products found</p>';
            return;
        }

        products.forEach(product => {
            const card = document.createElement('div');
            card.className = 'product-card';
            card.innerHTML = `
                <div class="product-image">🛍️</div>
                <div class="product-info">
                    <h3>${product.product_name}</h3>
                    <p class="product-category">${product.category}</p>
                    ${product.description ? `<p class="product-description">${product.description}</p>` : ''}
                    <p class="product-price">₹${formatNumber(product.price)}</p>
                    <p class="product-stock">Stock: ${product.stock}</p>
                    <div class="product-actions">
                        <button class="btn btn-primary btn-small" onclick="addToCart(${product.product_id}, '${product.product_name}', ${product.price})">
                            Add to Cart
                        </button>
                    </div>
                </div>
            `;
            productsList.appendChild(card);
        });
    } catch (error) {
        console.error('Error loading products:', error);
    }
}

// Load Orders
async function loadOrders() {
    try {
        const response = await fetch(`${API_URL}/orders`);
        const orders = await response.json();

        const ordersList = document.getElementById('orders-list');
        ordersList.innerHTML = '';

        if (orders.length === 0) {
            ordersList.innerHTML = '<p class="empty-message">No orders found</p>';
            return;
        }

        orders.forEach(order => {
            const card = document.createElement('div');
            card.className = 'order-card';
            card.innerHTML = `
                <div class="order-header">
                    <div class="order-info">
                        <h4>Order #${order.order_id}</h4>
                        <p>Customer: ${order.customer_name}</p>
                        <p>Date: ${new Date(order.order_date).toLocaleDateString()}</p>
                    </div>
                    <div>
                        <span class="order-status status-${order.status}">${order.status.toUpperCase()}</span>
                        <p class="order-total">₹${formatNumber(order.total_amount)}</p>
                    </div>
                </div>
            `;
            ordersList.appendChild(card);
        });
    } catch (error) {
        console.error('Error loading orders:', error);
    }
}

// Load Customers
async function loadCustomers() {
    try {
        const response = await fetch(`${API_URL}/customers`);
        const customers = await response.json();

        const customersList = document.getElementById('customers-list');
        customersList.innerHTML = '';

        if (customers.length === 0) {
            customersList.innerHTML = '<p class="empty-message">No customers found</p>';
            return;
        }

        for (const customer of customers) {
            // Get customer stats
            const statsResponse = await fetch(`${API_URL}/customers/${customer.customer_id}/stats`);
            const stats = await statsResponse.json();

            const card = document.createElement('div');
            card.className = 'customer-card';
            card.innerHTML = `
                <h4>${customer.name}</h4>
                <div class="customer-info">
                    <p>📧 ${customer.email}</p>
                    <p>📱 ${customer.phone}</p>
                    <p>📍 ${customer.address}</p>
                </div>
                <div class="customer-stats">
                    <div class="customer-stat">
                        <strong>${stats.total_orders}</strong>
                        <span>Orders</span>
                    </div>
                    <div class="customer-stat">
                        <strong>₹${formatNumber(stats.total_spent)}</strong>
                        <span>Spent</span>
                    </div>
                </div>
            `;
            customersList.appendChild(card);
        }
    } catch (error) {
        console.error('Error loading customers:', error);
    }
}

// Shopping Cart Functions
function loadCart() {
    const savedCart = localStorage.getItem('cart');
    if (savedCart) {
        cart = JSON.parse(savedCart);
        updateCartCount();
    }
}

function saveCart() {
    localStorage.setItem('cart', JSON.stringify(cart));
    updateCartCount();
}

function updateCartCount() {
    const count = cart.reduce((sum, item) => sum + item.quantity, 0);
    document.getElementById('cart-count').textContent = count;
}

function addToCart(productId, productName, price) {
    const existingItem = cart.find(item => item.productId === productId);

    if (existingItem) {
        existingItem.quantity++;
    } else {
        cart.push({
            productId,
            productName,
            price,
            quantity: 1
        });
    }

    saveCart();
    showNotification('Product added to cart!');
}

function removeFromCart(productId) {
    cart = cart.filter(item => item.productId !== productId);
    saveCart();
    renderCart();
}

function updateQuantity(productId, change) {
    const item = cart.find(item => item.productId === productId);
    if (item) {
        item.quantity += change;
        if (item.quantity <= 0) {
            removeFromCart(productId);
        } else {
            saveCart();
            renderCart();
        }
    }
}

function clearCart() {
    if (confirm('Are you sure you want to clear the cart?')) {
        cart = [];
        saveCart();
        renderCart();
    }
}

function renderCart() {
    const cartItems = document.getElementById('cart-items');
    const cartTotal = document.getElementById('cart-total');

    if (cart.length === 0) {
        cartItems.innerHTML = '<p class="empty-message">Your cart is empty</p>';
        cartTotal.textContent = '0';
        return;
    }

    cartItems.innerHTML = cart.map(item => `
        <div class="cart-item">
            <div class="cart-item-info">
                <h4>${item.productName}</h4>
                <p>₹${formatNumber(item.price)} each</p>
            </div>
            <div class="cart-item-quantity">
                <div class="quantity-controls">
                    <button class="quantity-btn" onclick="updateQuantity(${item.productId}, -1)">-</button>
                    <span>${item.quantity}</span>
                    <button class="quantity-btn" onclick="updateQuantity(${item.productId}, 1)">+</button>
                </div>
                <p class="cart-item-price">₹${formatNumber(item.price * item.quantity)}</p>
                <button class="btn btn-secondary btn-small" onclick="removeFromCart(${item.productId})">Remove</button>
            </div>
        </div>
    `).join('');

    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    cartTotal.textContent = formatNumber(total);
}

// Modal Functions
function showAddCustomerModal() {
    document.getElementById('add-customer-modal').classList.add('active');
}

async function showCheckoutModal() {
    if (cart.length === 0) {
        alert('Your cart is empty!');
        return;
    }

    // Load customers for dropdown
    try {
        const response = await fetch(`${API_URL}/customers`);
        const customers = await response.json();

        const select = document.getElementById('checkout-customer-select');
        select.innerHTML = '<option value="">-- Select Customer --</option>';

        customers.forEach(customer => {
            const option = document.createElement('option');
            option.value = customer.customer_id;
            option.textContent = customer.name;
            select.appendChild(option);
        });

        // Render checkout items
        const checkoutItems = document.getElementById('checkout-items');
        checkoutItems.innerHTML = cart.map(item => `
            <div class="checkout-item">
                <span>${item.productName} x ${item.quantity}</span>
                <span>₹${formatNumber(item.price * item.quantity)}</span>
            </div>
        `).join('');

        const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        document.getElementById('checkout-total').textContent = formatNumber(total);

        document.getElementById('checkout-modal').classList.add('active');
    } catch (error) {
        console.error('Error loading customers:', error);
        alert('Error loading customers');
    }
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}

// Form Setup
function setupForms() {
    // Add Customer Form
    document.getElementById('add-customer-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = Object.fromEntries(formData);

        try {
            const response = await fetch(`${API_URL}/customers`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                showNotification('Customer added successfully!');
                closeModal('add-customer-modal');
                e.target.reset();
                loadCustomers();
            } else {
                const error = await response.json();
                alert('Error: ' + error.error);
            }
        } catch (error) {
            console.error('Error adding customer:', error);
            alert('Error adding customer');
        }
    });

    // Checkout Form
    document.getElementById('checkout-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const customerId = formData.get('customer_id');

        if (!customerId) {
            alert('Please select a customer');
            return;
        }

        const orderData = {
            customer_id: parseInt(customerId),
            items: cart.map(item => ({
                product_id: item.productId,
                quantity: item.quantity
            }))
        };

        try {
            const response = await fetch(`${API_URL}/orders/multi`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(orderData)
            });

            if (response.ok) {
                showNotification('Order placed successfully!');
                closeModal('checkout-modal');
                clearCart();
                loadOrders();
                loadStats();
            } else {
                const error = await response.json();
                alert('Error: ' + error.error);
            }
        } catch (error) {
            console.error('Error placing order:', error);
            alert('Error placing order');
        }
    });
}

// Utility Functions
function formatNumber(num) {
    return parseFloat(num).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function showNotification(message) {
    // Create notification element
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 80px;
        right: 20px;
        background-color: #27ae60;
        color: white;
        padding: 1rem 2rem;
        border-radius: 5px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.2);
        z-index: 10000;
        animation: slideIn 0.3s ease-out;
    `;
    notification.textContent = message;

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.remove();
    }, 3000);
}

// Close modal when clicking outside
window.onclick = function(event) {
    if (event.target.classList.contains('modal')) {
        event.target.classList.remove('active');
    }
}
