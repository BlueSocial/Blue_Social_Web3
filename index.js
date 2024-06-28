import "@thirdweb-dev/react-native-adapter";
import { AppRegistry } from 'react-native';
import ConnectWalletButton from './ConnectWalletButton';
import { name as appName } from './app.json';
import SendIceBreaker from "./SendIceBreaker";

AppRegistry.registerComponent('ConnectWalletButton', () => ConnectWalletButton);
AppRegistry.registerComponent('SendIceBreaker', () => SendIceBreaker); 