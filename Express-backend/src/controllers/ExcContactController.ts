import type { Request, Response, NextFunction } from "express";
import { abi as excabi } from "../abi/exc.json";

import axios from "axios";

interface RequestBody {
  userAddress: string;
  userId: string;
  contactAddress: string;
  contactId: string;
}

export const sendContactExcReward = async (req: Request, res: Response) => {
  let { userAddress, userId, contactAddress, contactId }: RequestBody =
    req.body as RequestBody;

  if (!userAddress) userAddress = process.env.TREASURY;
  if (!contactAddress) contactAddress = process.env.TREASURY;

  try {
    //verify required parameters
    if (
      !process.env.TW_ACCESS_TOKEN ||
      !process.env.TW_BACKEND_WALLET ||
      !process.env.TW_ENGINE_URL
    )
      throw new Error("Missing required parameters");

    const postData = {
      functionName: "exchangeContact",
      args: [userAddress, Number(userId), contactAddress, Number(contactId)],
      txOverrides: {
        gas: "530000",
        maxFeePerGas: "1000000000",
        maxPriorityFeePerGas: "1000000000",
      },
      abi: excabi,
    };
    const headers = {
      accept: "application/json",
      "Content-Type": "application/json",
      Authorization: `Bearer ${process.env.TW_ACCESS_TOKEN}`,
      "x-backend-wallet-address": process.env.TW_BACKEND_WALLET,
      "ngrok-skip-browser-warning": "true",
    };

    const apiUrl = `${process.env.TW_ENGINE_URL}/contract/${process.env.CHAIN}/${process.env.EXC_CONTRACT_ADDRESS}/write`;
    axios
      .post(apiUrl, postData, { headers })
      .then((response) => {
        res.status(200).json({ message: "Request successfully sent." });
      })
      .catch((error) => {
        if (error.response) {
          // Server responded with a status code outside the 2xx range
          res.status(error.response.status).json({
            message: `Error posting data: ${error.response.data.error.message}`,
          });
        } else if (error.request) {
          // The request was made but no response was received
          res
            .status(500)
            .json({ message: "No response received from the server." });
        } else {
          // Something happened in setting up the request that triggered an error
          res.status(500).json({
            message: `Error setting up the request: ${error.message}`,
          });
        }
      });
  } catch (error: unknown) {
    if (error instanceof Error) {
      res.status(500).json({ message: error.message });
    } else {
      res.status(500).json({ message: "An unknown error occurred." });
    }
  }
};
