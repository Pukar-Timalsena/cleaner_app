# Safai Yojana API

Backend API for the Safai Yojana Cleaning Service mobile application built with Express.js and MongoDB.

## Features

- User authentication with JWT
- Role-based access control (Customer, Cleaner, Admin)
- Service management
- Booking system
- Task assignment for cleaners
- Review and rating system
- Admin dashboard with statistics

## Tech Stack

- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM
- **JWT** - Authentication
- **bcryptjs** - Password hashing

## Installation

1. Clone the repository and navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file in the root directory:
```bash
cp .env.example .env
```

4. Update `.env` with your configuration:
```env
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/safai_yojana
JWT_SECRET=your_jwt_secret_key_change_this_in_production
JWT_EXPIRE=7d
```

5. Ensure MongoDB is running on your system

6. Seed the database with sample data:
```bash
npm run seed
```

7. Start the development server:
```bash
npm run dev
```

The API will be available at `http://localhost:5000`

## Test Credentials

After seeding the database, you can use these credentials:

- **Customer:** user@test.com / user123
- **Admin:** admin@test.com / admin123
- **Cleaner:** cleaner@test.com / cleaner123

## API Endpoints

### Authentication
```
POST   /api/auth/register       - Register new user
POST   /api/auth/login          - Login user
GET    /api/auth/me             - Get current user (Protected)
POST   /api/auth/logout         - Logout user
```

### Users
```
GET    /api/users/:id           - Get user profile (Protected)
PUT    /api/users/:id           - Update user profile (Protected)
DELETE /api/users/:id           - Deactivate user account (Protected)
GET    /api/users/:id/bookings  - Get user's bookings (Protected)
```

### Services
```
GET    /api/services            - Get all services (Public)
GET    /api/services/:id        - Get single service (Public)
POST   /api/services            - Create service (Admin only)
PUT    /api/services/:id        - Update service (Admin only)
DELETE /api/services/:id        - Delete service (Admin only)
GET    /api/services/:id/reviews - Get service reviews (Public)
```

### Bookings
```
GET    /api/bookings            - Get all bookings (Protected, filtered by role)
GET    /api/bookings/:id        - Get single booking (Protected)
POST   /api/bookings            - Create booking (Protected)
PUT    /api/bookings/:id        - Update booking (Protected)
PUT    /api/bookings/:id/cancel - Cancel booking (Protected)
```

### Admin
```
GET    /api/admin/dashboard           - Get dashboard statistics (Admin only)
GET    /api/admin/bookings            - Get all bookings (Admin only)
PUT    /api/admin/bookings/:id/assign - Assign cleaner to booking (Admin only)
GET    /api/admin/users               - Get all users (Admin only)
GET    /api/admin/cleaners            - Get all cleaners (Admin only)
```

### Cleaners
```
GET    /api/cleaners/:id/tasks              - Get cleaner's tasks (Protected)
PUT    /api/cleaners/:id/tasks/:taskId/status - Update task status (Protected)
GET    /api/cleaners/:id/history            - Get cleaner's activity history (Protected)
GET    /api/cleaners/:id/profile            - Get cleaner profile with stats (Protected)
```

### Reviews
```
POST   /api/reviews             - Create review (Protected)
GET    /api/reviews/:id         - Get review (Protected)
PUT    /api/reviews/:id         - Update review (Protected)
DELETE /api/reviews/:id         - Delete review (Protected)
```

## Request/Response Examples

### Register User
```bash
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phone": "+977 9841234567",
  "address": "Kathmandu, Nepal",
  "role": "customer"
}
```

Response:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+977 9841234567",
    "address": "Kathmandu, Nepal",
    "role": "customer",
    "rating": 0,
    "totalJobs": 0
  }
}
```

### Login
```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@test.com",
  "password": "user123"
}
```

### Create Booking
```bash
POST /api/bookings
Authorization: Bearer <token>
Content-Type: application/json

