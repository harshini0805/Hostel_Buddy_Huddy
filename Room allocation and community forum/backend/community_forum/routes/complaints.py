from fastapi import APIRouter, HTTPException
from datetime import datetime
from database import complaints_col
from models.complaint import ComplaintCreate
from utils.auth import get_current_user
import uuid

router = APIRouter(prefix="/complaints", tags=["Complaints"])

@router.post("/")
def create_complaint(data: ComplaintCreate):
    user = get_current_user()
    complaint_id = str(uuid.uuid4())
    
    complaints_col.insert_one({
        "id": complaint_id,
        "title": data.title,
        "description": data.description,
        "created_by": user["user_id"],
        "upvotes": 0,
        "downvotes": 0,
        "created_at": datetime.utcnow().isoformat()
    })
    return {"message": "Complaint raised", "id": complaint_id}

@router.get("/")
def get_complaints():
    complaints = list(complaints_col.find({}, {"_id": 0}))
    return complaints

@router.post("/{complaint_id}/vote")
def vote_complaint(complaint_id: str, vote_data: dict):
    """
    Vote on a complaint
    vote_data: { "vote_type": "up" | "down" }
    """
    vote_type = vote_data.get("vote_type")
    
    if vote_type not in ["up", "down"]:
        raise HTTPException(status_code=400, detail="vote_type must be 'up' or 'down'")
    
    complaint = complaints_col.find_one({"id": complaint_id})
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
    
    # Update vote count
    if vote_type == "up":
        complaints_col.update_one(
            {"id": complaint_id},
            {"$inc": {"upvotes": 1}}
        )
    else:
        complaints_col.update_one(
            {"id": complaint_id},
            {"$inc": {"downvotes": 1}}
        )
    
    return {"message": "Vote recorded"}