from fastapi import APIRouter, HTTPException
from database import bookings_col
from models.booking import BookingCreate
from utils.auth import get_current_user
from utils.time_utils import time_to_minutes

router = APIRouter(prefix="/bookings", tags=["Bookings"])

@router.post("/")
def book_room(data: BookingCreate):
    user = get_current_user()

    start_min = time_to_minutes(data.start_time)
    end_min = time_to_minutes(data.end_time)

    if start_min >= end_min:
        raise HTTPException(
            status_code=400,
            detail="Start time must be before end time"
        )

    # ✅ MONGO-SAFE CONFLICT CHECK
    conflict = bookings_col.find_one({
        "room_id": data.room_id,
        "on_date": data.on_date,      # string comparison
        "start_min": {"$lt": end_min},
        "end_min": {"$gt": start_min}
    })

    if conflict:
        raise HTTPException(
            status_code=400,
            detail="Room already booked for this date and time slot"
        )

    bookings_col.insert_one({
        "room_id": data.room_id,
        "on_date": data.on_date,      # stored as string
        "start_time": data.start_time,
        "end_time": data.end_time,
        "start_min": start_min,
        "end_min": end_min,
        "purpose": data.purpose,
        "booked_by": user["user_id"]
    })

    return {"message": "Room booked successfully"}

@router.get("/")
def get_bookings():
    return list(bookings_col.find({}, {"_id": 0}))
