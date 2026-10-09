const fs = require('fs');
const path = require('path');
const https = require('https');

const BASE_DIR = path.dirname(__dirname);
const BGM_DIR = path.join(BASE_DIR, "assets", "audio", "bgm");
const SFX_DIR = path.join(BASE_DIR, "assets", "audio", "sfx");

fs.mkdirSync(BGM_DIR, { recursive: true });
fs.mkdirSync(SFX_DIR, { recursive: true });

console.log("Directories verified.");

// ==========================================
// 1. WAV GENERATION UTILITY
// ==========================================

function createWavBuffer(sampleRate, duration, generatorFunc) {
  const numSamples = Math.floor(sampleRate * duration);
  const dataSize = numSamples * 2; // 16-bit PCM (2 bytes per sample)
  const buffer = Buffer.alloc(44 + dataSize);

  // RIFF header
  buffer.write("RIFF", 0);
  buffer.writeUInt32LE(36 + dataSize, 4);
  buffer.write("WAVE", 8);

  // fmt chunk
  buffer.write("fmt ", 12);
  buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20); // PCM format
  buffer.writeUInt16LE(1, 22); // Mono (1 channel)
  buffer.writeUInt32LE(sampleRate, 24);
  buffer.writeUInt32LE(sampleRate * 2, 28); // byte rate (sampleRate * blockAlign)
  buffer.writeUInt16LE(2, 32); // block align
  buffer.writeUInt16LE(16, 34); // 16 bits per sample

  // data chunk
  buffer.write("data", 36);
  buffer.writeUInt32LE(dataSize, 40);

  // Generate samples
  for (let i = 0; i < numSamples; i++) {
    const t = i / sampleRate;
    const sampleVal = generatorFunc(t);
    // Clamp to signed 16-bit range
    const intVal = Math.max(-32768, Math.min(32767, Math.floor(sampleVal * 32767)));
    buffer.writeInt16LE(intVal, 44 + i * 2);
  }

  return buffer;
}

// Generate click_button.wav: exponential decay 800Hz sine click
const sfxClickBuffer = createWavBuffer(44100, 0.08, (t) => {
  const f = 800; // 800 Hz
  const decay = Math.exp(-60 * t);
  return Math.sin(2 * Math.PI * f * t) * decay * 0.4;
});

const sfxDest = path.join(SFX_DIR, 'click_button.wav');
fs.writeFileSync(sfxDest, sfxClickBuffer);
console.log("Successfully generated: click_button.wav");

// ==========================================
// 2. DOWNLOAD BGM TRACKS (Incompetech Royalty-Free)
// ==========================================

const bgmTracks = [
  {
    url: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Teller%20of%20the%20Tales.mp3",
    dest: "bgm_library.mp3"
  },
  {
    url: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Folk%20Round.mp3",
    dest: "bgm_map.mp3"
  },
  {
    url: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Thinking%20Music.mp3",
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
    console.log("Audio asset download and generation completed successfully!");
    process.exit(0);
  }
  
  const track = bgmTracks[currentTrackIdx];
  console.log(`Downloading BGM [${currentTrackIdx + 1}/${bgmTracks.length}]: ${track.dest}...`);
  
  downloadFile(track.url, track.dest, (err) => {
    if (err) {
      console.error(`Error downloading ${track.dest}:`, err.message);
    }
    currentTrackIdx++;
    // Sleep 1 second to be polite to the host
    setTimeout(downloadNext, 1000);
  });
}

downloadNext();
