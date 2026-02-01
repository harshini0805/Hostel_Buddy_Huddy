from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import datetime
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
import os
from enum import Enum
from fastapi.encoders import jsonable_encoder

app = FastAPI(title="Hostel Grievance System - Phase 1")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB Configuration
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DATABASE_NAME = "hostel_grievance"

# Global MongoDB client
mongodb_client: Optional[AsyncIOMotorClient] = None
database = None


# Enums
class IssueCategory(str, Enum):
    ELECTRICAL = "electrical"
    PLUMBING = "plumbing"
    CIVIL = "civil"
    INTERNET = "internet"
    SAFETY = "safety"
    OTHER = "other"


class ImpactRadius(str, Enum):
    ROOM = "room"
    FLOOR = "floor"
    HOSTEL = "hostel"


class UrgencyLevel(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class TicketStatus(str, Enum):
    SUBMITTED = "submitted"
    ASSIGNED = "assigned"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    CLOSED = "closed"


# Vendor Mapping
VENDOR_MAP = {
    IssueCategory.ELECTRICAL: "ELECTRICAL_VENDOR",
    IssueCategory.PLUMBING: "PLUMBING_VENDOR",
    IssueCategory.CIVIL: "CIVIL_VENDOR",
    IssueCategory.INTERNET: "INTERNET_VENDOR",
    IssueCategory.SAFETY: "SECURITY",
    IssueCategory.OTHER: "GENERAL_MAINTENANCE"
}

# Priority Calculation Weights
URGENCY_WEIGHT = {
    UrgencyLevel.LOW: 1,
    UrgencyLevel.MEDIUM: 2,
    UrgencyLevel.HIGH: 3
}

IMPACT_WEIGHT = {
    ImpactRadius.ROOM: 1,
    ImpactRadius.FLOOR: 2,
    ImpactRadius.HOSTEL: 3
}


# Request Models
class CreateTicketRequest(BaseModel):
    category: IssueCategory
    impact_radius: ImpactRadius
    urgency: UrgencyLevel
    description: str = Field(..., min_length=30)
    media_urls: List[str] = Field(default_factory=list)

    @validator('description')
    def description_not_empty(cls, v):
        if not v.strip():
            raise ValueError('Description cannot be empty')
        return v.strip()

class MonkeyAlertRequest(BaseModel):
    notes: Optional[str] = Field(default="", max_length=200)

# Response Models
class StudentInfo(BaseModel):
    id: str
    name: str
    department: str


class LocationInfo(BaseModel):
    hostel: str
    block: str
    floor: int
    room: str


class VotesInfo(BaseModel):
    count: int
    voters: List[str]


class TicketResponse(BaseModel):
    id: str
    student: StudentInfo
    location: LocationInfo
    category: str
    impact_radius: str
    urgency: str
    description: str
    media_urls: List[str]
    assigned_vendor: str
    status: str
    priority_score: int
    votes: VotesInfo
    created_at: datetime
    updated_at: datetime

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


# Database Connection
@app.on_event("startup")
async def startup_db_client():
    global mongodb_client, database
    mongodb_client = AsyncIOMotorClient(MONGODB_URL)
    database = mongodb_client[DATABASE_NAME]
    
    # Create indexes
    await database.tickets.create_index("student.id")
    await database.tickets.create_index("status")
    await database.tickets.create_index("priority_score")
    await database.tickets.create_index("created_at")
    await database.tickets.create_index("votes.voters")
    await database.monkey_alerts.create_index("status")
    await database.monkey_alerts.create_index("created_at")


    
    print("Connected to MongoDB")


@app.on_event("shutdown")
async def shutdown_db_client():
    global mongodb_client
    if mongodb_client:
        mongodb_client.close()
    print("Disconnected from MongoDB")


# Mock Authentication (Replace with actual auth in production)
async def get_current_student():
    """
    Mock function to simulate authenticated student.
    In production, this would validate JWT token and fetch user from session/DB.
    """
    # For Phase 1, returning mock data
    # In real implementation, this would:
    # 1. Validate JWT token from Authorization header
    # 2. Fetch student details from database
    # 3. Return student object or raise 401
    
    return {
        "id": "STU2024001",
        "name": "Rahul Kumar",
        "department": "Computer Science",
        "hostel": "H1",
        "block": "B",
        "floor": 3,
        "room": "312"
    }


def calculate_priority(urgency: UrgencyLevel, impact: ImpactRadius) -> int:
    """Calculate priority score based on urgency and impact."""
    return URGENCY_WEIGHT[urgency] * IMPACT_WEIGHT[impact]

def recalculate_priority_with_votes(
    urgency: str,
    impact: str,
    vote_count: int
) -> int:
    """
    Phase 2 priority formula:
    (urgency_weight × impact_weight) + votes
    """
    urgency_enum = UrgencyLevel(urgency)
    impact_enum = ImpactRadius(impact)

    base_priority = (
        URGENCY_WEIGHT[urgency_enum] *
        IMPACT_WEIGHT[impact_enum]
    )

    return base_priority + vote_count



def assign_vendor(category: IssueCategory) -> str:
    """Assign vendor based on issue category."""
    return VENDOR_MAP[category]


# API Endpoints
@app.get("/")
async def root():
    return {
        "message": "Hostel Grievance System API - Phase 1",
        "version": "1.0.0",
        "status": "running"
    }


@app.post("/tickets", response_model=TicketResponse, status_code=status.HTTP_201_CREATED)
async def create_ticket(
    ticket_data: CreateTicketRequest,
    current_student: dict = Depends(get_current_student)
):
    """
    Create a new grievance ticket.
    
    - Authenticates student
    - Auto-fills student information
    - Assigns vendor based on category
    - Calculates priority score
    - Stores ticket in MongoDB
    """
    
    # Calculate priority score
    priority_score = calculate_priority(ticket_data.urgency, ticket_data.impact_radius)
    
    # Assign vendor
    assigned_vendor = assign_vendor(ticket_data.category)
    
    # Prepare ticket document
    now = datetime.utcnow()
    ticket_document = {
        "student": {
            "id": current_student["id"],
            "name": current_student["name"],
            "department": current_student["department"]
        },
        "location": {
            "hostel": current_student["hostel"],
            "block": current_student["block"],
            "floor": current_student["floor"],
            "room": current_student["room"]
        },
        "category": ticket_data.category.value,
        "impact_radius": ticket_data.impact_radius.value,
        "urgency": ticket_data.urgency.value,
        "description": ticket_data.description,
        "media_urls": ticket_data.media_urls,
        "assigned_vendor": assigned_vendor,
        "status": TicketStatus.SUBMITTED.value,
        "priority_score": priority_score,
        "votes": {
            "count": 1,  # Student auto-votes for their own ticket
            "voters": [current_student["id"]]
        },
        "created_at": now,
        "updated_at": now
    }
    
    # Insert into MongoDB
    try:
        result = await database.tickets.insert_one(ticket_document)
        ticket_document["_id"] = result.inserted_id
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create ticket: {str(e)}"
        )
    
    # Prepare response
    response = TicketResponse(
        id=str(ticket_document["_id"]),
        student=StudentInfo(**ticket_document["student"]),
        location=LocationInfo(**ticket_document["location"]),
        category=ticket_document["category"],
        impact_radius=ticket_document["impact_radius"],
        urgency=ticket_document["urgency"],
        description=ticket_document["description"],
        media_urls=ticket_document["media_urls"],
        assigned_vendor=ticket_document["assigned_vendor"],
        status=ticket_document["status"],
        priority_score=ticket_document["priority_score"],
        votes=VotesInfo(**ticket_document["votes"]),
        created_at=ticket_document["created_at"],
        updated_at=ticket_document["updated_at"]
    )
    
    return response

