from flask import Flask, request
from flask_socketio import SocketIO, emit, join_room, leave_room
import random
import string

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, cors_allowed_origins="*", logger=False, engineio_logger=False)

rooms = {}

def generate_room_code():
    while True:
        code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
        if code not in rooms:
            return code

@socketio.on('create')
def handle_create():
    room_code = generate_room_code()
    rooms[room_code] = {
        'players': [],
        'board': [[[""] * 9 for _ in range(3)] for _ in range(3)],
        'bigBoard': [[""] * 3 for _ in range(3)],
        'currentPlayer': "X",
        'forcedBoard': None,
        'gameOver': False,
        'winner': "",
        'player_symbols': {}
    }
    join_room(room_code)
    rooms[room_code]['players'].append(request.sid)
    rooms[room_code]['player_symbols'][request.sid] = "X"
    emit('created', {'roomCode': room_code})

@socketio.on('join')
def handle_join(data):
    room_code = data['roomCode']
    if room_code in rooms and len(rooms[room_code]['players']) < 2:
        join_room(room_code)
        rooms[room_code]['players'].append(request.sid)
        rooms[room_code]['player_symbols'][request.sid] = "O"
        
        emit('joined', {'ready': True, 'roomCode': room_code})
        
        if len(rooms[room_code]['players']) == 2:
            socketio.emit('start_game', {
                'board': rooms[room_code]['board'],
                'bigBoard': rooms[room_code]['bigBoard'],
                'currentPlayer': rooms[room_code]['currentPlayer'],
                'forcedBoard': rooms[room_code]['forcedBoard']
            }, room=room_code)
    else:
        emit('error', {'message': 'Room piena o non trovata'})

@socketio.on('move')
def handle_move(data):
    room_code = data['roomCode']
    big_index = data['bigIndex']
    cell_index = data['cellIndex']
    
    if room_code in rooms:
        state = rooms[room_code]
        if state['gameOver']: return
        
        player_symbol = state['player_symbols'].get(request.sid)
        if player_symbol != state['currentPlayer']: return
        
        r, c = big_index // 3, big_index % 3
        
        if state['bigBoard'][r][c] != "": return
        if state['forcedBoard'] is not None and state['forcedBoard'] != big_index:
            fr, fc = state['forcedBoard'] // 3, state['forcedBoard'] % 3
            if state['bigBoard'][fr][fc] == "" and not is_board_full(state, state['forcedBoard']):
                return
        if state['board'][r][c][cell_index] != "": return

        state['board'][r][c][cell_index] = state['currentPlayer']
        sub_winner = check_winner_in_small_board(state, r, c)
        if sub_winner != "":
            state['bigBoard'][r][c] = sub_winner
        elif is_board_full(state, big_index):
            state['bigBoard'][r][c] = "D"

        state['forcedBoard'] = cell_index if cell_index < 9 else None
        if state['forcedBoard'] is not None and (state['bigBoard'][state['forcedBoard'] // 3][state['forcedBoard'] % 3] != "" or is_board_full(state, state['forcedBoard'])):
            state['forcedBoard'] = None

        game_winner = check_big_board_winner(state)
        if game_winner != "":
            state['gameOver'] = True
            state['winner'] = game_winner
        elif is_big_board_full(state):
            state['gameOver'] = True
            state['winner'] = "Pareggio"

        state['currentPlayer'] = "O" if state['currentPlayer'] == "X" else "X"

        socketio.emit('update', {
            'board': state['board'],
            'bigBoard': state['bigBoard'],
            'currentPlayer': state['currentPlayer'],
            'forcedBoard': state['forcedBoard'],
            'gameOver': state['gameOver'],
            'winner': state['winner']
        }, room=room_code)
        
        if state['gameOver']:
            socketio.start_background_task(remove_room_after_delat, room_code)
        
def remove_room_after_delat(room_code):
    import time
    time.sleep(30)
    if room_code in rooms:
        del rooms[room_code]
        
@socketio.on('disconnect')
def hendle_disconnect():
    disconnected_sid = request.sid
    for room_code, room_data in list(rooms.items()):
        if disconnected_sid in room_data['players']:
            room_data['players'].remove(disconnected_sid)
            if disconnected_sid in room_data['player_symbols']:
                del room_data['player_symbols'][disconnected_sid]

            if len(room_data['players']) == 1:
                remaining_sid = room_data['players'][0]
                socketio.emit('opponent_disconnected', room=remaining_sid)

            if len(room_data['players']) == 0:
                del rooms[room_code]
            break

def check_winner_in_small_board(state, r, c):
    sub = state['board'][r][c]
    lines = [
        [0,1,2], [3,4,5], [6,7,8],
        [0,3,6], [1,4,7], [2,5,8],
        [0,4,8], [2,4,6]
    ]
    for line in lines:
        if sub[line[0]] == sub[line[1]] == sub[line[2]] != "":
            return sub[line[0]]
    return ""

def check_big_board_winner(state):
    big = state['bigBoard']
    lines = [
        [0,1,2], [3,4,5], [6,7,8],
        [0,3,6], [1,4,7], [2,5,8],
        [0,4,8], [2,4,6]
    ]
    for line in lines:
        r1, c1 = line[0] // 3, line[0] % 3
        r2, c2 = line[1] // 3, line[1] % 3
        r3, c3 = line[2] // 3, line[2] % 3
        if (big[r1][c1] == big[r2][c2] == big[r3][c3] != "" and 
            big[r1][c1] != "D"):
            return big[r1][c1]
    return ""

def is_board_full(state, index):
    r, c = index // 3, index % 3
    return all(cell != "" for cell in state['board'][r][c])

def is_big_board_full(state):
    return all(all(cell != "" for cell in row) for row in state['bigBoard'])

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=12345, debug=True, log_output=False)