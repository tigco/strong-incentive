#!/usr/bin/python3
from brownie import Trigger, config, network
from scripts.helpful_scripts import (
    get_account,
)


def deploy_keeper_counter():
    account = get_account()
    contract_to_trigger = config["networks"][network.show_active()][
        "api_consumer_address"
    ]
    return Trigger.deploy(
        config["networks"][network.show_active()]["update_interval"],
        contract_to_trigger,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )


def main():
    deploy_keeper_counter()
