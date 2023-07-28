'''
@filename: usermodel.py
@author: krisna pranav
@copyright: 2023 Krisna Pranav MIT License
'''

from sqlalchemy import Integer, String, Column
from ai.database.base import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True)
    name = Column(String)
    
    def save(self, db):
        db.add(self)
        db.commit()