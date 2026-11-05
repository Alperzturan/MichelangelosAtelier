
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field

# Frontend ile etkileşimde bulunacak olan kullanıcı veri modelleri 


class UserBase(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=100, description="Kullanıcının tam adı")
    email: EmailStr = Field(..., description="Geçerli bir e-posta adresi")


# POST /auth/register data
class UserCreate(UserBase):
    password: str = Field(..., min_length=6, max_length=100, description="En az 6 karakterli şifre")


# POST /auth/login-json data
class UserLogin(BaseModel):
    email: EmailStr
    password: str


# Genel response
class UserResponse(UserBase):
    id: int
    role: str
    created_at: datetime

    class Config:
        from_attributes = True  