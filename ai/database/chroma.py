'''
@filename: chroma.py
@author: krisna pranav
@copyright: 2023 Krisna Pranav MIT License
'''

import os
from dotenv import load_dotenv
from langchain.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings
from ai.log import get_logger

load_dotenv()

# logger
logger = get_logger(__name__)

# embedding
embedding = OpenAIEmbeddings(openai_api_key=os.getenv("OPENAI_API_KEY"))

# get chroma
def get_chroma():
    chroma = Chroma(
        collection_name='llm',
        embedding_function=embedding,
        persist_directory='./chroma.db'
    )
    return chroma