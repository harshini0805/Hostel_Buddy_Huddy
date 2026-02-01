from pydantic import BaseModel

class ForumPostCreate(BaseModel):
    content: str
    category: str
