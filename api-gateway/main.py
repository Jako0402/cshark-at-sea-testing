from typing import Annotated
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Depends
from sqlmodel import Field, Session, SQLModel, create_engine, select, Relationship
from contextlib import asynccontextmanager
import json, os

REQUEST_MATCHES = "REQUEST_MATCHES"
JOIN_MATCH = "JOIN_MATCH"
MATCH_PLAYERS = "MATCH_PLAYERS"
PLAYER_JOINED = "PLAYER_JOINED"
PLAYER_DROPPED = "PLAYER_DROPPED"
CHECK_MATCH_READY = "CHECK_MATCH_READY"
MATCH_READY = "MATCH_READY"

active_connections = {}

sqlite_file_name = "database.db"
sqlite_url = f"sqlite:///{sqlite_file_name}"
connect_args = {"check_same_thread": False}
engine = create_engine(sqlite_url, connect_args=connect_args)

class Player(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    username: str = Field(unique=True)

class Match(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    map: str
    team_makeup: str

class MatchPlayer(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    player_id: int = Field(foreign_key="player.id")
    match_id: int = Field(foreign_key="match.id")
    team: str

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:
        yield session
SessionDep = Annotated[Session, Depends(get_session)]


@asynccontextmanager
async def lifespan(app: FastAPI):
    if os.path.exists("database.db"):
        os.remove("database.db")
    create_db_and_tables()
    match_1 = Match(map="Studiecaféen", team_makeup="1v1")
    match_2 = Match(map="PBA", team_makeup="1v1")
    with Session(engine) as session:
        session.add(match_1)
        session.add(match_2)
        session.commit()
    yield



app = FastAPI(lifespan=lifespan)



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
async def websocket_endpoint(websocket: WebSocket, session: Session = Depends(get_session)):
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_json()
            if data.get("op") == REQUEST_MATCHES:
                print(f"REQUEST_MATCHES: {data}")
                active_connections[data.get("username")] = websocket
                statement = select(Match)
                found_matches = [match.model_dump() for match in session.exec(statement).all()]
                response = {"op": REQUEST_MATCHES,
                            "response": found_matches}
                await manager.send_personal_message(response, websocket)

            elif data.get("op") == JOIN_MATCH:
                print(f"JOIN_MATCH: {data}") # JOIN_MATCH: {'matchId': 1, 'op': 'JOIN_MATCH', 'playerId': '928', 'username': 'User928'}
                statement = select(Match).where(Match.id == data.get("matchId"))
                match = session.exec(statement).one().model_dump()
                print(f"Match found: {match}")

                statement = select(MatchPlayer).where(MatchPlayer.match_id == data.get("matchId"))
                existing_players_in_match = [match.model_dump() for match in session.exec(statement).all()]
                print(f"existing_players_in_match: {existing_players_in_match}")
                team1 = [x for x in existing_players_in_match if x.get("team") == "1"]
                team2 = [x for x in existing_players_in_match if x.get("team") == "2"]

                if len(team1) < 1:
                    print("Adding player to team 1")
                    team = "1"
                elif len(team2) < 1:
                    print("Adding player to team 2")
                    team = "2"
                else:
                    print("Huh? Both teams are full...this should not happen")
                    return
                new_match_player: MatchPlayer = MatchPlayer(player_id=data.get("playerId"), match_id=data.get("matchId"), team=team)
                new_match_player_json = new_match_player.model_dump()
                all_players_in_match = existing_players_in_match + [new_match_player_json]
                session.add(new_match_player)
                session.commit()
                print(f"new_match_player_json: {new_match_player_json}")

                # Send PLAYER_JOINED to all other clients in match
                new_player_data = {
                    "op": PLAYER_JOINED,
                    "response": all_players_in_match
                }
                for client in existing_players_in_match:
                    await manager.send_personal_message(new_player_data, active_connections[str(client.get("player_id"))])

                match_players = {
                    "op": MATCH_PLAYERS,
                    "response": {
                        "users": all_players_in_match,
                        "matchInfo": match
                    }
                }

                await manager.send_personal_message(match_players, websocket)



            elif data.get("op") == CHECK_MATCH_READY:
                print(f"CHECK_MATCH_READY: {data}")
                statement = select(MatchPlayer).where(MatchPlayer.match_id == data.get("matchId"))
                players_in_match = [match.model_dump() for match in session.exec(statement).all()]
                print(f"Players in match: {players_in_match}")
                team1 = [x for x in players_in_match if x.get("team") == "1"]
                team2 = [x for x in players_in_match if x.get("team") == "2"]

                if len(team1) == 1 and len(team2) == 1:
                    print("Game is full. Staring game")
                    # TODO: UPDATE MATCH STATUS
                    connection_info = {
                        "op": MATCH_READY,
                        "response": {
                            "ip": "127.0.0.1",
                            "port": 3040
                        }
                    }
                    for client in players_in_match:
                        await manager.send_personal_message(connection_info, active_connections[str(client.get("player_id"))])


    except WebSocketDisconnect:
        manager.disconnect(websocket)
        dropped_username = next((username for username, ws in active_connections.items() if ws == websocket), None)
        print(f"Player: {dropped_username} dropped from lobby")
        statement = select(MatchPlayer).where(MatchPlayer.player_id == dropped_username)
        dropped_match_player = session.exec(statement).one()
        match_id = dropped_match_player.model_dump().get("match_id")
        session.delete(dropped_match_player)
        session.commit()

        statement = select(MatchPlayer).where(MatchPlayer.match_id == match_id)
        existing_players_in_match = [match_player.model_dump() for match_player in session.exec(statement).all()]

        dropped_player_info = {
            "op": PLAYER_DROPPED,
            "response": {
                "users": existing_players_in_match
            }
        }
        for client in existing_players_in_match:
            print(f"Sent droppped to: {client}")
            await manager.send_personal_message(dropped_player_info, active_connections[str(client.get("player_id"))])




