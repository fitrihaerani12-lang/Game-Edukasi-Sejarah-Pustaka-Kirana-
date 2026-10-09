const fs = require('fs');
const path = require('path');
const https = require('https');

const AUDIO_DIR = path.join(__dirname, '../assets/audio');
fs.mkdirSync(AUDIO_DIR, { recursive: true });

// ==========================================
// 1. WAV GENERATION UTILITIES
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

// ==========================================
// 2. SFX AUDIO WAVE GENERATORS
// ==========================================

// Soft click - high frequency rapid exponential decay
const sfxClickBuffer = createWavBuffer(44100, 0.08, (t) => {
  const f = 800; // 800 Hz
  const decay = Math.exp(-60 * t);
  return Math.sin(2 * Math.PI * f * t) * decay * 0.4;
});

// Major-third double-chime (C5 then E5)
const sfxCorrectBuffer = createWavBuffer(44100, 0.6, (t) => {
  let val = 0;
  // First note: C5 (523.25 Hz)
  if (t >= 0) {
    const t1 = t;
    val += Math.sin(2 * Math.PI * 523.25 * t1) * Math.exp(-10 * t1) * 0.5;
  }
  // Second note: E5 (659.25 Hz), delayed by 0.1s
  if (t >= 0.1) {
    const t2 = t - 0.1;
    val += Math.sin(2 * Math.PI * 659.25 * t2) * Math.exp(-10 * t2) * 0.5;
  }
  return val * 0.6;
});

// Soft descending buzzer / warning
const sfxWrongBuffer = createWavBuffer(44100, 0.5, (t) => {
  const freq = 220 - (220 - 140) * (t / 0.5);
  const phase = 2 * Math.PI * (220 * t - 0.5 * (220 - 140) * t * t / 0.5);
  let val = Math.sin(phase) * 0.6 + Math.sin(phase * 2) * 0.15;
  
  let env = 1.0;
  if (t < 0.05) {
    env = t / 0.05;
  } else {
    env = Math.exp(-6 * (t - 0.05));
  }
  return val * env * 0.4;
});

// Write SFX files
fs.writeFileSync(path.join(AUDIO_DIR, 'sfx_click.wav'), sfxClickBuffer);
console.log("Generated: sfx_click.wav");

fs.writeFileSync(path.join(AUDIO_DIR, 'sfx_correct.wav'), sfxCorrectBuffer);
console.log("Generated: sfx_correct.wav");

fs.writeFileSync(path.join(AUDIO_DIR, 'sfx_wrong.wav'), sfxWrongBuffer);
console.log("Generated: sfx_wrong.wav");

// ==========================================
// 3. DOWNLOAD BGM FROM INCOMPETECH
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
  },
  {
    url: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Lord%20of%20the%20Land.mp3",
    dest: "bgm_sequence.mp3"
  }
];

function downloadFile(url, destName, callback) {
  const destPath = path.join(AUDIO_DIR, destName);
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
      console.log(`Successfully Downloaded: ${destName}`);
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
    console.log("All audio generation and BGM downloads are completed!");
    process.exit(0);
  }
  
  const track = bgmTracks[currentTrackIdx];
  console.log(`Downloading BGM [${currentTrackIdx + 1}/${bgmTracks.length}]: ${track.dest}...`);
  
  downloadFile(track.url, track.dest, (err) => {
    if (err) {
      console.error(`Error downloading ${track.dest}:`, err.message);
      // Proceed to next anyway
    }
    currentTrackIdx++;
    // Sleep 1 second to be polite to the host
    setTimeout(downloadNext, 1000);
  });
}

downloadNext();
