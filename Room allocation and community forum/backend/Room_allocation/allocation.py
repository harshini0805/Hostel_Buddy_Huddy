from database import students_col, attendance_col, rooms_col, forms_col, allocations_col
from math import radians, cos, sin, asin, sqrt

HOSTEL_LAT=12.9352
HOSTEL_LON=77.6245

def distance(lat1, lon1, lat2, lon2):
    lon1, lat1, lon2, lat2=map(radians, [lon1, lat1, lon2, lat2])

    dlon=lon2-lon1
    dlat=lat2-lat1

    a=sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2

    return 6371 * (2 * asin(sqrt(a)))

def run_allocation():
    forms=list(forms_col.find())
    rooms=list(rooms_col.find())

    room_pool={}

    for r in rooms:
        for _ in range(r["capacity"]):
            room_pool.setdefault(r["room_type"], []).append(r)

    candidates=[]

    for f in forms:
        student_id = f["student_id"]

        student = students_col.find_one({"_id": student_id})
        if not student:
            continue

        attendance = attendance_col.find_one({"student_id": student_id})
        if not attendance:
            continue

        d=distance(
            student["home_lat"],
            student["home_lon"],
            HOSTEL_LAT,
            HOSTEL_LON
        )

        score=(
            0.5*(1/(1+forms.index(f)))+0.3*(attendance["attendance_percentage"]/100)+0.2*(d/2000)
        )

        candidates.append({
            "student_id":student_id,
            "preferences":f["preferences"],
            "score":score
        })

    candidates.sort(key=lambda x: x["score"], reverse=True)

    allocations_col.delete_many({})

    for c in candidates:
        assigned=False

        for pref in c["preferences"]:
            available=room_pool.get(pref,[])
            if available:
                room=available.pop()
                allocations_col.insert_one({
                    "student_id":c["student_id"],
                    "room_type":pref,
                    "room_id":room["_id"],
                    "status":"ALLOCATED"
                })
                assigned=True
                break

        if not assigned:
            for room_type, available_rooms in room_pool.items():
                if available_rooms:
                    room = available_rooms.pop()
                    allocations_col.insert_one({
                        "student_id": c["student_id"],
                        "room_type": room_type,
                        "room_id": room["_id"],
                        "status": "ALLOCATED"
                    })
                    break