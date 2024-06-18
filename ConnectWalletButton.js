import "@thirdweb-dev/react-native-adapter";
import React from "react";
import { ThirdwebProvider, ConnectButton, createThirdwebClient } from "thirdweb/react";
import { createWallet } from "thirdweb/wallets";

const client = createThirdwebClient({
  clientId: "d3ef52c9a18c17eba1e1fc43d862671c", // Replace with your Thirdweb client ID
});

const wallets = [
  createWallet("com.coinbase.wallet"),
];

const ConnectWalletButton = () => {
  return (
    <ThirdwebProvider>
    <ConnectButton
      client={client}
      wallets={wallets}
      theme={"dark"}
      connectModal={{ size: "wide" }}
    />
  </ThirdwebProvider>
  );
};

export default ConnectWalletButton;
