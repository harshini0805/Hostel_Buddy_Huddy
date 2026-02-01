from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017/")
db = client["hostel_db"]

students_col = db.students
attendance_col = db.attendance
rooms_col = db.rooms
forms_col = db.room_forms
allocations_col = db.allocations
