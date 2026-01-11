from flask import Flask, request, jsonify
from langchain_ollama import ChatOllama
import json

from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Carica del modello
print("Carico il modello...")
lcmodel = ChatOllama(model="gemma3:4b", temperature=0, reasoning=False)
print("Modello caricato.")

@app.route('/trivia/generate', methods=["GET"])
def generate_trivia():
    difficulty = request.args.get("difficulty", default="easy", type=str)
    topic = request.args.get("topic", default="generale", type=str)

    prompt = f"""
    Genera una domanda di trivia su {topic} di difficoltà "{difficulty}". 
    Rispondi esclusivamente in formato JSON così:
    {{
        "question": "...",
        "answers": ["...", "...", "...", "..."],
        "correctIndex": x
    }}
    """

    try:
        response = lcmodel.invoke([("human", prompt)])
        
        content = response.content.strip()
        
        import re
        match = re.search(r'```(?:json)?\s*({.*?})\s*```', content, re.DOTALL)
        if match:
            content = match.group(1)
        
        data = json.loads(content)
        print(content)
        return jsonify(data)
    except json.JSONDecodeError:
        print(f"Errore: risposta non in formato JSON valido: {content}")
        return jsonify({"error": "Formato JSON non valido"}), 500
    except Exception as e:
        print(f"Errore durante la generazione della domanda: {e}")
        return jsonify({"error": "Impossibile generare domanda"}), 500

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=9000, debug=False)