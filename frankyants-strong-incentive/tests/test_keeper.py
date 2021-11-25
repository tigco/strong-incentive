from brownie import Counter, config
from scripts.helpful_scripts import get_account

# TODO: create/update the necessary mocks. Delete unnecessary ones.

def test_can_call_check_upkeep():
    # Arrange
    interval = 2
    account = get_account()
    counter = Counter.deploy(
        interval, 
        config["networks"]["kovan"]["api_consumer_address"],
        {"from": account}
    )
    upkeepNeeded, performData = counter.checkUpkeep.call(
        "",
        {"from": account},
    )
    assert isinstance(upkeepNeeded, bool)
    assert isinstance(performData, bytes)
