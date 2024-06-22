import express from "express";
import helmet from "helmet";
import cors from "cors";
import rateLimit from "express-rate-limit";
import type { Request, Response, NextFunction } from "express";
import dotenv from "dotenv";
import path from "path";
import { sendPoiReward } from "./controllers/PoiController";
import { sendContactExcReward } from "./controllers/ExcContactController";

// Load environment variables from .env file
dotenv.config({ path: path.resolve(__dirname, "../.env") });

const app = express();
const { PORT } = process.env;

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
app.post("/api/v1/poi", sendPoiReward);
app.post("/api/v1/exc", sendContactExcReward);

// Error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  res.status(500).send("Something broke!");
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
