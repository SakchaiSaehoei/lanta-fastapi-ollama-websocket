# main.py (Ollama version)
import asyncio
from loguru import logger
from fastapi.websockets import WebSocket, WebSocketDisconnect
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from stream import ws_manager, ollama_client

app = FastAPI()
app.mount("/pages", StaticFiles(directory="pages"), name="pages")

@app.websocket("/generate/text/streams")
async def websocket_endpoint(websocket: WebSocket) -> None:
    logger.info("Connecting to client....")
    await ws_manager.connect(websocket)
    try:
        while True:
            prompt = await ws_manager.receive(websocket)
            async for chunk in ollama_client.chat_stream(prompt):
                await ws_manager.send(chunk, websocket)
                await asyncio.sleep(0.05)
    except WebSocketDisconnect:
        logger.info("Client disconnected")
    except Exception as e:
        logger.error(f"Error with the WebSocket connection: {e}")
        await ws_manager.send("An internal server error has occurred")
    finally:
        await ws_manager.disconnect(websocket)