@app.get("/tickets/feed", response_model=List[TicketResponse])
async def get_ticket_feed(
    current_student: dict = Depends(get_current_student)
):
    """
    Returns tickets relevant to the student's location:
    - Same room
    - Same floor
    - Same hostel
    Excludes closed tickets.
    """

    hostel = current_student["hostel"]
    block = current_student["block"]
    floor = current_student["floor"]
    room = current_student["room"]

    query = {
        "status": {"$ne": TicketStatus.CLOSED.value},
        "location.hostel": hostel,
        "$or": [
            {"location.room": room},
            {
                "location.block": block,
                "location.floor": floor
            },
            {}  # same hostel fallback
        ]
    }

    cursor = (
        database.tickets
        .find(query)
        .sort([
            ("priority_score", -1),
            ("created_at", 1)
        ])
    )

    tickets = []
    async for ticket in cursor:
        tickets.append(
            TicketResponse(
                id=str(ticket["_id"]),
                student=StudentInfo(**ticket["student"]),
                location=LocationInfo(**ticket["location"]),
                category=ticket["category"],
                impact_radius=ticket["impact_radius"],
                urgency=ticket["urgency"],
                description=ticket["description"],
                media_urls=ticket["media_urls"],
                assigned_vendor=ticket["assigned_vendor"],
                status=ticket["status"],
                priority_score=ticket["priority_score"],
                votes=VotesInfo(**ticket["votes"]),
                created_at=ticket["created_at"],
                updated_at=ticket["updated_at"]
            )
        )

    return tickets

