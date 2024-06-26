import { ThirdwebProvider, PayEmbed } from "thirdweb/react";
import { baseSepolia } from "thirdweb/chains";
import { client } from "../client";

export default function EmbeddePay() {
  return (
    <ThirdwebProvider>
      <PayEmbed
        client={client}
        payOptions={{
          prefillBuy: {
            token: {
              address: import.meta.env.VITE_TOKEN_TO_BUY,
              name: "Blue Token",
              symbol: "Blue",
              icon: "blue-token.png", // optional
            },
            chain: import.meta.env.MODE === "development" ? baseSepolia : baseSepolia,
            allowEdits: {
              amount: true, // allow editing buy amount
              token: false, // disable selecting buy token
              chain: false, // disable selecting buy chain
            },
          },
        }}
      />
    </ThirdwebProvider>
  );
}