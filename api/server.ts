import dotenv from "dotenv";
// import { expand } from "dotenv-expand";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

dotenv.config({
  path: path.resolve(__dirname, "../.env"),
});

dotenv.config({
  path: path.resolve(__dirname, "./.env"),
});

import express, { Request, Response } from "express";

const app = express();
const port = process.env.APP_PORT || 3000;

app.get("/health", (_req, res: Response) => {
  res.json({
    status: `Conexión establecida con ${process.env.DB_NAME}.`,
  });
});

app.listen(Number(port), () => {
  console.log(`Servidor disponible en: ${process.env.APP_URL}:${port}`);
});
