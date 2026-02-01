from fastapi import APIRouter, HTTPException
from datetime import datetime
from bson import ObjectId
from database import forum_posts_col, forum_replies_col
from models.forum import ForumPostCreate
from models.forum_reply import ForumReplyCreate
from utils.auth import get_current_user

router = APIRouter(prefix="/forum", tags=["Forum"])

# -------------------------------
# CREATE A FORUM POST
# -------------------------------
@router.post("/post")
def create_post(data: ForumPostCreate):
    user = get_current_user()

    forum_posts_col.insert_one({
        "content": data.content,
        "category": data.category,
        "author_id": user["user_id"],  # hidden from frontend
        "created_at": datetime.utcnow()
    })

    return {"message": "Forum post created"}

# -------------------------------
# GET ALL FORUM POSTS (PUBLIC)
# -------------------------------
@router.get("/posts")
def get_posts():
    posts = list(forum_posts_col.find({}, {"author_id": 0}))
    for post in posts:
        post["id"] = str(post["_id"])
        del post["_id"]
    return posts

# -------------------------------
# CREATE A REPLY TO A POST
# -------------------------------
@router.post("/reply")
def create_reply(data: ForumReplyCreate):
    user = get_current_user()

    # Validate post exists
    if not forum_posts_col.find_one({"_id": ObjectId(data.post_id)}):
        raise HTTPException(404, "Post not found")

    forum_replies_col.insert_one({
        "post_id": data.post_id,
        "content": data.content,
        "author_id": user["user_id"],  # hidden
        "created_at": datetime.utcnow()
    })

    return {"message": "Reply added"}

# -------------------------------
# GET REPLIES FOR A POST
# -------------------------------
@router.get("/replies/{post_id}")
def get_replies(post_id: str):
    replies = list(
        forum_replies_col.find(
            {"post_id": post_id},
            {"author_id": 0}
        )
    )

    for reply in replies:
        reply["id"] = str(reply["_id"])
        del reply["_id"]

    return replies