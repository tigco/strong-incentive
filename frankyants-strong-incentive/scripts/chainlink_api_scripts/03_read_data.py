#!/usr/bin/python3
from brownie import APIConsumer


def main():
    api_contract = APIConsumer[-1]
    print("Reading data from {}".format(api_contract.address))
    if api_contract.rewardProportion() == 0:
        print(
            "You may have to wait a minute and then call this again, unless on a local chain!"
        )
    print(f"Result (or reward proportion) = {api_contract.rewardProportion()}")
    print(f"Reward unit = {api_contract.rewardUnit()}")
