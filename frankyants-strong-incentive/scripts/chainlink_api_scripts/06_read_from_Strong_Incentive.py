#!/usr/bin/python3
from brownie import APIConsumer, Contract, config, network


def main():
    api_contract = Contract.from_abi(
        "APIConsumer",
        config["networks"][network.show_active()]["api_consumer_address"],
        APIConsumer.abi,
    )

    print("Reading data from {}".format(api_contract.address))
    if api_contract.rewardProportion() == 0:
        print(
            "You may have to wait a minute and then call this again, unless on a local chain!"
        )
    print(f"Result (or reward proportion) = {api_contract.rewardProportion()}")
