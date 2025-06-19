# stream.py (Ollama version)
from fastapi.websockets import WebSocket
import asyncio
from typing import AsyncGenerator
import os 
import aiohttp
import json

class WSConnectionManager: 
    def __init__(self) -> None:
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket) -> None: 
        await websocket.accept()
        self.active_connections.append(websocket)

    async def disconnect(self, websocket: WebSocket) -> None: 
        self.active_connections.remove(websocket)
        await websocket.close()

    @staticmethod
    async def receive(websocket: WebSocket) -> str: 
        return await websocket.receive_text()

    @staticmethod
    async def send(
        message: str | bytes | list | dict, websocket: WebSocket
    ) -> None: 
        if isinstance(message, str):
            await websocket.send_text(message)
        elif isinstance(message, bytes):
            await websocket.send_bytes(message)
        else:
            await websocket.send_json(message)

    async def broadcast(self, message: str | bytes | list | dict) -> None:
        for connection in self.active_connections:
            await self.send(message, connection)

class OllamaClient:
    def __init__(self):
        self.base_url = f"http://{os.getenv('OLLAMA_HOST', '127.0.0.1:11434')}/api"
        self.model = os.getenv("OLLAMA_MODEL", "deepseek-r1:latest")  
    async def chat_stream(self, prompt: str) -> AsyncGenerator[str, None]:
        async with aiohttp.ClientSession() as session:
            payload = {
                "model": self.model,
                "prompt": prompt,
                "stream": True
            }
            
            async with session.post(
                f"{self.base_url}/generate",
                json=payload,
                timeout=60
            ) as response:
                async for line in response.content:
                    if line:
                        try:
                            chunk = json.loads(line.decode('utf-8'))
                            if 'response' in chunk:
                                yield chunk['response']
                            await asyncio.sleep(0.05)
                        except json.JSONDecodeError:
                            continue

ollama_client = OllamaClient()
ws_manager = WSConnectionManager()