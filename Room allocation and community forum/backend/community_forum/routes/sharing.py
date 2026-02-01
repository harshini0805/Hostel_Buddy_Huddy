from fastapi import APIRouter, HTTPException
from datetime import datetime
import uuid

from database import sharing_col, sharing_replies_col
from models.sharing import ShareCreate, ShareReplyCreate
from utils.auth import get_current_user

router = APIRouter(prefix="/sharing", tags=["Sharing"])


# -----------------------------
# Create a sharing post
# -----------------------------
@router.post("/")
def create_share(data: ShareCreate):
    user = get_current_user()
    sharing_id = str(uuid.uuid4())

    sharing_col.insert_one({
        "id": sharing_id,
        "title": data.title,
        "description": data.description,
        "type": data.type,
        "posted_by": user["user_id"],
        "upvotes": 0,
        "downvotes": 0,
        "reply_count": 0,
        "created_at": datetime.utcnow().isoformat()
    })

    return {"message": "Request posted", "id": sharing_id}


# -----------------------------
# Get all sharing posts
# -----------------------------
@router.get("/")
def get_shares():
    shares = list(sharing_col.find({}, {"_id": 0}))
    return shares


# -----------------------------
# Vote on a sharing post
# -----------------------------
@router.post("/{sharing_id}/vote")
def vote_sharing(sharing_id: str, vote_data: dict):
    vote_type = vote_data.get("vote_type")

    if vote_type not in ["up", "down"]:
        raise HTTPException(
            status_code=400,
            detail="vote_type must be 'up' or 'down'"
        )

    sharing = sharing_col.find_one({"id": sharing_id})
    if not sharing:
        raise HTTPException(
            status_code=404,
            detail="Sharing request not found"
        )

    if vote_type == "up":
        sharing_col.update_one(
            {"id": sharing_id},
            {"$inc": {"upvotes": 1}}
        )
    else:
        sharing_col.update_one(
            {"id": sharing_id},
            {"$inc": {"downvotes": 1}}
        )

    return {"message": "Vote recorded"}


# -----------------------------
# Get replies for a sharing post
# -----------------------------
@router.get("/{sharing_id}/replies")
def get_sharing_replies(sharing_id: str):
    replies = list(
        sharing_replies_col.find(
            {"sharing_id": sharing_id},
            {"_id": 0}
        ).sort("created_at", 1)
    )
    return replies


# -----------------------------
# Add reply to a sharing post
# FIXED: Changed parameter name from 'reply' to 'data' for consistency
# -----------------------------
@router.post("/{sharing_id}/reply")
def add_sharing_reply(sharing_id: str, data: ShareReplyCreate):
    user = get_current_user()

    sharing = sharing_col.find_one({"id": sharing_id})
    if not sharing:
        raise HTTPException(status_code=404, detail="Sharing request not found")

    reply_doc = {
        "id": str(uuid.uuid4()),
        "sharing_id": sharing_id,
        "user_id": user["user_id"],
        "message": data.message,  # FIXED: Changed from reply.message to data.message
        "created_at": datetime.utcnow().isoformat()
    }

    sharing_replies_col.insert_one(reply_doc)

    sharing_col.update_one(
        {"id": sharing_id},
        {"$inc": {"reply_count": 1}}
    )

    return {"message": "Reply added successfully"}

# -----------------------------
# Delete sharing post + replies
# -----------------------------
@router.delete("/{sharing_id}")
def delete_sharing(sharing_id: str):
    sharing_col.delete_one({"id": sharing_id})
    sharing_replies_col.delete_many({"sharing_id": sharing_id})

    return {"message": "Sharing post and replies deleted"}