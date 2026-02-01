# backend/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from models import RoomForm, AllocationResult
from database import forms_col, allocations_col
from allocation import run_allocation
from datetime import datetime, timezone
import uvicorn

app = FastAPI()

# CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:5000",
        "http://127.0.0.1:8000",
        "http://localhost:62046",   # Flutter Web dev port
        "http://10.0.2.2:8000",     # Android emulator
        "*",                         # Allow all for development (remove in production)
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/submit-form")
def submit_form(form: RoomForm):
    forms_col.insert_one({
        "student_id": form.student_id,
        "name": form.name,
        "year": form.year,
        "attendance_percentage": form.attendance_percentage,
        "home_lat": form.home_lat,
        "home_lon": form.home_lon,
        "preferences": form.preferences,
        "submitted_at": datetime.now(timezone.utc)
    })
    return {"message": "Form submitted successfully"}

@app.post("/run-allocation")
def allocate():
    run_allocation()
    return {"message": "Allocation completed"}

@app.get("/allocation/{student_id}")
def get_allocation(student_id: str):
    return allocations_col.find_one(
        {"student_id": student_id},
        {"_id": 0},
    )


@app.get("/allocations")
def get_all_allocations():
    """Get all allocations for admin view"""
    allocations = list(allocations_col.find({}, {"_id": 0}))
    return allocations

@app.get("/forms")
def get_all_forms():
    """Get all submitted forms for admin view"""
    forms = list(forms_col.find({}, {"_id": 0}))
    return forms

@app.get("/stats")
def get_stats():
    """Get statistics for admin dashboard"""
    total_forms = forms_col.count_documents({})
    total_allocations = allocations_col.count_documents({})
    
    # Count allocations by room type
    pipeline = [
        {
            "$group": {
                "_id": "$room_type",
                "count": {"$sum": 1}
            }
        }
    ]
    allocation_by_type = {item["_id"]: item["count"] for item in allocations_col.aggregate(pipeline)}
    
    return {
        "total_forms": total_forms,
        "total_allocations": total_allocations,
        "allocation_by_room_type": allocation_by_type
    }

# Optional: Reset endpoints for testing
@app.delete("/reset-forms")
def reset_forms():
    """Delete all forms (for testing only)"""
    forms_col.delete_many({})
    return {"message": "All forms deleted"}

@app.delete("/reset-allocations")
def reset_allocations():
    """Delete all allocations (for testing only)"""
    allocations_col.delete_many({})
    return {"message": "All allocations deleted"}

# Health check endpoint
@app.get("/")
def root():
    return {"message": "Hostel Allocation API is running"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)