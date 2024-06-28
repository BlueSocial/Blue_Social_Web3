import "@thirdweb-dev/react-native-adapter";
import React from 'react';
import ConnectWalletButton from './ConnectWalletButton';
import SendIceBreaker from "./SendIceBreaker";

const App = (props) => {
  console.log(props)
  return (
      <View>
          <ConnectWalletButton props = {props}/>
          <SendIceBreaker />
      </View>
  );
};

export default App;
