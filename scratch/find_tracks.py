import urllib.request
import json

url = "https://incompetech.com/music/royalty-free/pieces.json"
try:
    print("Fetching pieces.json...")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        
    targets = ["Teller of the Tales", "Folk Round", "Thinking Music", "Lord of the Land"]
    
    for piece in data:
        name = piece.get("title", "")
        if any(t.lower() in name.lower() for t in targets):
            print(f"Match: '{name}' -> Filename: '{piece.get('filename', '')}'")
            
except Exception as e:
    print("Error:", e)
