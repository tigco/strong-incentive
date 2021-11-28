#!/usr/bin/python3
from brownie import Contract, APIConsumer, config, network
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()
    api_contract = Contract.from_abi(
        "APIConsumer",
        config["networks"][network.show_active()]["api_consumer_address"],
        APIConsumer.abi,
    )
    tx = fund_with_link(
        api_contract.address, amount=config["networks"][network.show_active()]["fee"]
    )
    tx.wait(1)
    request_tx = api_contract.requestRewardData({"from": account})
    request_tx.wait(1)
