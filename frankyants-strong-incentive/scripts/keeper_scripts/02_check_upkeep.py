#!/usr/bin/python3
from brownie import Trigger, config, network
from scripts.helpful_scripts import get_account, fund_with_link


def main():
    account = get_account()
    keeper_contract = Trigger[-1]
    upkeepNeeded, performData = keeper_contract.checkUpkeep.call(
        # "0x000000000000000000000000d04647b7cb523bb9f26730e9b6de1174db7591ad",
        "",
        {"from": account},
    )
    print(f"The status of this upkeep is currently: {upkeepNeeded}")
    print(f"Here is the perform data: {performData}")

    if upkeepNeeded:
        # If upkeep is needed, it is necessary for the APIConsumer to be funded.
        contract_to_trigger = config["networks"][network.show_active()]["api_consumer_address"]
        tx = fund_with_link(
            contract_to_trigger, amount=config["networks"][network.show_active()]["fee"]
        )
        tx.wait(1)
        print(f"Performing upkeep")
        keeper_contract.performUpkeep(
            performData,
            {"from": account},
        )
