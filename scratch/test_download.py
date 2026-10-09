import urllib.request
import os

test_urls = {
    "mine": "https://cdn.pixabay.com/audio/2024/10/17/audio_5c559ab55e.mp3",
    "shot": "https://cdn.pixabay.com/audio/2022/02/21/audio_4e7e25d719.mp3",
    "nice": "https://cdn.pixabay.com/audio/2022/03/10/audio_054d2be21b.mp3",
    "test_valid": "https://cdn.pixabay.com/audio/2021/08/09/audio_e2a6340055.mp3"
}

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}

for name, url in test_urls.items():
    print(f"Testing {name}: {url}")
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req) as response:
            size = len(response.read())
            print(f"  Success! Size: {size} bytes")
    except Exception as e:
        print(f"  Failed: {e}")
