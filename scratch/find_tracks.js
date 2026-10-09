const https = require('https');

const url = "https://incompetech.com/music/royalty-free/pieces.json";
console.log("Fetching pieces.json...");

const options = {
  headers: {
    'User-Agent': 'Mozilla/5.0'
  }
};

https.get(url, options, (res) => {
  let body = "";

  res.on("data", (chunk) => {
    body += chunk;
  });

  res.on("end", () => {
    try {
      const data = JSON.parse(body);
      const targets = ["Teller of the Tales", "Folk Round", "Thinking Music", "Lord of the Land"];
      
      data.forEach(piece => {
        const name = piece.title || "";
        if (targets.some(t => name.toLowerCase().includes(t.toLowerCase()))) {
          console.log(`Match: '${name}' -> Filename: '${piece.filename}'`);
        }
      });
    } catch (e) {
      console.error("Parsing error:", e);
    }
  });
}).on("error", (e) => {
  console.error("Error:", e.message);
});
