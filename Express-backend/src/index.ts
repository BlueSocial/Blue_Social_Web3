import express from "express";
import helmet from "helmet";
import cors from "cors";
import rateLimit from "express-rate-limit";
import type { Request, Response, NextFunction } from "express";
import dotenv from "dotenv";
import path from "path";
import POIABI from "../abi/poi.json";

// Load environment variables from .env file
dotenv.config({ path: path.resolve(__dirname, "../.env") });

const app = express();
const {
  PORT,
  TW_ENGINE_URL,
  TW_BACKEND_WALLET,
  TW_ACCESS_TOKEN,
  CLIENT_ID,
  POICONTRACT_ADDRESS,
  CHAIN,
} = process.env;
console.log("🚀 ~ PORT:", PORT);

// Middleware
app.use(helmet());
app.use(
  cors({
    origin: ["*"],
  })
);
app.use(express.json({ limit: "10kb" }));

// Rate Limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: "Too many requests from this IP, please try again after 15 minutes",
});

app.use("/api/v1/", apiLimiter);

// Routes
app.get("/", (req: Request, res: Response) => {
  res.json({ message: "you have reached the blue social engine master" });
});

app.post("/master", async (req: Request, res: Response) => {
  //const unixTimestamp = Math.floor(new Date(timestamp) / 1000);
  const { sender, receiver, timestamp } = req.body;
  try {
    if (!TW_ACCESS_TOKEN || !TW_BACKEND_WALLET || !TW_ENGINE_URL)
      throw new Error("Missing required parameters");

    //commnicate with the engine
    const response = await fetch(
      `${TW_ENGINE_URL}/contract/${CHAIN}/${POICONTRACT_ADDRESS}/write`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${TW_ACCESS_TOKEN}`,
          "x-backend-wallet-address": TW_BACKEND_WALLET,
        },
        body: JSON.stringify({
          functionName: "",
          args: [sender, receiver, timestamp],
          txOverrides: {
            gas: "530000",
            maxFeePerGas: "1000000000",
            maxPriorityFeePerGas: "1000000000",
          },
          abi: POIABI,
        }),
      }
    );

    if (!response.ok) {
      throw new Error(
        `Failed to communicate with the engine: ${response.statusText}`
      );
    }

    res.status(200).json({ message: "Request successfully sent." });
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
});

// Error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error(err.stack);
  res.status(500).send("Something broke!");
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
