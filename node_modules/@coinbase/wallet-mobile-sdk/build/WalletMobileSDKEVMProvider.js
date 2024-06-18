import { ethErrors } from "eth-rpc-errors";
import { initiateHandshake, isConnected, makeRequest, resetSession, } from "./CoinbaseWalletSDK";
import { bigIntStringFromBN, ensureAddressString, ensureBN, ensureBuffer, ensureIntNumber, ensureParsedJSONObject, hexStringFromBuffer, hexStringFromIntNumber, prepend0x, } from "./types/core/util";
import BN from "bn.js";
import { MMKV } from "react-native-mmkv";
import SafeEventEmitter from "@metamask/safe-event-emitter";
global.Buffer = global.Buffer || require("buffer").Buffer;
const CACHED_ADDRESSES_KEY = "mobile_sdk.addresses";
const CHAIN_ID_KEY = "mobile_sdk.chain_id";
export class WalletMobileSDKEVMProvider extends SafeEventEmitter {
    _chainId;
    _jsonRpcUrl;
    _addresses = [];
    _storage;
    constructor(opts) {
        super();
        this.send = this.send.bind(this);
        this.sendAsync = this.sendAsync.bind(this);
        this.request = this.request.bind(this);
        this._updateChainId = this._updateChainId.bind(this);
        this._setAddresses = this._setAddresses.bind(this);
        this._getChainId = this._getChainId.bind(this);
        this._storage = opts?.storage ?? new MMKV({ id: "mobile_sdk.store" });
        this._chainId = opts?.chainId;
        this._jsonRpcUrl = opts?.jsonRpcUrl;
        const chainId = this._chainId ?? this._getChainId();
        const chainIdStr = prepend0x(chainId.toString(16));
        this.emit("connect", { chainId: chainIdStr });
        const cachedAddresses = opts?.address ?? this._storage.getString(CACHED_ADDRESSES_KEY);
        if (cachedAddresses) {
            const addresses = cachedAddresses.split(" ");
            if (addresses[0] && addresses[0] !== "") {
                this._setAddresses(addresses);
            }
        }
    }
    get selectedAddress() {
        return this._addresses[0] || undefined;
    }
    get networkVersion() {
        return this._getChainId().toString(10);
    }
    get host() {
        if (this._jsonRpcUrl) {
            return this._jsonRpcUrl;
        }
        else {
            throw new Error("No jsonRpcUrl provided");
        }
    }
    get connected() {
        return isConnected();
    }
    get chainId() {
        return prepend0x(this._getChainId().toString(16));
    }
    supportsSubscriptions() {
        return false;
    }
    disconnect() {
        resetSession();
        this._addresses = [];
        this._storage.delete(CACHED_ADDRESSES_KEY);
        this.emit("disconnect");
        return true;
    }
    _send = this.send.bind(this);
    _sendAsync = this.sendAsync.bind(this);
    send(requestOrMethod, callbackOrParams) {
        // send<T>(method, params): Promise<T>
        if (typeof requestOrMethod === "string") {
            const method = requestOrMethod;
            const params = Array.isArray(callbackOrParams)
                ? callbackOrParams
                : callbackOrParams !== undefined
                    ? [callbackOrParams]
                    : [];
            const request = {
                jsonrpc: "2.0",
                id: 0,
                method,
                params,
            };
            return this._sendRequestAsync(request).then((res) => res.result);
        }
        // send(JSONRPCRequest | JSONRPCRequest[], callback): void
        if (typeof callbackOrParams === "function") {
            const request = requestOrMethod;
            const callback = callbackOrParams;
            return this._sendAsync(request, callback);
        }
        // send(JSONRPCRequest[]): JSONRPCResponse[]
        if (Array.isArray(requestOrMethod)) {
            const requests = requestOrMethod;
            return requests.map((r) => this._sendRequest(r));
        }
        // send(JSONRPCRequest): JSONRPCResponse
        const req = requestOrMethod;
        return this._sendRequest(req);
    }
    async sendAsync(request, callback) {
        if (typeof callback !== "function") {
            throw new Error("callback is required");
        }
        // send(JSONRPCRequest[], callback): void
        if (Array.isArray(request)) {
            const arrayCb = callback;
            this._sendMultipleRequestsAsync(request)
                .then((responses) => arrayCb(null, responses))
                .catch((err) => arrayCb(err, null));
            return;
        }
        // send(JSONRPCRequest, callback): void
        const cb = callback;
        return this._sendRequestAsync(request)
            .then((response) => cb(null, response))
            .catch((err) => cb(err, null));
    }
    // request
    async request(args) {
        if (!args || typeof args !== "object" || Array.isArray(args)) {
            throw ethErrors.rpc.invalidRequest({
                message: "Expected a single, non-array, object argument.",
                data: args,
            });
        }
        const { method, params } = args;
        if (typeof method !== "string" || method.length === 0) {
            throw ethErrors.rpc.invalidRequest({
                message: "'args.method' must be a non-empty string.",
                data: args,
            });
        }
        if (params !== undefined &&
            !Array.isArray(params) &&
            (typeof params !== "object" || params === null)) {
            throw ethErrors.rpc.invalidRequest({
                message: "'args.params' must be an object or array if provided.",
                data: args,
            });
        }
        const newParams = params === undefined ? [] : params;
        const id = 0;
        const result = await this._sendRequestAsync({
            method,
            params: newParams,
            jsonrpc: "2.0",
            id,
        });
        return result.result;
    }
    _sendRequest(request) {
        const result = this._handleSynchronousMethods(request);
        if (result === undefined) {
            throw ethErrors.provider.unsupportedMethod(`Unsupported synchronous method: ${request.method}`);
        }
        return {
            jsonrpc: "2.0",
            id: request.id,
            result,
        };
    }
    _sendMultipleRequestsAsync(requests) {
        return Promise.all(requests.map((r) => this._sendRequestAsync(r))); // TODO: Request batching
    }
    _sendRequestAsync(request) {
        return new Promise((resolve, reject) => {
            try {
                // Handle synchronous methods
                const syncResult = this._handleSynchronousMethods(request);
                if (syncResult !== undefined) {
                    return resolve({
                        jsonrpc: "2.0",
                        id: request.id,
                        result: syncResult,
                    });
                }
            }
            catch (error) {
                return reject(error);
            }
            // Handle asynchronous methods
            this._handleAsynchronouseMethods(request)
                .then((res) => res && resolve({ ...res, id: request.id }))
                .catch((error) => reject(error));
        });
    }
    _handleSynchronousMethods({ method }) {
        switch (method) {
            case "eth_accounts":
                return this._eth_accounts();
            case "eth_coinbase":
                return this._eth_coinbase();
            case "net_version":
                return this._net_version();
            case "eth_chainId":
                return this._eth_chainId();
            default:
                return undefined;
        }
    }
    async _handleAsynchronouseMethods(request) {
        const method = request.method;
        const params = request.params || [];
        switch (method) {
            case "eth_requestAccounts":
                return this._eth_requestAccounts();
            case "personal_sign":
                return this._personal_sign(params);
            case "eth_signTypedData_v3":
                return this._eth_signTypedData(params, "v3");
            case "eth_signTypedData_v4":
                return this._eth_signTypedData(params, "v4");
            case "eth_signTransaction":
                return this._eth_signTransaction(params, false);
            case "eth_sendTransaction":
                return this._eth_signTransaction(params, true);
            case "wallet_switchEthereumChain":
                return this._wallet_switchEthereumChain(params);
            case "wallet_addEthereumChain":
                return this._wallet_addEthereumChain(params);
            case "wallet_watchAsset":
                return this._wallet_watchAsset(params);
            default:
                if (this._jsonRpcUrl) {
                    return this._makeEthereumJsonRpcRequest(request, this._jsonRpcUrl);
                }
                else {
                    throw ethErrors.provider.unsupportedMethod({
                        message: `Unsupported method: ${method}`,
                    });
                }
        }
    }
    _eth_accounts() {
        return [...this._addresses];
    }
    _eth_coinbase() {
        return this.selectedAddress ?? null;
    }
    _net_version() {
        return this._getChainId().toString(10);
    }
    _eth_chainId() {
        return hexStringFromIntNumber(this._getChainId());
    }
    async _eth_requestAccounts() {
        const action = {
            method: "eth_requestAccounts",
            params: {},
        };
        const [, account] = await this._makeHandshakeRequest(action);
        this._setAddresses([account.address]);
        return {
            jsonrpc: "2.0",
            id: 0,
            result: [account.address],
        };
    }
    async _personal_sign(params) {
        this._requireAuthorization();
        const message = ensureBuffer(params[0]);
        const address = ensureAddressString(params[1]);
        const action = {
            method: "personal_sign",
            params: {
                message,
                address,
            },
        };
        const res = await this._makeSDKRequest(action);
        return {
            jsonrpc: "2.0",
            id: 0,
            result: res,
        };
    }
    async _eth_signTypedData(params, type) {
        this._requireAuthorization();
        const address = ensureAddressString(params[0]);
        const typedDataJson = JSON.stringify(ensureParsedJSONObject(params[1]));
        const action = {
            method: type === "v3"
                ? "eth_signTypedData_v3"
                : "eth_signTypedData_v4",
            params: {
                address,
                typedDataJson,
            },
        };
        const res = await this._makeSDKRequest(action);
        return {
            jsonrpc: "2.0",
            id: 0,
            result: res,
        };
    }
    async _eth_signTransaction(params, shouldSubmit) {
        this._requireAuthorization();
        const tx = this._prepareTransactionParams(params[0] || {});
        const action = {
            method: shouldSubmit
                ? "eth_sendTransaction"
                : "eth_signTransaction",
            params: {
                fromAddress: tx.fromAddress,
                toAddress: tx.toAddress,
                weiValue: bigIntStringFromBN(tx.weiValue),
                data: hexStringFromBuffer(tx.data),
                nonce: tx.nonce,
                gasPriceInWei: tx.gasPriceInWei
                    ? bigIntStringFromBN(tx.gasPriceInWei)
                    : null,
                maxFeePerGas: tx.maxFeePerGas
                    ? bigIntStringFromBN(tx.maxFeePerGas)
                    : null,
                maxPriorityFeePerGas: tx.maxPriorityFeePerGas
                    ? bigIntStringFromBN(tx.maxPriorityFeePerGas)
                    : null,
                gasLimit: tx.gasLimit ? bigIntStringFromBN(tx.gasLimit) : null,
                chainId: tx.chainId.toString(),
            },
        };
        const res = await this._makeSDKRequest(action);
        return {
            jsonrpc: "2.0",
            id: 0,
            result: res,
        };
    }
    _prepareTransactionParams(tx) {
        const fromAddress = tx.from ? ensureAddressString(tx.from) : null;
        if (!fromAddress) {
            throw new Error("Ethereum address is unavailable");
        }
        const toAddress = tx.to ? ensureAddressString(tx.to) : null;
        const weiValue = tx.value != null ? ensureBN(tx.value) : new BN(0);
        const data = tx.data ? ensureBuffer(tx.data) : Buffer.alloc(0);
        const nonce = tx.nonce != null ? ensureIntNumber(tx.nonce) : null;
        const gasPriceInWei = tx.gasPrice != null ? ensureBN(tx.gasPrice) : null;
        const maxFeePerGas = tx.maxFeePerGas != null ? ensureBN(tx.maxFeePerGas) : null;
        const maxPriorityFeePerGas = tx.maxPriorityFeePerGas != null
            ? ensureBN(tx.maxPriorityFeePerGas)
            : null;
        const gasLimit = tx.gas != null ? ensureBN(tx.gas) : null;
        const chainId = tx.chainId ? ensureIntNumber(tx.chainId) : this._getChainId();
        return {
            fromAddress,
            toAddress,
            weiValue,
            data,
            nonce,
            gasPriceInWei,
            maxFeePerGas,
            maxPriorityFeePerGas,
            gasLimit,
            chainId,
        };
    }
    async _wallet_switchEthereumChain(params) {
        this._requireAuthorization();
        const request = params[0];
        const chainId = parseInt(request.chainId, 16);
        const successResponse = {
            jsonrpc: "2.0",
            id: 0,
            result: null,
        };
        if (ensureIntNumber(chainId) === this._getChainId()) {
            return successResponse;
        }
        const action = {
            method: "wallet_switchEthereumChain",
            params: {
                chainId: chainId.toString(),
            },
        };
        const res = await this._makeSDKRequest(action);
        if (res === null) {
            this._updateChainId(chainId);
        }
        return {
            jsonrpc: "2.0",
            id: 0,
            result: res,
        };
    }
    async _wallet_addEthereumChain(params) {
        this._requireAuthorization();
        const request = params[0];
        if (!request.rpcUrls || request.rpcUrls?.length === 0) {
            throw ethErrors.rpc.invalidParams({
                message: "please pass in at least 1 rpcUrl",
            });
        }
        if (!request.chainName || request.chainName.trim() === "") {
            throw ethErrors.rpc.invalidParams({
                message: "chainName is a required field",
            });
        }
        if (!request.nativeCurrency) {
            throw ethErrors.rpc.invalidParams({
                message: "nativeCurrency is a required field",
            });
        }
        const chainIdNumber = parseInt(request.chainId, 16);
        const action = {
            method: "wallet_addEthereumChain",
            params: {
                chainId: chainIdNumber.toString(),
                blockExplorerUrls: request.blockExplorerUrls ?? null,
                chainName: request.chainName ?? null,
                iconUrls: request.iconUrls ?? null,
                nativeCurrency: request.nativeCurrency ?? null,
                rpcUrls: request.rpcUrls ?? [],
            },
        };
        const res = await this._makeSDKRequest(action);
        return {
            jsonrpc: "2.0",
            id: 0,
            result: res,
        };
    }
    async _wallet_watchAsset(params) {
        this._requireAuthorization();
        const request = (Array.isArray(params) ? params[0] : params);
        if (!request.type) {
            throw ethErrors.rpc.invalidParams({
                message: "Type is required",
            });
        }
        if (request?.type !== "ERC20") {
            throw ethErrors.rpc.invalidParams({
                message: `Asset of type '${request.type}' is not supported`,
            });
        }
        if (!request?.options) {
            throw ethErrors.rpc.invalidParams({
                message: "Options are required",
            });
        }
        if (!request?.options.address) {
            throw ethErrors.rpc.invalidParams({
                message: "Address is required",
            });
        }
        const { address, symbol, image, decimals } = request.options;
        const action = {
            method: "wallet_watchAsset",
            params: {
                type: request.type,
                options: {
                    address,
                    symbol: symbol ?? null,
                    decimals: decimals ?? null,
                    image: image ?? null,
                },
            },
        };
        const res = await this._makeSDKRequest(action);
        return {
            jsonrpc: "2.0",
            id: 0,
            result: res,
        };
    }
    async _makeEthereumJsonRpcRequest(request, jsonRpcUrl) {
        return fetch(jsonRpcUrl, {
            method: "POST",
            body: JSON.stringify(request),
            mode: "cors",
            headers: { "Content-Type": "application/json" },
        })
            .then((res) => res.json())
            .then((json) => {
            if (!json) {
                throw ethErrors.rpc.parse();
            }
            const response = json;
            if (response.error) {
                throw ethErrors.provider.custom(response.error);
            }
            return response;
        });
    }
    async _makeHandshakeRequest(action) {
        try {
            const [[res], account] = await initiateHandshake([action]);
            if (!res.result || !account) {
                throw this._getProviderError(res);
            }
            return [JSON.parse(res.result), account];
        }
        catch (error) {
            if (error.message.match(/(session not found|session expired)/i)) {
                this.disconnect();
                throw ethErrors.provider.disconnected(error.message);
            }
            if (error.message.match(/(denied|rejected)/i)) {
                throw ethErrors.provider.userRejectedRequest();
            }
            throw error;
        }
    }
    async _makeSDKRequest(action) {
        try {
            const [res] = await makeRequest([action]);
            if (res.errorMessage || !res.result) {
                throw this._getProviderError(res);
            }
            return JSON.parse(res.result);
        }
        catch (error) {
            if (error.message.match(/(session not found|session expired)/i)) {
                this.disconnect();
                throw ethErrors.provider.disconnected(error.message);
            }
            if (error.message.match(/(denied|rejected)/i)) {
                throw ethErrors.provider.userRejectedRequest();
            }
            throw error;
        }
    }
    _getProviderError(result) {
        const errorMessage = result.errorMessage ?? "";
        if (errorMessage.match(/(denied|rejected)/i)) {
            return ethErrors.provider.userRejectedRequest();
        }
        else {
            return ethErrors.provider.custom({
                code: result.errorCode ?? 1000,
                message: errorMessage,
            });
        }
    }
    _getChainId() {
        const chainIdStr = this._storage.getString(CHAIN_ID_KEY) || "1";
        const chainId = parseInt(chainIdStr, 10);
        return ensureIntNumber(chainId);
    }
    _updateChainId(chainId) {
        const originalChainId = this._getChainId();
        this._storage.set(CHAIN_ID_KEY, chainId.toString(10));
        const chainChanged = ensureIntNumber(chainId) !== originalChainId;
        if (chainChanged) {
            this.emit("chainChanged", prepend0x(this._getChainId().toString(16)));
        }
    }
    _setAddresses(addresses) {
        const newAddresses = addresses.map((address) => ensureAddressString(address));
        if (JSON.stringify(this._addresses) === JSON.stringify(newAddresses)) {
            return;
        }
        this._addresses = newAddresses;
        this._storage.set(CACHED_ADDRESSES_KEY, newAddresses.join(" "));
        this.emit("accountsChanged", this._addresses);
    }
    _requireAuthorization() {
        if (!this.connected) {
            throw ethErrors.provider.unauthorized();
        }
    }
}
//# sourceMappingURL=WalletMobileSDKEVMProvider.js.map