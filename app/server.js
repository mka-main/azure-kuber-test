"use strict";

const http = require("http");
const fs = require("fs");
const path = require("path");

const port = Number(process.env.PORT || 8080);
const publicDir = path.join(__dirname, "public");

const mime = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".png": "image/png",
  ".woff2": "font/woff2",
};

function send(res, status, body, headers) {
  res.writeHead(status, headers);
  res.end(body);
}

function safeFile(urlPath) {
  const decoded = decodeURIComponent((urlPath.split("?")[0] || "/"));
  const relative = decoded === "/" ? "index.html" : decoded.replace(/^\/+/, "");
  const resolved = path.resolve(publicDir, relative);
  if (!resolved.startsWith(publicDir + path.sep) && resolved !== publicDir) {
    return null;
  }
  return resolved;
}

const server = http.createServer((req, res) => {
  const urlPath = req.url || "/";

  if (urlPath === "/healthz" || urlPath === "/health") {
    send(res, 200, "ok\n", { "Content-Type": "text/plain; charset=utf-8" });
    return;
  }

  if (req.method !== "GET" && req.method !== "HEAD") {
    send(res, 405, "method not allowed\n", { "Content-Type": "text/plain; charset=utf-8" });
    return;
  }

  const filePath = safeFile(urlPath);
  if (!filePath) {
    send(res, 400, "bad request\n", { "Content-Type": "text/plain; charset=utf-8" });
    return;
  }

  fs.stat(filePath, (err, stat) => {
    if (err || !stat.isFile()) {
      send(res, 404, "not found\n", { "Content-Type": "text/plain; charset=utf-8" });
      return;
    }
    const ext = path.extname(filePath).toLowerCase();
    const type = mime[ext] || "application/octet-stream";
    res.writeHead(200, { "Content-Type": type, "Cache-Control": "no-cache" });
    if (req.method === "HEAD") {
      res.end();
      return;
    }
    fs.createReadStream(filePath).pipe(res);
  });
});

server.listen(port, "0.0.0.0", () => {
  process.stdout.write(`listening on ${port}\n`);
});
