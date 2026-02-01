from pydantic import BaseModel
from datetime import date

class BookingCreate(BaseModel):
    room_id: str              # e.g. CR1, CR2
    on_date: str             # yyyy-mm-dd (API standard)
    start_time: str           # hh:mm AM/PM
    end_time: str             # hh:mm AM/PM
    purpose: str
