
-include .env

.PHONY: install build

install:
	@forge install openzeppelin/openzeppelin-contracts --no-commit
	@forge install https://github.com/dmfxyz/murky.git --no-commit
	@forge install https://github.com/foundry-rs/forge-std --no-commit


build :; forge build