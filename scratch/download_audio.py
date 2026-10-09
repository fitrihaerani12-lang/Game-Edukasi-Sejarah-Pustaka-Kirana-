import os
import wave
import struct
import math
import urllib.request

# Define paths
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BGM_DIR = os.path.join(BASE_DIR, "assets", "audio", "bgm")
SFX_DIR = os.path.join(BASE_DIR, "assets", "audio", "sfx")

# Ensure directories exist
os.makedirs(BGM_DIR, exist_ok=True)
os.makedirs(SFX_DIR, exist_ok=True)

print("Directories verified.")

# ==========================================
# 1. DOWNLOAD BGM TRACKS (Incompetech Royalty-Free)
# ==========================================

bgm_tracks = [
    {
        "url": "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Teller%20of%20the%20Tales.mp3",
        "dest": os.path.join(BGM_DIR, "bgm_library.mp3")
    },
    {
        "url": "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Folk%20Round.mp3",
        "dest": os.path.join(BGM_DIR, "bgm_map.mp3")
    },
    {
        "url": "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Thinking%20Music.mp3",
        "dest": os.path.join(BGM_DIR, "bgm_quiz.mp3")
    }
]

def download_file(url, dest):
    print(f"Downloading: {url} -> {dest} ...")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'})
    try:
        with urllib.request.urlopen(req) as response:
            with open(dest, 'wb') as f:
                f.write(response.read())
        print(f"Successfully downloaded {os.path.basename(dest)}")
    except Exception as e:
        print(f"Error downloading {os.path.basename(dest)}: {e}")

for track in bgm_tracks:
    download_file(track["url"], track["dest"])

# ==========================================
# 2. GENERATE SFX (click_button.wav)
# ==========================================

sfx_dest = os.path.join(SFX_DIR, "click_button.wav")
sample_rate = 44100
duration = 0.08  # 80ms - short and responsive click

print(f"Generating SFX -> {sfx_dest} ...")

# Create simple wav file using standard wave module
try:
    with wave.open(sfx_dest, 'wb') as w:
        w.setnchannels(1)  # Mono
        w.setsampwidth(2)  # 16-bit PCM (2 bytes)
        w.setframerate(sample_rate)
        
        num_samples = int(sample_rate * duration)
        for i in range(num_samples):
            t = i / sample_rate
            # 800 Hz sine wave click, decaying exponentially
            f = 800
            decay = math.exp(-60 * t)
            amplitude = math.sin(2 * math.PI * f * t) * decay * 0.4
            
            # Convert to 16-bit signed integer
            val = int(max(-32768, min(32767, amplitude * 32767)))
            w.writeframes(struct.pack('<h', val))
            
    print("Successfully generated click_button.wav")
except Exception as e:
    print(f"Error generating SFX: {e}")

print("Audio asset preparation completed successfully.")
