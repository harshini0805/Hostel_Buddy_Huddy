from pydantic import BaseModel

class ForumReplyCreate(BaseModel):
    post_id: str
    content: str
