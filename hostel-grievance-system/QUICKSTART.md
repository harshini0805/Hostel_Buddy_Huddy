# 🚀 Quick Start Guide - Hostel Grievance System (Phase 1)

## ⚡ Fastest Way to Get Started

### Option 1: Using Docker (Recommended)

```bash
# Clone/navigate to project directory
cd hostel-grievance-system

# Start all services
docker-compose up -d

# Check if services are running
docker-compose ps

# View logs
docker-compose logs -f backend

# Test the API
curl http://localhost:8000/health
```

**Access the API:** http://localhost:8000/docs

---

### Option 2: Manual Setup

#### Step 1: Start MongoDB (Terminal 1)
```bash
# Using local MongoDB
mongod

# OR using Docker
docker run -d -p 27017:27017 mongo:latest
```

#### Step 2: Start Backend (Terminal 2)
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

**Backend running at:** http://localhost:8000

#### Step 3: Run Flutter App (Terminal 3)
```bash
cd flutter_app
flutter pub get
flutter run
```

---

## 🧪 Test the System

### Using the Test Script
```bash
cd backend
python test_api.py
```

### Using curl
```bash
# Create a ticket
curl -X POST http://localhost:8000/tickets \
  -H "Content-Type: application/json" \
  -d '{
    "category": "plumbing",
    "impact_radius": "floor",
    "urgency": "high",
    "description": "Water leaking from ceiling in room 312 bathroom. Affecting rooms below as well.",
    "media_urls": []
  }'
```

### Using the Flutter App
1. Launch the app
2. Tap "Create New Ticket"
3. Fill in the form:
   - Category: Select from dropdown
   - Impact: Choose room/floor/hostel
   - Urgency: Select low/medium/high
   - Description: Enter at least 30 characters
4. Tap "Submit Ticket"
5. Check success message

---

## 📊 Verify Data in MongoDB

```bash
# Connect to MongoDB
mongo

# Or using MongoDB Compass
# Connect to: mongodb://localhost:27017

# View tickets
use hostel_grievance
db.tickets.find().pretty()

# Count tickets
db.tickets.count()

# Find high priority tickets
db.tickets.find({ urgency: "high" }).pretty()
```

---

## 🎯 What to Test

### Priority Score Calculation
- **High urgency + Hostel impact** = 9 (highest)
- **High urgency + Floor impact** = 6
- **Medium urgency + Floor impact** = 4
- **Low urgency + Room impact** = 1 (lowest)

### Vendor Assignment
- Electrical → ELECTRICAL_VENDOR
- Plumbing → PLUMBING_VENDOR
- Civil → CIVIL_VENDOR
- Internet → INTERNET_VENDOR
- Safety → SECURITY
- Other → GENERAL_MAINTENANCE

### Auto-Voting
- Every created ticket should have `votes.count = 1`
- Creator's student ID should be in `votes.voters` array

---

## ❓ Common Issues & Fixes

**Backend won't start**
```bash
# Check if port 8000 is free
lsof -i :8000
# Kill existing process if needed
kill -9 <PID>
```

**MongoDB connection failed**
```bash
# Check if MongoDB is running
pgrep mongod
# Start MongoDB
mongod
```

**Flutter can't connect to backend**
```dart
// Update in lib/services/ticket_service.dart
// For Android Emulator:
static const String baseUrl = 'http://10.0.2.2:8000';
```

---

## ✅ Success Checklist

- [ ] Backend API running at http://localhost:8000
- [ ] MongoDB running on port 27017
- [ ] API docs accessible at http://localhost:8000/docs
- [ ] Health check returns "healthy" status
- [ ] Flutter app launches without errors
- [ ] Can create tickets via app
- [ ] Tickets appear in MongoDB
- [ ] Priority scores calculated correctly
- [ ] Vendors assigned correctly
- [ ] Auto-voting works (count = 1)

---

## 📞 Need Help?

1. Check the main README.md for detailed documentation
2. Review API docs at http://localhost:8000/docs
3. Run the test script: `python backend/test_api.py`
4. Check logs in terminal windows
5. Verify MongoDB data: `mongo hostel_grievance`

---

## 🎉 You're Ready!

Once all checklist items are complete, you've successfully set up Phase 1 MVP!

**Next:** Start implementing Phase 2 features (voting, feed, dashboard)
