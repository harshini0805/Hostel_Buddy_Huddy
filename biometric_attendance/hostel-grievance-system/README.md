# Hostel Grievance System - Phase 1: Ticket Creation (MVP)

## 🎯 Overview
A student-identified ticket creation system for hostel grievances that auto-fills student info, captures impact & urgency, assigns vendors automatically, and stores structured data for future voting & prioritization.

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter
- **Backend**: Python (FastAPI)
- **Database**: MongoDB

### Features Implemented ✅
- ✅ Student auto-filled ticket creation form
- ✅ Issue category selection (6 categories)
- ✅ Impact radius tracking (Room/Floor/Hostel)
- ✅ Urgency level assessment (Low/Medium/High)
- ✅ Description validation (min 30 chars)
- ✅ Automatic vendor assignment
- ✅ Priority score calculation
- ✅ MongoDB storage with proper schema
- ✅ Auto-voting (student votes for their own ticket)

### Features NOT in Phase 1 🚫
- ❌ Voting UI
- ❌ Ticket feed
- ❌ Staff dashboard
- ❌ NLP similarity detection
- ❌ Notifications
- ❌ Media upload functionality

---

## 🚀 Setup Instructions

### Prerequisites
- Python 3.9+
- Flutter 3.0+
- MongoDB 4.4+
- Node.js (optional, for MongoDB Compass)

---

### Backend Setup

#### 1. Navigate to backend directory
```bash
cd backend
```

#### 2. Create virtual environment
```bash
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate
```

#### 3. Install dependencies
```bash
pip install -r requirements.txt
```

#### 4. Configure environment variables
```bash
# Copy the example env file
cp .env.example .env

# Edit .env and update MongoDB URL if needed
# Default: MONGODB_URL=mongodb://localhost:27017
```

#### 5. Start MongoDB
```bash
# If using local MongoDB
mongod --dbpath /path/to/your/data/directory

# Or if using Docker
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

#### 6. Run the backend server
```bash
python main.py

# Or using uvicorn directly
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The backend will be available at: `http://localhost:8000`

#### 7. Verify backend is running
Open browser and navigate to:
- API Docs: `http://localhost:8000/docs`
- Health Check: `http://localhost:8000/health`

---

### Frontend Setup

#### 1. Navigate to Flutter app directory
```bash
cd flutter_app
```

#### 2. Install Flutter dependencies
```bash
flutter pub get
```

#### 3. Update API endpoint (if needed)
Edit `lib/services/ticket_service.dart` and update the `baseUrl`:

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000';

// For iOS Simulator
static const String baseUrl = 'http://localhost:8000';

// For Real Device (use your computer's IP)
static const String baseUrl = 'http://192.168.1.xxx:8000';
```

#### 4. Run the Flutter app
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Or run on Chrome (for web testing)
flutter run -d chrome
```

---

## 📊 Database Schema

### Collection: `tickets`

```javascript
{
  "_id": ObjectId("..."),
  "student": {
    "id": "STU2024001",
    "name": "Rahul Kumar",
    "department": "Computer Science"
  },
  "location": {
    "hostel": "H1",
    "block": "B",
    "floor": 3,
    "room": "312"
  },
  "category": "plumbing",           // electrical, plumbing, civil, internet, safety, other
  "impact_radius": "floor",         // room, floor, hostel
  "urgency": "high",                // low, medium, high
  "description": "Water leaking continuously in bathroom near room 312",
  "media_urls": [],
  "assigned_vendor": "PLUMBING_VENDOR",
  "status": "submitted",
  "priority_score": 6,              // urgency_weight × impact_weight
  "votes": {
    "count": 1,
    "voters": ["STU2024001"]
  },
  "created_at": ISODate("2024-02-01T10:30:00Z"),
  "updated_at": ISODate("2024-02-01T10:30:00Z")
}
```

### Indexes Created
- `student.id`
- `status`
- `priority_score`
- `created_at`

---

## 🔧 API Endpoints

### 1. Create Ticket
**POST** `/tickets`

**Request Body:**
```json
{
  "category": "plumbing",
  "impact_radius": "floor",
  "urgency": "high",
  "description": "Water leaking continuously in bathroom near room 312",
  "media_urls": []
}
```

