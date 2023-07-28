'''
@filename: interaction.py
@author: krisna pranav
@copyright: 2023 Krisna Pranav MIT License
'''

import datetime
from ai.database.base import Base
from sqlalchemy import Column, Integer, String, DateTime, Unicode

class Interactor(Base):
    __tablename__ = "interactions"
    
    id = Column(Integer, primary_key=True, index=True, nullable=False)
    client_id = Column(Integer)
    user_id = Column(String(50))
    session_id = Column(String(50))
    client_message = Column(String)
    
    def save(self, db):
        db.add(self)
        db.commit()
