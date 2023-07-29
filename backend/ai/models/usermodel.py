'''
@filename: usermodel.py
@author: krisna pranav
@copyright: 2023 Krisna Pranav MIT License
'''

from ai.database.base import Base
from sqlalchemy import Column, Integer, String


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    email = Column(String, unique=True, index=True, nullable=False)

    def save(self, db):
        db.add(self)
        db.commit()