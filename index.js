// index.js
import "@thirdweb-dev/react-native-adapter";
import { AppRegistry } from 'react-native';
import ConnectWalletButton from './ConnectWalletButton';
import { name as appName } from './app.json';

AppRegistry.registerComponent('ConnectWalletButton', () => ConnectWalletButton);
