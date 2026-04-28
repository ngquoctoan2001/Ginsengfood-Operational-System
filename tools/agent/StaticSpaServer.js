#!/usr/bin/env node
const fs = require("fs");
const http = require("http");
const path = require("path");
const url = require("url");

const root = path.resolve(process.argv[2] || "dist");
const port = Number(process.argv[3] || 4174);
const host = process.argv[4] || "127.0.0.1";

const contentTypes = new Map([
  [".css", "text/css; charset=utf-8"],
  [".html", "text/html; charset=utf-8"],
  [".js", "text/javascript; charset=utf-8"],
  [".json", "application/json; charset=utf-8"],
  [".map", "application/json; charset=utf-8"],
  [".png", "image/png"],
  [".svg", "image/svg+xml"],
  [".ico", "image/x-icon"],
  [".woff", "font/woff"],
  [".woff2", "font/woff2"],
]);

function resolveRequestPath(requestUrl) {
  const parsed = url.parse(requestUrl || "/");
  const decodedPath = decodeURIComponent(parsed.pathname || "/");
  const requestedPath = decodedPath === "/" ? "/index.html" : decodedPath;
  const absolutePath = path.resolve(root, `.${requestedPath}`);

  if (!absolutePath.startsWith(root)) {
    return null;
  }

  return absolutePath;
}

function sendFile(response, filePath) {
  fs.readFile(filePath, (error, body) => {
    if (error) {
      response.writeHead(500, { "content-type": "text/plain; charset=utf-8" });
      response.end("Internal server error");
      return;
    }

    const contentType = contentTypes.get(path.extname(filePath)) || "application/octet-stream";
    response.writeHead(200, { "content-type": contentType });
    response.end(body);
  });
}

const server = http.createServer((request, response) => {
  const filePath = resolveRequestPath(request.url);
  if (filePath === null) {
    response.writeHead(403, { "content-type": "text/plain; charset=utf-8" });
    response.end("Forbidden");
    return;
  }

  fs.stat(filePath, (statError, stat) => {
    if (!statError && stat.isFile()) {
      sendFile(response, filePath);
      return;
    }

    sendFile(response, path.join(root, "index.html"));
  });
});

server.listen(port, host, () => {
  console.log(`Static SPA server listening at http://${host}:${port}/ from ${root}`);
});

process.on("SIGTERM", () => {
  server.close(() => process.exit(0));
});
