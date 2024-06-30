import { useEffect, useState, startTransition } from 'react';
import { NativeModules, NativeEventEmitter, Text, View } from 'react-native';
import { createThirdwebClient, readContract, getContract, sendTransaction, waitForReceipt, prepareContractCall, prepareTransaction, prepareEvent, watchContractEvents } from "thirdweb";
import { useActiveAccount, useSendTransaction, useSendCalls, useCallsStatus, useActiveWallet } from "thirdweb/react";
import { getWalletBalance } from "thirdweb/wallets";
import { toWei, toEther } from "thirdweb/utils";
import { baseSepolia } from "thirdweb/chains";
import { approve } from "thirdweb/extensions/erc20";
import { sendCalls } from "thirdweb/wallets/eip5792";

const { WalletInfoBridge } = NativeModules;

import { chain, client } from "./ThirdwebClient";

const eventEmitter = new NativeEventEmitter(NativeModules.RNEventEmitter);
console.log("EventEmitter created");

const SendIceBreaker = () => {
    console.log("SendIceBreaker component rendered");

    const activeAccount = useActiveAccount();
    const activeWallet = useActiveWallet();

    // const { mutateAsync: sendCalls, data: bundleId, error: sendCallsError } = useSendCalls({
    //     client,
    //     waitForResult: true,
    // });

    // const { data: status, isLoading } = useCallsStatus({
    //     bundleId,
    //     client,
    // });

    const contract = getContract({
        client,
        chain,
        address: "0x7dbc1368A738091Da8E960818bDb9488efaB925A", // blue token
    });

    const poiContract = getContract({
        client,
        chain,
        address: '0x086F7ec0CFe508882F5e7E9E73BcA766020f4c0e'
    });

    const myEvent = prepareEvent({
        signature: "event RewardUser(address indexed user, uint256 reward)",
    });

    const createHyperLink = () => {
        var walletAddressLink = `https://sepolia.basescan.org/address/${activeAccount?.address}`
        console.log(walletAddressLink);
        return walletAddressLink
    }

    const getBalance = async () => {
        try {
            const amount = await getWalletBalance({
                address: activeAccount?.address,
                client,
                chain,
                tokenAddress: "0x7dbc1368A738091Da8E960818bDb9488efaB925A"
            });
            return amount;
        } catch (error) {
            console.error('Error fetching balance:', error);
        }
    }

    const events = watchContractEvents({
        contract: poiContract,
        events: [myEvent],
        onEvents: (events) => {
            console.log(events)
            var rewardAmount = toEther(events[0].args.reward)
            console.log(rewardAmount)
            const usd = 0.18
            const link = createHyperLink();
            // update wallet balance here
            getBalance().then(balance => {
                console.log('Balance retrieved:', balance.displayValue);
                WalletInfoBridge.sendBalance(balance.displayValue.toString(), usd.toString(), activeAccount?.address, link);
            }).catch(err => {
                console.error('Failed to retrieve balance:', err);
            });

            WalletInfoBridge.sendRewardAmount(rewardAmount); 
            // send reward tokens amount
            
        },
    });

    const handleBreakTheIce = async () => {
        console.log("Breaking the ice function called");

        if (!activeWallet) {
            console.error("No wallet connected");
            return;
        }

        try {
            const approveBlue = await approve({
                contract,
                spender: "0x086F7ec0CFe508882F5e7E9E73BcA766020f4c0e", // poi
                amount: toWei("1.0"),
            });

            console.log("approveBlue:", approveBlue);

            const { transactionHash: blueTxHash } = await sendTransaction({
                account: activeAccount,
                transaction: approveBlue,
            });

            const iceBreakerTransaction = await prepareContractCall({
                contract: poiContract,
                method: "function sendIceBreaker(address _invitee)",
                params: ['0x54eB82E4Ec25eb173E1668dd5aB0943904d87331'], // joe's address
            });

            console.log("iceBreakerTransaction:", iceBreakerTransaction);
            console.log(`https://${chain.id}.bundler.thirdweb.com/${client.clientId}`)

            const { transactionHash } = await sendTransaction({
                account: activeAccount,
                transaction: iceBreakerTransaction,
            });

            console.log(transactionHash)

            // send notification to swift to go to poi screen

        } catch (error) {
            console.error("Error in handleBreakTheIce:", error);
        }
    };

    useEffect(() => {
        console.log("This is active account address:", activeAccount?.address);
        console.log("This is the active wallet:", activeWallet);

        const handleEvent = () => {
            handleBreakTheIce();
        };

        eventEmitter.addListener('callBreakTheIce', handleEvent);

    }, []);

    return null;
};

export default SendIceBreaker;