{
  "service": "507f1f77bcf86cd799439011",
  "bookingDate": "2025-12-01",
  "bookingTime": "10:00 AM",
  "location": "Kathmandu",
  "paymentMethod": "cash",
  "subtotal": 1500,
  "discount": 0,
  "total": 1500
}
```

### Get Services
```bash
GET /api/services?category=house-cleaning
```

Response:
```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "title": "House Cleaning",
      "description": "Complete house cleaning service...",
      "category": "house-cleaning",
      "basePrice": 1500,
      "rating": 4.5,
      "reviewCount": 124,
      "estimatedTime": "2-3 hours",
      "isActive": true
    }
  ]
}
```

### Assign Cleaner (Admin)
```bash
PUT /api/admin/bookings/:id/assign
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "cleanerId": "507f1f77bcf86cd799439012"
}
```

### Update Task Status (Cleaner)
```bash
PUT /api/cleaners/:id/tasks/:taskId/status
Authorization: Bearer <cleaner_token>
Content-Type: application/json

{
  "status": "ongoing"
}
```

## Database Models

### User
- name, email, password, phone, address
- role (customer, cleaner, admin)
- profileImage, isActive
- Cleaner fields: experience, rating, totalJobs

### Service
- title, description, category, image
- basePrice, location, rating, reviewCount
- estimatedTime, isActive

### Booking
- bookingId (auto-generated: BK001, BK002, etc.)
- customer, service, cleaner (references)
- customerName, phone, address
- bookingDate, bookingTime, location
- paymentMethod, subtotal, discount, total
- status (pending, assigned, in_progress, completed, cancelled)

### Task
- booking, cleaner (references)
- title, description, location
- status (pending, ongoing, completed, cancelled)
- priority (low, medium, high)
- assignedAt, startedAt, completedAt, duration

### Review
- booking, customer, cleaner, service (references)
- rating (1-5), comment
- Auto-updates service and cleaner ratings

## Error Handling

All endpoints return consistent error responses:

```json
{
  "success": false,
  "error": "Error message here"
}
```

Common HTTP status codes:
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Server Error

## Authentication

Protected routes require a JWT token in the Authorization header:

```
Authorization: Bearer <your_token_here>
```

## Scripts

- `npm start` - Start production server
- `npm run dev` - Start development server with nodemon
- `npm run seed` - Seed database with sample data
- `npm run seed -d` - Delete all data from database

## Project Structure

```
backend/
├── config/
│   └── db.js                 # Database connection
├── controllers/
│   ├── auth.js              # Authentication logic
│   ├── users.js             # User management
│   ├── services.js          # Service management
│   ├── bookings.js          # Booking management
│   ├── admin.js             # Admin operations
│   ├── cleaners.js          # Cleaner operations
│   └── reviews.js           # Review management
├── middleware/
│   ├── auth.js              # JWT authentication & authorization
│   └── error.js             # Error handler
├── models/
│   ├── User.js              # User model
│   ├── Service.js           # Service model
│   ├── Booking.js           # Booking model
│   ├── Task.js              # Task model
│   └── Review.js            # Review model
├── routes/
│   ├── auth.js              # Auth routes
│   ├── users.js             # User routes
│   ├── services.js          # Service routes
│   ├── bookings.js          # Booking routes
│   ├── admin.js             # Admin routes
│   ├── cleaners.js          # Cleaner routes
│   └── reviews.js           # Review routes
├── seeders/
│   └── index.js             # Database seeder
├── .env.example             # Environment variables template
├── .gitignore              # Git ignore rules
├── package.json            # Dependencies
├── server.js               # App entry point
└── README.md               # Documentation
```

## Future Enhancements

- [ ] Image upload functionality for services and profiles
- [ ] Email notifications for bookings
- [ ] SMS notifications via Twilio
- [ ] Payment gateway integration (eSewa, Khalti)
- [ ] Real-time updates using Socket.io
- [ ] Advanced search and filtering
- [ ] Analytics and reporting for admin
- [ ] Push notifications
- [ ] Geolocation-based cleaner assignment

## License

ISC

## Support

For issues and questions, please contact the development team.
