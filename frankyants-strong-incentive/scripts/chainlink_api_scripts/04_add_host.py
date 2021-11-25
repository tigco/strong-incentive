#!/usr/bin/python3
from brownie import APIConsumer, config, network
from scripts.helpful_scripts import (
    get_account,
    fund_with_link,
)


def add_host():
    account = get_account()
    api_contract = APIConsumer[-1]
    tx = fund_with_link(
        api_contract.address, amount=config["networks"][network.show_active()]["fee"]
    )
    tx.wait(1)
    add_tx = api_contract.addHost(
        "0xB0a829464370366042116bD9a0b9289817b76964", [132143], {"from": account}
    )
    add_tx.wait(1)


def main():
    add_host()
