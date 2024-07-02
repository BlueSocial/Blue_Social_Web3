# Blue Social Web3

Welcome to the Blue Social Web3 Public repository! This project aims to incorporate Web3 functionalities into the existing Blue Social iOS Web2 app, allowing users to earn rewards through real-life social interactions using the innovative Proof-of-Interaction (POI) protocol. Our platform fosters meaningful connections and engagement through a Socialize-to-Earn model.

As Will from @Base told us to share, here is what we had prior to buildathon:
- The Swift BLE code is hidden due to IP of Follow-Mee, inc. and shareholders. (Pre-Built)
- Most of the Native iOS app was built previously before Buildathon in Swift.

 And what we built during buildathon:
- We removed a lot of features and built an MVP Web3 version that is on Base during buildathon using React Native components.
- We built smart contracts for the BLUE token, Exchange Contact & Proof-of-Interaction during BASE buildathon.
- We built a rewardUser function that rewards users with tokens after a IRL social interaction.
- We built a PHP backend to talk to Thirdweb Engine during Base buildathon.
- We built a way to show users wallet balance in app of BLUE Sepolia Tokens.
- We built Thirdweb in-app wallets for sign up and sign in.
- We built smart accounts/wallets for users, sponsoring gas fees.
- We built website below and integrated Thirdweb Pay to allow users to buy tokens with credit card / crypto.

[Official Website](https://web3.blue.social/)

[iOS TestFlight Download](https://testflight.apple.com/join/RlfwnoC0)

# Introduction

Blue Social gamifies real-life social interactions by rewarding users with tokens through its Proof-of-Interaction (POI) protocol. The platform aims to foster meaningful connections and engagement through its innovative Socialize-to-Earn model. Think Pokémon-Go but for meeting people.

- BLUE Base Sepolia Contract: 0x7dbc1368A738091Da8E960818bDb9488efaB925A
- Proof-of-Interaction Contract: 0x086F7ec0CFe508882F5e7E9E73BcA766020f4c0e
- Exchange-of-Contact Contract: 0x96c45b8aeb8136af6e98101f481362c82c097015

![Proof Of Interaction flow](/POI.png)

# Features

- Wallet Integration: Uses Thirdweb In-App Wallet to create/connect wallets via email.
- User Authentication: Authenticate users based on their wallet addresses.
- Proof-of-Interaction Protocol: Record and verify social interactions on the blockchain.
- Token Rewards: Distribute Blue Social tokens as rewards for verified interactions.
- User Interface Enhancements: Display user token balances, token rewards and interaction statuses.
- Backend Integration: Secure storage and management of user interaction data and token balances with Thirdweb Engine.
- Security Measures: Ensure secure data encryption and smart contract audits.

# Tech Stack

- Base
- Solidity
- React Native
- Swift
- Thirdweb Engine
- Thirdweb Paymaster
- Thirdweb Smart Wallet
- PHP
- AWS
- Firebase

# License

This project is licensed under the MIT License. See the LICENSE file for details.
