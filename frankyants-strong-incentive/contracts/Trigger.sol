// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

contract Trigger is KeeperCompatibleInterface {
    /**
    * Public counter variable
    */
    uint public counter;


    /**
    * contractToTrigger is the address of the contract to trigger when upkeep is needed.
    * Use an interval in seconds and a timestamp to slow execution of Upkeep
    */
    uint public immutable interval;
    uint public lastTimeStamp;
    address private contractToTrigger;

    
    constructor(uint updateInterval, address _contractToTrigger) {
      interval = updateInterval;
      contractToTrigger = _contractToTrigger;

      lastTimeStamp = block.timestamp;

      counter = 0;
    }


    function checkUpkeep(bytes calldata checkData) external override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;

        // We don't use the checkData in this example
        // checkData was defined when the Upkeep was registered
        performData = checkData;
    }

    function performUpkeep(bytes calldata performData) external override {
        lastTimeStamp = block.timestamp;
        counter = counter + 1;
        
        // TODO: TRIGGER THE APIConsumer CONTRACT HERE
        APIConsumerInterface contractToCall = APIConsumerInterface(contractToTrigger);
        contractToCall.requestRewardData();

        // We don't use the performData in this example
        // performData is generated by the Keeper's call to your `checkUpkeep` function
        performData;
    }
}


// Interface of the the Contract that is to be called at set intervals.
// This interface should probably be in a separate .sol file probably and should be Imported
interface APIConsumerInterface {
    // function getValue(uint initialValue) returns(uint);
    // function storeValue(uint value);
    // function getValues() returns(uint);
    function fulfill(bytes32 _requestId, uint256 _rewardProportion) external;
    function requestRewardData() external returns(bytes32);
}