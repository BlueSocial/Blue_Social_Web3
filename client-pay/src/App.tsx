import { ConnectButton } from "thirdweb/react";
import thirdwebIcon from "./thirdweb.svg";
import { client } from "./client";
import EmbeddePay from "./components/EmbeddedPay";

export function App() {
	return (
		<main className="p-4 pb-10 min-h-[100vh] flex items-center justify-center container max-w-screen-lg mx-auto">
			<EmbeddePay />
		</main>
	);
}
