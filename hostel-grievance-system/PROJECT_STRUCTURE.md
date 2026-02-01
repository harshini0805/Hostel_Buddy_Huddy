# Project Structure

```
hostel-grievance-system/
│
├── README.md                          # Complete documentation
├── QUICKSTART.md                      # Quick setup guide
├── API_DOCUMENTATION.md               # API reference
├── docker-compose.yml                 # Docker orchestration
├── .gitignore                         # Git ignore rules
│
├── backend/                           # Python FastAPI Backend
│   ├── main.py                        # FastAPI application
│   ├── requirements.txt               # Python dependencies
│   ├── .env.example                   # Environment template
│   ├── Dockerfile                     # Docker image config
│   └── test_api.py                    # API test suite
│
└── flutter_app/                       # Flutter Frontend
    ├── pubspec.yaml                   # Flutter dependencies
    └── lib/
        ├── main.dart                  # App entry point
        │
        ├── models/                    # Data Models
        │   └── ticket_models.dart     # Ticket-related models
        │
        ├── providers/                 # State Management
        │   └── student_provider.dart  # Student state
        │
        ├── screens/                   # UI Screens
        │   └── create_ticket_screen.dart
        │
        └── services/                  # API Services
            └── ticket_service.dart    # Ticket API client
```

## File Descriptions

### Root Level

**README.md**
- Complete project documentation
- Setup instructions for backend and frontend
- Database schema
- Business logic explanation
- Troubleshooting guide

**QUICKSTART.md**
- Minimal setup steps
- Docker commands
- Quick testing guide
- Common issues

**API_DOCUMENTATION.md**
- API endpoints reference
- Request/response examples
- Data models
- Error handling
- Use cases

**docker-compose.yml**
- MongoDB service
- Backend service
- Network configuration
- Volume management

**.gitignore**
- Python excludes
- Flutter excludes
- Environment files
- IDE files

### Backend Files

**main.py** (350 lines)
- FastAPI application setup
- MongoDB connection
- POST /tickets endpoint
- GET /health endpoint
- Vendor assignment logic
- Priority calculation
- Data validation
- Error handling

**requirements.txt**
- fastapi
- uvicorn
- motor (async MongoDB)
- pydantic
- python-multipart
- python-dotenv

**.env.example**
- MongoDB URL template
- Database name
- JWT secret placeholder

**Dockerfile**
- Python 3.11 base image
- Dependency installation
- App setup
- Port exposure

**test_api.py**
- Health check test
- 5 ticket creation tests
- Different priority scenarios
- Summary report

### Frontend Files

**pubspec.yaml**
- provider (state management)
- http (API calls)
- Flutter SDK config

**main.dart** (100 lines)
- App initialization
- Provider setup
- Theme configuration
- Home screen
- Navigation

**ticket_models.dart** (220 lines)
- IssueCategory enum
- ImpactRadius enum
- UrgencyLevel enum
- TicketStatus enum
- Student model
- CreateTicketRequest model
- TicketResponse model
- JSON serialization

**student_provider.dart** (30 lines)
- Student state management
- Mock login
- Session handling

**create_ticket_screen.dart** (400 lines)
- Auto-filled student info card
- Category dropdown
- Impact radio buttons
- Urgency level selector
- Description text field
- Form validation
- Submit button
- Loading states
- Error handling
- Success messages

**ticket_service.dart** (60 lines)
- Base URL configuration
- createTicket() API call
- healthCheck() API call
- HTTP client setup
- Error handling
- JSON parsing

## Component Flow

```
User Interaction
      ↓
CreateTicketScreen (UI)
      ↓
FormValidation
      ↓
StudentProvider (State)
      ↓
TicketService (HTTP)
      ↓
FastAPI Backend
      ↓
MongoDB Storage
```

## Data Flow

```
1. Student opens app
   → StudentProvider loads mock data
   → CreateTicketScreen displays auto-filled info

2. Student fills form
   → Local validation
   → Enable/disable submit button

3. Student submits
   → Create CreateTicketRequest
   → TicketService.createTicket()
   → POST /tickets
   
4. Backend processes
   → Authenticate (mock)
   → Fetch student details
   → Assign vendor
   → Calculate priority
   → Store in MongoDB
   → Return TicketResponse

5. Frontend receives response
   → Parse JSON
   → Show success message
   → Clear form
   → Ready for next ticket
```

## Key Features by File

### Backend (main.py)
✅ Enum definitions
✅ Request/Response models
✅ MongoDB connection
✅ Vendor mapping logic
✅ Priority calculation
✅ Auto-voting
✅ Timestamp handling
✅ Error responses

### Frontend (create_ticket_screen.dart)
✅ Auto-filled student card
✅ Category dropdown
✅ Impact radio group
✅ Urgency selector (colored)
✅ Description validation
✅ Submit button states
✅ Loading indicator
✅ Success/error messages
✅ Form reset

## Testing Coverage

### Backend Tests (test_api.py)
1. Health check
2. High priority plumbing (hostel-wide)
3. Medium priority electrical (floor-wide)
4. Low priority civil (single room)
5. High priority safety (hostel-wide)
6. Medium priority internet (floor-wide)

### Manual Testing
- Form validation
- Network errors
- MongoDB connection
- Priority calculation
- Vendor assignment
- Auto-voting

## Next Steps

After Phase 1 is working:
1. Add JWT authentication
2. Implement voting system
3. Build ticket feed
4. Create staff dashboard
5. Add NLP similarity
6. Implement notifications
7. Media upload support