**Response:** `201 Created`
```json
{
  "id": "65b3f2a8c9e4b1a2d3e4f5a6",
  "student": {
    "id": "STU2024001",
    "name": "Rahul Kumar",
    "department": "Computer Science"
  },
  "location": {
    "hostel": "H1",
    "block": "B",
    "floor": 3,
    "room": "312"
  },
  "category": "plumbing",
  "impact_radius": "floor",
  "urgency": "high",
  "description": "Water leaking continuously in bathroom near room 312",
  "media_urls": [],
  "assigned_vendor": "PLUMBING_VENDOR",
  "status": "submitted",
  "priority_score": 6,
  "votes": {
    "count": 1,
    "voters": ["STU2024001"]
  },
  "created_at": "2024-02-01T10:30:00Z",
  "updated_at": "2024-02-01T10:30:00Z"
}
```

### 2. Health Check
**GET** `/health`

**Response:** `200 OK`
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2024-02-01T10:30:00Z"
}
```

---

## 📐 Business Logic

### Vendor Assignment
```python
VENDOR_MAP = {
  "electrical": "ELECTRICAL_VENDOR",
  "plumbing": "PLUMBING_VENDOR",
  "civil": "CIVIL_VENDOR",
  "internet": "INTERNET_VENDOR",
  "safety": "SECURITY",
  "other": "GENERAL_MAINTENANCE"
}
```

### Priority Score Calculation
```
priority_score = urgency_weight × impact_weight

Urgency Weights:
- low    = 1
- medium = 2
- high   = 3

Impact Weights:
- room   = 1
- floor  = 2
- hostel = 3

Example:
high urgency + floor impact = 3 × 2 = 6
```

---

## 🧪 Testing

### Backend Testing

#### Test with curl
```bash
# Health check
curl http://localhost:8000/health

# Create ticket
curl -X POST http://localhost:8000/tickets \
  -H "Content-Type: application/json" \
  -d '{
    "category": "plumbing",
    "impact_radius": "floor",
    "urgency": "high",
    "description": "Water leaking continuously in bathroom near room 312",
    "media_urls": []
  }'
```

#### Test with Postman
1. Import the API from Swagger docs: `http://localhost:8000/docs`
2. Create a POST request to `/tickets`
3. Add JSON body with required fields
4. Send request

### Frontend Testing
1. Run the app on emulator/simulator
2. Navigate to Create Ticket screen
3. Verify student info is auto-filled
4. Fill in all required fields
5. Submit ticket
6. Check MongoDB for created ticket

---

## 📁 Project Structure

```
hostel-grievance-system/
├── backend/
│   ├── main.py                 # FastAPI application
│   ├── requirements.txt        # Python dependencies
│   └── .env.example           # Environment variables template
│
└── flutter_app/
    ├── lib/
    │   ├── main.dart          # App entry point
    │   ├── models/
    │   │   └── ticket_models.dart    # Data models
    │   ├── providers/
    │   │   └── student_provider.dart # State management
    │   ├── screens/
    │   │   └── create_ticket_screen.dart
    │   └── services/
    │       └── ticket_service.dart   # API client
    └── pubspec.yaml           # Flutter dependencies
```

---

## 🐛 Troubleshooting

### Backend Issues

**MongoDB Connection Error**
```
Solution: Ensure MongoDB is running on port 27017
Check: mongod --version
Start: mongod --dbpath /path/to/data
```

**Port 8000 Already in Use**
```
Solution: Kill the process or use a different port
uvicorn main:app --reload --port 8001
```

### Frontend Issues

**Cannot Connect to Backend**
```
Solution: Update baseUrl in ticket_service.dart
- Android Emulator: http://10.0.2.2:8000
- iOS Simulator: http://localhost:8000
- Real Device: http://<YOUR_IP>:8000
```

**Provider Error**
```
Solution: Ensure Provider package is installed
flutter pub get
flutter clean
flutter pub get
```

---

## ✅ Acceptance Criteria

Phase 1 is complete when:

- [x] A logged-in student can submit a ticket
- [x] Student details are auto-filled correctly
- [x] All input fields validate properly
- [x] Ticket is stored in MongoDB with correct schema
- [x] Vendor is assigned automatically based on category
- [x] Priority score is calculated correctly
- [x] Student automatically votes for their own ticket (count: 1)
- [x] Success/error messages display appropriately
- [x] API returns proper HTTP status codes

---

## 🔮 Next Steps (Phase 2+)

After Phase 1 is validated:
1. Implement voting UI for students
2. Build ticket feed/list view
3. Create staff/admin dashboard
4. Add NLP for similar ticket detection
5. Implement notification system
6. Add media upload functionality
7. Build analytics & reporting

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review API documentation at `/docs`
3. Verify MongoDB connection and data
4. Check Flutter logs: `flutter logs`
5. Check backend logs in terminal

---

## 📄 License

This is a Phase 1 MVP implementation. Update license as needed.
