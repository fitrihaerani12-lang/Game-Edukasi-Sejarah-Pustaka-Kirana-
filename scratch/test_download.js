const https = require('https');

const testUrls = {
    mine: "https://cdn.pixabay.com/audio/2024/10/17/audio_5c559ab55e.mp3",
    shot: "https://cdn.pixabay.com/audio/2022/02/21/audio_4e7e25d719.mp3",
    nice: "https://cdn.pixabay.com/audio/2022/03/10/audio_054d2be21b.mp3",
    test_valid: "https://cdn.pixabay.com/audio/2021/08/09/audio_e2a6340055.mp3"
};

const options = {
    headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
};

function testUrl(name, url) {
    return new Promise((resolve) => {
        console.log(`Testing ${name}: ${url}`);
        https.get(url, options, (res) => {
            let dataSize = 0;
            res.on('data', (chunk) => {
                dataSize += chunk.length;
            });
            res.on('end', () => {
                console.log(`  Status: ${res.statusCode}, Size: ${dataSize} bytes`);
                resolve();
            });
        }).on('error', (err) => {
            console.log(`  Failed: ${err.message}`);
            resolve();
        });
    });
}

async function run() {
    for (const [name, url] of Object.entries(testUrls)) {
        await testUrl(name, url);
    }
}

run();
