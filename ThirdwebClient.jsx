import { createThirdwebClient, getContract } from "thirdweb";
import { base, baseSepolia } from "thirdweb/chains";

const clientId = "d3ef52c9a18c17eba1e1fc43d862671c";

if (!clientId) {
	throw new Error(
		"Missing EXPO_PUBLIC_THIRDWEB_CLIENT_ID - make sure to set it in your .env file",
	);
}

export const client = createThirdwebClient({
	clientId,
});

export const chain = baseSepolia;