'''
@filename: base.py
@author: krisna pranav
@copyright: 2023 Krisna Pranav MIT License
'''

from abc import ABC, abstractmethod
from langchain.callbacks.base import AsyncCallbackHandler
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler

# Streaming STDOUT
StreamingStdOutCallbackHandler.on_chat_model_start = lambda *args, **kwargs: None

class AsyncCallbackTextHandler(AsyncCallbackHandler):
    def __init__(self, on_new_token=None, token_buffer=None, on_llm_end=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.on_new_token = on_new_token
        self._on_llm_end = on_llm_end
        self.token_buffer = token_buffer
    
    async def on_chat_model_start(self, *args, **kwargs):
        pass

    async def on_llm_new_token(self, token: str, *args, **kwargs):
        if self.token_buffer is not None:
            self.token_buffer.append(token)
        await self.on_new_token(token)
    
    async def on_llm_end(self, *args, **kwargs):
        if self._on_llm_end is not None:
            await self._on_llm_end(''.join(self.token_buffer))
            self.token_buffer.clear()
            
class LLM(ABC):
    @abstractmethod
    async def achat(self, *args, **kwargs):
        pass