@app.post("/tickets/{ticket_id}/vote", status_code=status.HTTP_200_OK)
async def vote_on_ticket(
    ticket_id: str,
    current_student: dict = Depends(get_current_student)
):
    """
    Allows a student to vote on a ticket once.
    Recalculates priority_score after voting.
    """

    student_id = current_student["id"]

    ticket = await database.tickets.find_one({"_id": ObjectId(ticket_id)})

    if not ticket:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ticket not found"
        )

    if student_id in ticket["votes"]["voters"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You have already voted on this ticket"
        )

    # Update votes
    new_vote_count = ticket["votes"]["count"] + 1

    new_priority = recalculate_priority_with_votes(
        urgency=ticket["urgency"],
        impact=ticket["impact_radius"],
        vote_count=new_vote_count
    )

    await database.tickets.update_one(
        {"_id": ObjectId(ticket_id)},
        {
            "$push": {"votes.voters": student_id},
            "$set": {
                "votes.count": new_vote_count,
                "priority_score": new_priority,
                "updated_at": datetime.utcnow()
            }
        }
    )

    return {
        "message": "Vote registered successfully",
        "new_vote_count": new_vote_count,
        "new_priority_score": new_priority
    }

@app.post("/alerts/monkey", status_code=status.HTTP_201_CREATED)
async def report_monkey_alert(
    alert: MonkeyAlertRequest,
    current_student: dict = Depends(get_current_student)
):
    now = datetime.utcnow()

    alert_doc = {
        "type": "monkey",
        "reported_by": {
            "id": current_student["id"],
            "name": current_student["name"]
        },
        "location": {
            "hostel": current_student["hostel"],
            "block": current_student["block"],
            "floor": current_student["floor"],
            "room": current_student["room"]
        },
        "notes": alert.notes,
        "status": "active",  # active | resolved
        "created_at": now
    }

    await database.monkey_alerts.insert_one(alert_doc)

    return {
        "type": "MONKEY_ALERT",
        "message": "Monkey alert reported successfully",
        "play_sound": True,
        "severity": "high",
        "reported_at": now.isoformat()
    }


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    try:
        # Ping MongoDB
        await mongodb_client.admin.command('ping')
        db_status = "connected"
    except Exception as e:
        db_status = f"disconnected: {str(e)}"
    
    return {
        "status": "healthy",
        "database": db_status,
        "timestamp": datetime.utcnow().isoformat()
    }


@app.get("/tickets/feed")
async def get_ticket_feed():
    """
    Returns all active tickets (status != 'closed') sorted by priority_score descending
    """
    tickets_cursor = database.tickets.find({"status": {"$ne": "closed"}}).sort("priority_score", -1)
    tickets = await tickets_cursor.to_list(length=100)  # adjust max length as needed

    # Convert ObjectId to string
    for t in tickets:
        t["_id"] = str(t["_id"])
    return tickets



if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
