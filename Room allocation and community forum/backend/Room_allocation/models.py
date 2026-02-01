from pydantic import BaseModel
from typing import List
from datetime import datetime

class RoomForm(BaseModel):
    student_id: str
    name: str
    year: int
    attendance_percentage: float
    home_lat: float
    home_lon: float
    preferences: List[str]

class AllocationResult(BaseModel):
    student_id: str
    room_type: str
    room_id: str
    status: str