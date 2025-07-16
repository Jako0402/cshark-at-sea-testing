from http.client import responses

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import json
app = FastAPI()

class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def send_personal_message(self, message: json, websocket: WebSocket):
        await websocket.send_json(message)

    async def broadcast(self, message: json):
        for connection in self.active_connections:
            await connection.send_json(message)

manager = ConnectionManager()

@app.websocket("/")
async def websocket_endpoint(websocket: WebSocket):
    client_id = 1
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_json()
            if data.get("op") == "REQUEST_MATCHES":
                response = {"op": "REQUEST_MATCHES",
                            "response": [{"teamMakeup": "1v1", "map": "Studiecaféen"},
                                         {"teamMakeup": "2v2", "map": "PBA"}]}
                await manager.send_personal_message(response, websocket)
            elif data.get("op") == "JOIN_MATCH":
                print("JOIN_MATCH")
            elif data.get("op") == "CHECK_MATCH_READY":
                print("CHECK_MATCH_READY")
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        await manager.broadcast(f"Client #{client_id} left the chat")