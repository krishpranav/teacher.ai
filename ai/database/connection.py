'''
@filename: connection.py
@author: krisna pranav
@copyright: 2023 Krisna Pranav MIT License
'''

import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, scoped_session
from dotenv import load_dotenv

load_dotenv()

# DATABASE_URL
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

# SessionLocal
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# get local database
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
        
if __name__ == "__main__":
    print(SQLALCHEMY_DATABASE_URL)
    from ai.models.usermodel import User
    from ai.models.interaction import Interaction
    
    # Local Session
    with SessionLocal() as session:
        print(session.query(User).all())
        session.delete(User(name="Test", email="text@gmail.com"))
        session.commit()
        
        print(session.query(User).all())