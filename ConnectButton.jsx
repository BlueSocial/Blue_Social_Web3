import "@thirdweb-dev/react-native-adapter";
import { useState, useEffect } from 'react';
import axios from 'axios';
import { View, Text, TouchableOpacity, StyleSheet, TextInput, Alert, Image } from 'react-native';
import { createThirdwebClient } from "thirdweb";
import { 	useActiveWallet, useWalletBalance, useActiveAccount, useConnect } from "thirdweb/react"
import { baseSepolia } from "thirdweb/chains";
import { embeddedWallet, inAppWallet, smartWallet } from 'thirdweb/wallets';
import { preAuthenticate } from "thirdweb/wallets/in-app"
import NavigationModule from './NavigationModule'; 
import WalletInfo from "./WalletInfo";
import SendIceBreaker from "./SendIceBreaker";

import { chain, client } from "./ThirdwebClient";

const ConnectButton = ( {email, userId} ) => {

  const [screen, setScreen] = useState("email");
  const [sendingOtp, setSendingOtp] = useState(false);
  const [verificationCode, setVerificationCode] = useState("");
  const [session, setSession] = useState(null);
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userAccount, setUserAccount] = useState(null);
  const [userWallet, setUserWallet] = useState(null);
  const { connect, isConnecting } = useConnect({
    client,
    accountAbstraction: {
      chain,
      sponsorGas: true,
    },
  });

  const activeAccount = useActiveAccount();
  const activeWallet = useActiveWallet();

  useEffect(() => {
    console.log("Active account address:", activeAccount?.address);
    console.log("Active wallet:", activeWallet);

    if (activeAccount) {
      console.log("updating wallet address")
      updateWalletAddress(userId, activeAccount?.address);
    }

  }, [activeAccount, activeWallet]);

  const sendEmailCode = async () => {
    if (!email) return;
    setSendingOtp(true);
    try {
      const session = await preAuthenticate({
        client,
        strategy: "email",
        email,
      });
      setSession(session);
      setSendingOtp(false);
      setScreen("code");
      console.log("Sent verification code");
    } catch (error) {
      console.error('Failed to send email code:', error);
      setSendingOtp(false);
    }
  };

  const updateWalletAddress = async (userId, walletAddress) => {
    console.log(userId)
    console.log(activeAccount?.address)
    try {
      const response = await axios.post("https://www.profiles.blue/api/updateWalletAddress", {
        user_id: userId,
        wallet_address: activeAccount?.address,
      });
      if (response.data.status === "Success") {
        console.log(response.data);
        NavigationModule.navigateToTourPage();
      } else {
        console.error("Failed to update wallet address:", response.data);
        Alert.alert("Error", "Failed to update wallet address");
      }
    } catch (error) {
      console.error("Error updating wallet address:", error);
      Alert.alert("Error", "Error updating wallet address");
    }
  };

  const handleLogin = async () => {
    if (!verificationCode || !email || !session) return;
    setIsLoggingIn(true);
    console.log(verificationCode)
    console.log(email)
    console.log(session)
    try {
      await connect(async () => {
        const personalWallet = inAppWallet();
        console.log("🚀 ~ awaitconnect ~ personalWallet:", personalWallet)
        const personalAccount = await personalWallet.connect({
          client,
          strategy: "email",
          email,
          verificationCode,
        });
        console.log(personalAccount)
        const userSmartWallet = smartWallet({
          chain, // the chain where your account will be or is deployed
          factoryAddress: "0xFbB74BCecCB5324E8Ea87eC2184aa7AF836f614f", // your own deployed account factory address
          gasless: true, // enable or disable gasless transactions
        });
        console.log(userSmartWallet)
        const userSmartAccount = await userSmartWallet.connect({
          client,
          personalAccount,
        });
        // console.log(userSmartAccount)
        //console.log(personalAccount) // personal wallet address
        setUserAccount(personalAccount)
        return personalWallet;
      });

      console.log("Logged in")

      //await updateWalletAddress(userId, activeAccount?.address);
      
      setIsLoggingIn(false); 
      setIsLoggedIn(true);

    } catch (error) {
      console.error('Failed to connect wallet:', error);
      setIsLoggingIn(false);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.headerText}>{screen === 'email' ? 'Create Web3 Wallet' : 'Enter OTP code sent to:'}</Text>
        {screen === 'code' && <Text style={styles.emailText}>{email}</Text>}
        <Text style={styles.descriptionText}>
          {screen === 'email'
            ? 'Create a Web3 Wallet to have access to the app and functionalities. This wallet will keep track of your spending and rewards for being social.'
            : ''}
        </Text>
        {!isLoggedIn && (
          screen === 'email' ? (
            <View>
              <Text style={styles.label}>Email</Text>
              <TextInput
                style={styles.input}
                value={email}
                editable={false}
                placeholder='Enter email address'
                keyboardType='email-address'
                placeholderTextColor='#6e6e6e'
              />
              <TouchableOpacity
                onPress={sendEmailCode}
                style={[styles.button, sendingOtp && styles.buttonDisabled]}
                disabled={sendingOtp}
              >
                <Text style={styles.buttonText}>{sendingOtp ? 'Sending...' : 'Create Wallet'}</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <View>
              <TextInput
                style={styles.input}
                value={verificationCode}
                onChangeText={setVerificationCode}
                placeholder='Enter verification code'
                keyboardType='numeric'
                placeholderTextColor='#6e6e6e'
                editable={true}
              />
              <TouchableOpacity
                onPress={handleLogin}
                style={[styles.button, isLoggingIn && styles.buttonDisabled]}
                disabled={isLoggingIn}
              >
                <Text style={styles.buttonText}>{isLoggingIn ? 'Logging in...' : 'Verify'}</Text>
              </TouchableOpacity>
              <Text style={styles.codeExpiresText}>
                Code expires in <Text style={styles.codeExpiresNumber}>15</Text> minutes
              </Text>
            </View>
          )
        )}
        {isLoggedIn && userAccount && (
          <>
            <WalletInfo account = {userAccount} address={userAccount.address} userWallet = {activeWallet} />
          </>
        )}
        {isLoggedIn && !userAccount && (
          <Text style={styles.successMessage}>Please try another email.</Text>
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'flex-start', 
    padding: 16,
    paddingTop: 60,
  },
  content: {
    marginTop: 80, // Move everything down a little more
  },
  headerText: {
    fontSize: 24,
    fontWeight: '400',
    textAlign: 'left', // Align text to the left
    marginBottom: 8,
    color: '#031227',
  },
  emailText: {
    fontSize: 16,
    fontWeight: '300',
    textAlign: 'left', // Align text to the left
    marginBottom: 16,
    color: '#031227',
  },
  descriptionText: {
    fontSize: 16,
    fontWeight: '300',
    textAlign: 'left', // Align text to the left
    marginBottom: 24,
    color: '#98A2B1',
  },
  label: {
    fontSize: 18,
    fontWeight : '400',
    marginBottom: 8,
    color: '#98A2B1',
    textAlign: 'left', // Align text to the left
  },
  input: {
    height: 50,
    borderColor: '#ced4da',
    borderWidth: 1,
    borderRadius: 10,
    marginBottom: 20,
    paddingHorizontal: 15,
    backgroundColor: '#F2F3F4',
    color: '#495057',
  },
  button: {
    backgroundColor: '#0066FF',
    paddingVertical: 15,
    alignItems: 'center',
    borderRadius: 10,
    width: 300, // Adjust the width to make the button smaller horizontally
    alignSelf: 'center', // Center the button horizontally
  },
  buttonDisabled: {
    backgroundColor: '#6c757d',
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
  successMessage: {
    fontSize: 18,
    color: 'green',
    fontWeight: '600',
    textAlign: 'center',
    marginTop: 20,
  },
  codeExpiresText: {
    fontSize: 14,
    color: '#98A2B1',
    textAlign: 'center',
    marginTop: 50,
  },
  codeExpiresNumber: {
    color: '#0066FF', // Blue color for the number
  },
});


export default ConnectButton;