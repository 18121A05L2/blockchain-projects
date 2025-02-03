-include .env

.PHONY : deploy-hack execute deploy-original

deploy-hack:
	forge create  --private-key ${REAL_ACCOUNT_PRIVATE_KEY}  --broadcast --rpc-url https://eth-sepolia.g.alchemy.com/v2/mdt_Q4PnZo1YELFCEs89Ulec7rqpZeGR src/GateKeeperOne.sol:BreakGateKeeperOne --constructor-args 0xAd13c8e9cE58dA83833Aa8deC9B829A539E5B519 --etherscan-api-key ${ETHER_SCAN_API}

deploy-original:
	forge create  --private-key ${REAL_ACCOUNT_PRIVATE_KEY}  --broadcast --rpc-url https://eth-sepolia.g.alchemy.com/v2/mdt_Q4PnZo1YELFCEs89Ulec7rqpZeGR src/GateKeeperOne.sol:GatekeeperOne --etherscan-api-key ${ETHER_SCAN_API}

execute:
	cast send 0x8178aF17A803B67728899f1C4A662FD39Beb6d56 "breakContract(bytes8,uint256)" 0x8000000000007764 416 --private-key ${REAL_ACCOUNT_PRIVATE_KEY} --rpc-url https://eth-sepolia.g.alchemy.com/v2/mdt_Q4PnZo1YELFCEs89Ulec7rqpZeGR