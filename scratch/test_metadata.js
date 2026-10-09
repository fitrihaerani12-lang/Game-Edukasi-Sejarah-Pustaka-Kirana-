const https = require('https');
const fs = require('fs');
const path = require('path');

const urls = [
    "https://cdn.pixabay.com/audio/2021/11/13/audio_cb4f1212a9.mp3",
    "https://cdn.pixabay.com/audio/2021/11/24/audio_82498b22da.mp3",
    "https://cdn.pixabay.com/audio/2021/11/25/audio_91b32e02f9.mp3",
    "https://cdn.pixabay.com/audio/2021/11/23/audio_035a943c87.mp3",
    "https://cdn.pixabay.com/audio/2021/11/01/audio_00fa5593f3.mp3",
    "https://cdn.pixabay.com/audio/2021/08/08/audio_dc39bde808.mp3",
    "https://cdn.pixabay.com/audio/2021/07/27/audio_202082aa0b.mp3",
    "https://cdn.pixabay.com/audio/2021/07/22/audio_9584aae297.mp3",
    "https://cdn.pixabay.com/audio/2020/10/11/audio_746c5a0fb3.mp3",
    "https://cdn.pixabay.com/audio/2021/12/11/audio_0ad0f9e437.mp3",
    "https://cdn.pixabay.com/audio/2024/10/17/audio_5c559ab55e.mp3",
    "https://cdn.pixabay.com/audio/2022/02/21/audio_4e7e25d719.mp3"
];

const options = {
    headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
};

function checkUrl(url) {
    return new Promise((resolve) => {
        https.get(url, options, (res) => {
            let dataSize = 0;
            res.on('data', (chunk) => {
                dataSize += chunk.length;
            });
            res.on('end', () => {
                console.log(`URL: ${url}`);
                console.log(`  Status: ${res.statusCode}`);
                console.log(`  Size: ${dataSize} bytes (${(dataSize / 1024 / 1024).toFixed(2)} MB)`);
                resolve({ url, status: res.statusCode, size: dataSize });
            });
        }).on('error', (err) => {
            console.log(`URL: ${url}`);
            console.log(`  Error: ${err.message}`);
            resolve({ url, error: err.message });
        });
    });
}

async function run() {
    for (const url of urls) {
        await checkUrl(url);
    }
}

run();
