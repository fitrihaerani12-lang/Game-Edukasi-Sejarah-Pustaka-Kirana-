const fs = require('fs');
const path = require('path');
const https = require('https');

const BASE_DIR = path.dirname(__dirname);
const BGM_DIR = path.join(BASE_DIR, "assets", "audio", "bgm");
const SFX_DIR = path.join(BASE_DIR, "assets", "audio", "sfx");

fs.mkdirSync(BGM_DIR, { recursive: true });
fs.mkdirSync(SFX_DIR, { recursive: true });

console.log("Downloading BGM tracks from Pixabay...");

const bgmTracks = [
  {
    // BGM LIBRARY: cozy, magical, soft piano & strings
    url: "https://cdn.pixabay.com/audio/2021/11/13/audio_cb4f1212a9.mp3",
    dest: "bgm_library.mp3"
  },
  {
    // BGM MAP: magical adventure, fantasy travel atmosphere
    url: "https://cdn.pixabay.com/audio/2021/07/27/audio_202082aa0b.mp3",
    dest: "bgm_map.mp3"
  },
  {
    // BGM QUIZ & SEQUENCE: focused, calm, historical immersive puzzle vibe
    url: "https://cdn.pixabay.com/audio/2021/07/22/audio_9584aae297.mp3",
    dest: "bgm_quiz.mp3"
  }
];

function downloadFile(url, destName, callback) {
  const destPath = path.join(BGM_DIR, destName);
  const file = fs.createWriteStream(destPath);
  
  const options = {
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
  };

  https.get(url, options, (response) => {
    if (response.statusCode === 302 || response.statusCode === 301) {
      // Follow redirect
      downloadFile(response.headers.location, destName, callback);
      return;
    }
    
    if (response.statusCode !== 200) {
      fs.unlink(destPath, () => {});
      callback(new Error(`Failed to download ${destName} (HTTP ${response.statusCode})`));
      return;
    }

    response.pipe(file);
    
    file.on('finish', () => {
      file.close();
      console.log(`Successfully Downloaded BGM: ${destName}`);
      callback(null);
    });
  }).on('error', (err) => {
    fs.unlink(destPath, () => {});
    callback(err);
  });
}

// Download sequence
let currentTrackIdx = 0;

function downloadNext() {
  if (currentTrackIdx >= bgmTracks.length) {
    console.log("BGM downloads from Pixabay completed successfully!");
    process.exit(0);
  }
  
  const track = bgmTracks[currentTrackIdx];
  console.log(`Downloading BGM [${currentTrackIdx + 1}/${bgmTracks.length}]: ${track.dest}...`);
  
  downloadFile(track.url, track.dest, (err) => {
    if (err) {
      console.error(`Error downloading ${track.dest}:`, err.message);
      process.exit(1);
    }
    currentTrackIdx++;
    // Sleep 1 second to be polite
    setTimeout(downloadNext, 1000);
  });
}

downloadNext();
