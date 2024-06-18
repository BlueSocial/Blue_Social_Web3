// file: App.tsx

// this needs to be imported before anything else
import "@thirdweb-dev/react-native-adapter";
import React from 'react';
import ConnectWalletButton from './ConnectWalletButton';

const App = () => {
  return <ConnectWalletButton />;
};

export default App;
