'''
@filename: interaction.py
@author: krisna pranav
@copyright: 2023 Krisna Pranav MIT License
'''

import datetime
from sqlalchemy import Column, Integer, String, DateTime, Unicode
from ai.database.base import Base


class Interaction(Base):
    # table_name
    __tablename__ = "interactions"

    # id
    id = Column(Integer, primary_key=True, index=True, nullable=False)
    
    # id[client, user, session]
    client_id = Column(Integer)  
    user_id = Column(String(50))
    session_id = Column(String(50))
    
    # client_message + server_message
    client_message = Column(String)
    server_message = Column(String)
    client_message_unicode = Column(Unicode(65535))
    server_message_unicode = Column(Unicode(65535))

    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    platform = Column(String(50))
    action_type = Column(String(50))
    character_id = Column(String(100))
    tools = Column(String(100))

    def save(self, db):
        db.add(self)
        db.commit()