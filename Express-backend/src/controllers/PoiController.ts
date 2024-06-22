import type { Request, Response, NextFunction } from "express";
import { abi as poiabi } from "../abi/poi.json";

import axios from "axios";

interface RequestBody {
  senderAddress: string;
  senderId: string;
  receiverAddress: string;
  receiverId: string;
  timestamp: Date;
}

export const sendPoiReward = async (req: Request, res: Response) => {
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
    if (
      !process.env.TW_ACCESS_TOKEN ||
      !process.env.TW_BACKEND_WALLET ||
      !process.env.TW_ENGINE_URL
    )
      throw new Error("Missing required parameters");

    const postData = {
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
      abi: poiabi,
    };
    const headers = {
      accept: "application/json",
      "Content-Type": "application/json",
      Authorization: `Bearer ${process.env.TW_ACCESS_TOKEN}`,
      "x-backend-wallet-address": process.env.TW_BACKEND_WALLET,
      "ngrok-skip-browser-warning": "true",
    };

    const apiUrl = `${process.env.TW_ENGINE_URL}/contract/${process.env.CHAIN}/${process.env.POICONTRACT_ADDRESS}/write`;
    axios.post(apiUrl, postData, { headers }).catch((error) => {
      throw new Error(`Error posting data: ${error}`);
    });

    res.status(200).json({ message: "Request successfully sent." });
  } catch (error: unknown) {
    if (error instanceof Error) {
      res.status(500).json({ message: error.message });
    } else {
      res.status(500).json({ message: "An unknown error occurred." });
    }
  }
};
