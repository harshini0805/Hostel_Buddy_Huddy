from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017")
db = client["hostel_db"]

users_col = db["users"]
forum_posts_col = db["forum_posts"]
complaints_col = db["complaints"]
sharing_col = db["sharing"]
bookings_col = db["bookings"]
forum_replies_col = db["forum_replies"]
sharing_replies_col = db["sharing_replies"]
