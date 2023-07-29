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

# SQLALCHEMY
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

# Connect Args
connect_args = {"check_same_thread": False} if SQLALCHEMY_DATABASE_URL.startswith(
    "sqlite") else {}

# Engine
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args=connect_args)

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
    # print default SQLALCHEMY DATABASE URL
    print(SQLALCHEMY_DATABASE_URL)
    
    from ai.models.usermodel import User
    from ai.models.interaction import Interaction
    
    # local session
    with SessionLocal() as session:
        print(session.query(User).all())
        session.delete(User(name="TestUser", email="test@gmail.com"))
        session.commit()

        print(session.query(User).all())
        session.query(User).filter(User.name == "TestUser").delete()
        session.commit()

        print(session.query(User).all())