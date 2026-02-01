from pymongo import MongoClient
from faker import Faker
import random
from datetime import datetime, timedelta

fake=Faker("en_IN")

client=MongoClient("mongodb://localhost:27017/")
db=client["hostel_db"]

# ---------- STUDENTS ----------
students=[]
for i in range(1, 81):
    students.append({
        "_id":f"STU{i:03}",
        "name":fake.name_female(),
        "year":random.randint(1,4),
        "home_lat": random.uniform(8.0, 28.0),
        "home_lon":random.uniform(68.0, 88.0)
    })
db.students.insert_many(students)

# ---------- ATTENDANCE ----------
attendance = []
for s in students:
    attendance.append({
        "student_id": s["_id"],
        "year": 2024,
        "attendance_percentage": random.randint(65, 100)
    })

db.attendance.insert_many(attendance)

# ---------- ROOMS ----------
rooms = []

for i in range(1, 11):
    rooms.append({ "_id": f"R_SAC_{i:02}", "room_type": "SINGLE_AC", "capacity": 1, "occupied": 0 })
    rooms.append({ "_id": f"R_SNAC_{i:02}", "room_type": "SINGLE_NON_AC", "capacity": 1, "occupied": 0 })
    rooms.append({ "_id": f"R_TAC_{i:02}", "room_type": "THREE_AC", "capacity": 3, "occupied": 0 })
    rooms.append({ "_id": f"R_TNAC_{i:02}", "room_type": "THREE_NON_AC", "capacity": 3, "occupied": 0 })

db.rooms.insert_many(rooms)

# ---------- ROOM FORMS ----------
forms = []
base_time = datetime(2025, 3, 1, 10, 0, 0)

room_types = ["SINGLE_AC", "SINGLE_NON_AC", "THREE_AC", "THREE_NON_AC"]

for idx, s in enumerate(students):
    forms.append({
        "student_id": s["_id"],
        "submitted_at": base_time + timedelta(minutes=idx),
        "preferences": random.sample(room_types, 3)
    })

db.room_forms.insert_many(forms)

print("✅ MongoDB seeded successfully")