import express from "express";
import helmet from "helmet";
import cors from "cors";
import rateLimit from "express-rate-limit";
import type { Request, Response, NextFunction } from "express";
import dotenv from "dotenv";
import path from "path";
import { abi as poiabi } from "../abi/poi.json";

interface RequestBody {
  senderAddress: string;
  senderId: string;
  receiverAddress: string;
  receiverId: string;
  timestamp: Date;
}

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
console.log(CHAIN);
// Middleware
app.use(helmet());
app.use(
  cors({
    origin: ["https://www.profiles.blue", "*"],
  })
);
app.use(express.json({ limit: "10kb" }));

// Rate Limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: "Too many requests from this IP, please try again after 15 minutes",
});

app.use("/", apiLimiter);

// Routes
app.get("/api/v1/", (req: Request, res: Response) => {
  res.json({ message: "you have reached the blue social engine master" });
});

app.post("/api/v1/poi", async (req: Request, res: Response) => {
  const {
    senderAddress,
    senderId,
    receiverAddress,
    receiverId,
    timestamp,
  }: RequestBody = req.body as RequestBody;

  // Parse the timestamp to a Date object if it's a string
  const date = new Date(timestamp);

  if (isNaN(date.getTime())) {
    throw new Error("Invalid timestamp");
  }

  const unixTimestamp = Math.floor(date.getTime() / 1000);

  try {
    //verify required parameters
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
          functionName: "rewardUsers",
          args: [
            senderAddress,
            Number(senderId),
            receiverAddress,
            Number(receiverId),
            unixTimestamp,
          ],
          txOverrides: {
            gas: "530000",
            maxFeePerGas: "1000000000",
            maxPriorityFeePerGas: "1000000000",
          },
          abi: [
            {
              inputs: [
                {
                  internalType: "address",
                  name: "_senderAddress",
                  type: "address",
                },
                {
                  internalType: "uint256",
                  name: "_senderId",
                  type: "uint256",
                },
                {
                  internalType: "address",
                  name: "_receiverAddress",
                  type: "address",
                },
                {
                  internalType: "uint256",
                  name: "_receiverId",
                  type: "uint256",
                },
                {
                  internalType: "uint256",
                  name: "_timestamp",
                  type: "uint256",
                },
              ],
              stateMutability: "nonpayable",
              type: "function",
              name: "rewardUsers",
            },
          ],
        }),
      }
    );

    if (!response.ok) {
      throw new Error(
        `Failed to communicate with the engine: ${response.statusText}`
      );
    }

    res.status(200).json({ message: "Request successfully sent." });
  } catch (error: unknown) {
    if (error instanceof Error) {
      res.status(500).json({ message: error.message });
    } else {
      res.status(500).json({ message: "An unknown error occurred." });
    }
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
