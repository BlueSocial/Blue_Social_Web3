import "@thirdweb-dev/react-native-adapter";
import { useEffect } from 'react';
import axios from 'axios';
import { NativeModules } from 'react-native';
import { createThirdwebClient, getContract } from "thirdweb";
import { useWalletBalance, useReadContract, useActiveAccount } from "thirdweb/react"
import { baseSepolia } from "thirdweb/chains";
import { balanceOf, claimTo, getNFT } from "thirdweb/extensions/erc721";
import SendIceBreaker from "./SendIceBreaker";

const { WalletInfoBridge } = NativeModules;


import { chain, client } from "./ThirdwebClient";

const WalletInfo = ({ account, address, userWallet }) => {

    const activeAccount = useActiveAccount();

    const { data, isLoading, isError }  = useWalletBalance({
        address: activeAccount?.address,
        chain,
        client,
        tokenAddress: "0x7dbc1368A738091Da8E960818bDb9488efaB925A"
    });

    const fetchEthToUsdRate = async (amount) => {
        try {
            const response = await axios.get('https://api.coinbase.com/v2/exchange-rates', {
                params: {
                    currency: 'ETH'
                }
            });
            console.log(response.data.data.rates.USD * amount)
            return parseFloat(response.data.data.rates.USD); // Convert the rate to a number
        } catch (error) {
            console.error('Error fetching ETH to USD rate:', error);
            return null;
        }
    };

    const createHyperLink = () => {
        var walletAddressLink = `https://sepolia.basescan.org/address/${activeAccount?.address}`
        console.log(walletAddressLink);
        return walletAddressLink
    }

    useEffect(() => {
        console.log('useEffect triggered in WalletInfo');
        console.log(userWallet)
        
        const updateBalance = async () => {
            if (data) {
                console.log('Wallet balance:', data.displayValue, data.symbol);
                const cryptoAmount = data.displayValue;
                //const usd = await fetchEthToUsdRate(cryptoAmount);
                const usd = 0.18
                const link = createHyperLink();
                if (usd !== null) {
                    WalletInfoBridge.sendBalance(cryptoAmount.toString(), usd.toString(), activeAccount?.address, link);
                }
            }
        };
    
        updateBalance();
    }, [data?.displayValue]);

    return <>
        <SendIceBreaker />
    </>; 
};

export default WalletInfo;