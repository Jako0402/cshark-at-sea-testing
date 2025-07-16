from http.client import responses
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import json

REQUEST_MATCHES = "REQUEST_MATCHES"
JOIN_MATCH = "JOIN_MATCH"
MATCH_PLAYERS = "MATCH_PLAYERS"
PLAYER_JOINED = "PLAYER_JOINED"
PLAYER_DROPPED = "PLAYER_DROPPED"
CHECK_MATCH_READY = "CHECK_MATCH_READY"
MATCH_READY = "MATCH_READY"

temp_matches_table = [{"matchId": "1", "teamMakeup": "1v1", "map": "Studiecaféen"},
                      {"matchId": "2", "teamMakeup": "1v1", "map": "PBA"}]
temp_players_table = []
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
            if data.get("op") == REQUEST_MATCHES:
                print("REQUEST_MATCHES")
                response = {"op": REQUEST_MATCHES,
                            "response": temp_matches_table}
                await manager.send_personal_message(response, websocket)
            elif data.get("op") == JOIN_MATCH:
                print("JOIN_MATCH")
                match = next(x for x in temp_matches_table if x.get("matchId") == data.get("matchId"))

                team1 = [x for x in temp_players_table if x.get("team") == "1"]
                team2 = [x for x in temp_players_table if x.get("team") == "2"]

                player_data = {
                    "playerId": data.get("playerId"),
                    "username": data.get("username"),
                    "connectionId": websocket
                }

                if len(team1) < 1:
                    print("Adding player to team 1")
                    player_data.update({"team": "1"})
                elif len(team2) < 1:
                    print("Adding player to team 2")
                    player_data.update({"team": "2"})
                else:
                    print("Huh? Both teams are full...this should not happen")
                    return

                # Send PLAYER_JOINED to all other clients in match
                users_for_match = []
                for seq in (team1, team2):
                    for client in seq:
                        users_for_match.append(client)
                        new_player = {
                            "op": PLAYER_JOINED,
                            "response": {
                                "username": player_data.get("username"),
                                "rank": "123"
                            }
                        }
                        await manager.send_personal_message(new_player, client.get("connectionId"))

                temp_players_table.append(player_data)
                match_players = {
                    "op": MATCH_PLAYERS,
                    "response": {
                        "users": [{"username": x.get("username"), "rank": "123"} for x in users_for_match],
                        "matchInfo": match
                    }
                }
                print(match_players)
                await manager.send_personal_message(match_players, websocket)








            elif data.get("op") == CHECK_MATCH_READY:
                print("CHECK_MATCH_READY")
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        await manager.broadcast(f"Client #{client_id} left the chat")