# API Documentation - Phase 1

## Base URL
```
http://localhost:8000
```

---

## Authentication
**Phase 1**: Mock authentication (auto-filled student data)  
**Future**: JWT-based authentication required

---

## Endpoints

### 1. Health Check

**Endpoint:** `GET /health`

**Description:** Check if the API and database are running

**Response:**
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2024-02-01T10:30:00.123456"
}
```

**Status Codes:**
- `200 OK` - Service is healthy

---

### 2. Create Ticket

**Endpoint:** `POST /tickets`

**Description:** Create a new grievance ticket

**Request Headers:**
```
Content-Type: application/json
```

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

**Field Descriptions:**

| Field | Type | Required | Values | Description |
|-------|------|----------|--------|-------------|
| category | string | Yes | electrical, plumbing, civil, internet, safety, other | Issue category |
| impact_radius | string | Yes | room, floor, hostel | Scope of impact |
| urgency | string | Yes | low, medium, high | Urgency level |
| description | string | Yes | min 30 chars | Detailed description |
| media_urls | array | No | URLs | Image URLs (future) |

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
  "created_at": "2024-02-01T10:30:00.123456",
  "updated_at": "2024-02-01T10:30:00.123456"
}
```

**Error Responses:**

**400 Bad Request** - Validation error
```json
{
  "detail": [
    {
      "loc": ["body", "description"],
      "msg": "ensure this value has at least 30 characters",
      "type": "value_error.any_str.min_length"
    }
  ]
}
```

**422 Unprocessable Entity** - Invalid data
```json
{
  "detail": "Validation error: description cannot be empty"
}
```

**500 Internal Server Error**
```json
{
  "detail": "Failed to create ticket: connection error"
}
```

---

## Data Models

### IssueCategory Enum
```
- electrical
- plumbing
- civil
- internet
- safety
- other
```

### ImpactRadius Enum
```
- room    (affects single room)
- floor   (affects entire floor)
- hostel  (affects entire hostel)
```

### UrgencyLevel Enum
```
- low     (inconvenience, can wait)
- medium  (disruptive to daily activities)
- high    (safety concern or blocking critical needs)
```

### TicketStatus Enum
```
- submitted    (newly created)
- assigned     (vendor assigned - future)
- in_progress  (being worked on - future)
- resolved     (fixed - future)
- closed       (completed - future)
```

---

## Business Logic

### Vendor Assignment Rules

| Category | Assigned Vendor |
|----------|----------------|
| electrical | ELECTRICAL_VENDOR |
| plumbing | PLUMBING_VENDOR |
| civil | CIVIL_VENDOR |
| internet | INTERNET_VENDOR |
| safety | SECURITY |
| other | GENERAL_MAINTENANCE |

### Priority Score Calculation

```
priority_score = urgency_weight × impact_weight
```

**Urgency Weights:**
- low: 1
- medium: 2
- high: 3

**Impact Weights:**
- room: 1
- floor: 2
- hostel: 3

**Examples:**
- high + hostel = 3 × 3 = 9 (highest priority)
- high + floor = 3 × 2 = 6
- medium + floor = 2 × 2 = 4
- low + room = 1 × 1 = 1 (lowest priority)

### Auto-Voting
- When a ticket is created, the student automatically votes for it
- Initial vote count: 1
- Initial voters array: [student_id]

---

## Example Use Cases

### Example 1: Emergency Safety Issue
```bash
curl -X POST http://localhost:8000/tickets \
  -H "Content-Type: application/json" \
  -d '{
    "category": "safety",
    "impact_radius": "hostel",
    "urgency": "high",
    "description": "Fire alarm system not working in Block A. This is a critical safety hazard affecting all residents.",
    "media_urls": []
  }'
```
**Priority Score:** 9 (immediate attention required)

### Example 2: Regular Maintenance
```bash
curl -X POST http://localhost:8000/tickets \
  -H "Content-Type: application/json" \
  -d '{
    "category": "civil",
    "impact_radius": "room",
    "urgency": "low",
    "description": "Paint peeling off the wall in room 205. Not urgent but needs attention for maintenance.",
    "media_urls": []
  }'
```
**Priority Score:** 1 (low priority, scheduled maintenance)

### Example 3: Network Issue
```bash
curl -X POST http://localhost:8000/tickets \
  -H "Content-Type: application/json" \
  -d '{
    "category": "internet",
    "impact_radius": "floor",
    "urgency": "medium",
    "description": "WiFi connectivity is very slow on 3rd floor. Multiple students reporting issues during online classes.",
    "media_urls": []
  }'
```
**Priority Score:** 4 (moderate priority)

---

## Rate Limits
**Phase 1:** No rate limiting  
**Future:** To be implemented based on usage patterns

---

## Error Handling

All errors follow this structure:
```json
{
  "detail": "Error message or validation errors array"
}
```

**Common HTTP Status Codes:**
- `200` - Success (GET)
- `201` - Created (POST)
- `400` - Bad Request
- `401` - Unauthorized
- `422` - Validation Error
- `500` - Internal Server Error

---

## Testing Tools

### Swagger UI (Interactive Docs)
Visit: http://localhost:8000/docs

### Postman Collection
Import from Swagger and test endpoints interactively

### Python Test Script
```bash
cd backend
python test_api.py
```

---

## Future Endpoints (Phase 2+)

- `GET /tickets` - List all tickets
- `GET /tickets/{id}` - Get single ticket
- `PUT /tickets/{id}/vote` - Vote for ticket
- `GET /tickets/feed` - Get prioritized feed
- `PATCH /tickets/{id}/status` - Update status (admin)
- `GET /analytics/dashboard` - Get analytics data
