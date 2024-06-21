import { ThirdwebProvider, PayEmbed } from "thirdweb/react";
import { base } from "thirdweb/chains";
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
              name: "Base ETH",
              symbol: "ETH",
              icon: "...", // optional
            },
            chain: base,
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