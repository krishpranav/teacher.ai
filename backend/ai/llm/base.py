'''
@filename: base.py
@author: krisna pranav
@copyright: 2023 Krisna Pranav MIT License
'''

from abc import ABC, abstractmethod
from langchain.callbacks.base import AsyncCallbackHandler
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler

# StreamingSTD[on_chat_model]
StreamingStdOutCallbackHandler.on_chat_model_start = lambda *args, **kwargs: None

# AsyncCallbackTextHandler
class AsyncCallbackTextHandler(AsyncCallbackHandler):
    # initialize.
    def __init__(self, on_new_token=None, token_buffer=None, on_llm_end=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.on_new_token = on_new_token
        self._on_llm_end = on_llm_end
        self.token_buffer = token_buffer

    # on_chat_model_start
    async def on_chat_model_start(self, *args, **kwargs):
        pass

    # on_llm_new_token
    async def on_llm_new_token(self, token: str, *args, **kwargs):
        if self.token_buffer is not None:
            self.token_buffer.append(token)
        await self.on_new_token(token)

    # on_llm_end
    async def on_llm_end(self, *args, **kwargs):
        if self._on_llm_end is not None:
            await self._on_llm_end(''.join(self.token_buffer))
            self.token_buffer.clear()


# AsyncCallbackAudioHandler
class AsyncCallbackAudioHandler(AsyncCallbackHandler):
    # initialize.
    def __init__(self, text_to_speech=None, websocket=None, tts_event=None, character_name="", *args, **kwargs):
        super().__init__(*args, **kwargs)
        if text_to_speech is None:
            def text_to_speech(token): return print(
                f'New audio token: {token}')
        self.text_to_speech = text_to_speech
        self.websocket = websocket
        self.current_sentence = ""
        self.character_name = character_name
        self.is_reply = False  
        self.tts_event = tts_event
        self.is_first_sentence = True

    # chat_model_start
    async def on_chat_model_start(self, *args, **kwargs):
        pass

    # llm_new_token
    async def on_llm_new_token(self, token: str, *args, **kwargs):
        if not self.is_reply and token == ">":
            self.is_reply = True
        elif self.is_reply:
            if token != ".":
                self.current_sentence += token
            else:
                await self.text_to_speech.stream(
                    self.current_sentence,
                    self.websocket,
                    self.tts_event,
                    self.character_name,
                    self.is_first_sentence)
                self.current_sentence = ""
                if self.is_first_sentence:
                    self.is_first_sentence = False

    # llm_end
    async def on_llm_end(self, *args, **kwargs):
        if self.current_sentence != "":
            await self.text_to_speech.stream(
                self.current_sentence,
                self.websocket, self.tts_event, self.character_name, self.is_first_sentence)

# LLM
class LLM(ABC):
    @abstractmethod
    async def achat(self, *args, **kwargs):
        pass