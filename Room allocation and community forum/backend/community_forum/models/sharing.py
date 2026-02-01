from pydantic import BaseModel
from datetime import datetime
from bson import ObjectId

class ShareCreate(BaseModel):
    title: str
    description: str
    type: str  # borrow / lend / help

class SharingReply(BaseModel):
    id: str | None = None
    sharing_id: str          # 🔑 LINK TO POST
    user_id: str
    message: str
    created_at: datetime = datetime.utcnow()

class ShareReplyCreate(BaseModel):
    message: str
