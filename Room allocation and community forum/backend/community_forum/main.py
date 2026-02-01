from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import forum, complaints, sharing, bookings

app = FastAPI(title="Hostel Community Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten later
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(forum.router)
app.include_router(complaints.router)
app.include_router(sharing.router)
app.include_router(bookings.router)
