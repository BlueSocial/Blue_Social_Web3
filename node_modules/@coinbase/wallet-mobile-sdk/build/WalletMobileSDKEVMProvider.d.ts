import { RequestArguments, Web3Provider } from "./types/provider/Web3Provider";
import { JSONRPCRequest, JSONRPCResponse } from "./types/provider/JSONRPC";
import { AddressString, Callback } from "./types/core/type";
import { NativeMMKV } from "react-native-mmkv";
import SafeEventEmitter from "@metamask/safe-event-emitter";
export interface WalletMobileSDKProviderOptions {
    chainId?: number;
    storage?: KVStorage;
    jsonRpcUrl?: string;
    address?: string;
}
export interface KVStorage extends Pick<NativeMMKV, "set" | "getString" | "delete"> {
}
export declare class WalletMobileSDKEVMProvider extends SafeEventEmitter implements Web3Provider {
    private _chainId?;
    private _jsonRpcUrl?;
    private _addresses;
    private _storage;
    constructor(opts?: WalletMobileSDKProviderOptions);
    get selectedAddress(): AddressString | undefined;
    get networkVersion(): string;
    get host(): string;
    get connected(): boolean;
    get chainId(): string;
    supportsSubscriptions(): boolean;
    disconnect(): boolean;
    private _send;
    private _sendAsync;
    send(request: JSONRPCRequest): JSONRPCResponse;
    send(request: JSONRPCRequest[]): JSONRPCResponse[];
    send(request: JSONRPCRequest, callback: Callback<JSONRPCResponse>): void;
    send(request: JSONRPCRequest[], callback: Callback<JSONRPCResponse[]>): void;
    send<T = any>(method: string, params?: any[] | any): Promise<T>;
    sendAsync(request: JSONRPCRequest, callback: Callback<JSONRPCResponse>): void;
    sendAsync(request: JSONRPCRequest[], callback: Callback<JSONRPCResponse[]>): void;
    request<T>(args: RequestArguments): Promise<T>;
    private _sendRequest;
    private _sendMultipleRequestsAsync;
    private _sendRequestAsync;
    private _handleSynchronousMethods;
    private _handleAsynchronouseMethods;
    private _eth_accounts;
    private _eth_coinbase;
    private _net_version;
    private _eth_chainId;
    private _eth_requestAccounts;
    private _personal_sign;
    private _eth_signTypedData;
    private _eth_signTransaction;
    private _prepareTransactionParams;
    private _wallet_switchEthereumChain;
    private _wallet_addEthereumChain;
    private _wallet_watchAsset;
    private _makeEthereumJsonRpcRequest;
    private _makeHandshakeRequest;
    private _makeSDKRequest;
    private _getProviderError;
    private _getChainId;
    private _updateChainId;
    private _setAddresses;
    private _requireAuthorization;
}
//# sourceMappingURL=WalletMobileSDKEVMProvider.d.ts.map