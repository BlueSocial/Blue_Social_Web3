import "@thirdweb-dev/react-native-adapter";
import {useState, useEffect} from "react"
import { createThirdwebClient } from "thirdweb";
import {ThirdwebProvider} from "thirdweb/react";
import ConnectButton from "./ConnectButton"; 
import SendIceBreaker from "./SendIceBreaker";

import { chain, client } from "./ThirdwebClient";

export default function ConnectWalletButton(props) {
  console.log(props)
  return (
    <ThirdwebProvider>
      <ConnectButton email = {props.email} userId = {props.id}/>
    </ThirdwebProvider>
  );
}
