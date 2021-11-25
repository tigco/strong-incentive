// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

contract APIConsumer is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    //  TODO: see what vars can be made private
    uint256 public rewardProportion;
    address payable[] public deviceHosts;
    mapping (address => uint256[]) public hostedDevices;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    uint256 public rewardUnit;  // In Wei
    uint256 private deviceHostIndex;
    
    /**
     * Network: Kovan
     * Oracle: 0xc57b33452b4f7bb189bb5afae9cc4aba1f7a4fd8
     * Job ID: d5270d1c311941d0b08bead21fea7747
     * Fee: 0.1 LINK
     */
    constructor(address _oracle, bytes32 _jobId, uint256 _fee, uint256 _rewardUnit, address _link) {
        if (_link == address(0)) {
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(_link);
        }
        oracle = _oracle;
        // jobId = stringToBytes32(_jobId);
        jobId = _jobId;
        fee = _fee;
        rewardUnit = _rewardUnit;
    }
    
    function addHost(address _host, uint256[] calldata _hostedDevices) public
    {
        // Only for new hosts!
        // TODO: Implement other methods to support update etc, e.g. if deviceHosts.indexOf(_host) then update, else add
        // TODO: Confirm both host address (_host) and devise index (_hostedDevice) have valid values if () {}

        deviceHosts.push(payable(_host));
        hostedDevices[_host] = _hostedDevices;
    }

    /**
     * Create a Chainlink request to retrieve API response and find the target
     * data.
     */
    function requestVolumeData() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
    
        // Set the URL to perform the GET request on
        request.add("get", "https://us-central1-my-testing-and-learning.cloudfunctions.net/fra-purple-air-ext-adapter?id=99&sensor_index=132143");
        
        // TODO: ?? Need to pass the job ID from above to the URL below as a parameter?
        
        // request.add("get", 
        //     string(
        //         abi.encodePacked(
        //             "https://us-central1-my-testing-and-learning.cloudfunctions.net/fra-purple-air-ext-adapter?",
        //             "id=99&",
        //             "sensor_index=",
        //             abi.encodePacked( hostedDevices[ deviceHosts[0] ][0] ) 
        //         )                
        //     )
        // );

        // request.add("content-type", "application/json");
        
        // Set the path to find the desired data in the API response, where the response format is:
        // {
        //   "data":
        //    {
        //      "result": 1,
        //     },
        //   "result": 0,
        //  }
        request.add("path", "data.result");
        
        // Multiply the result by 1000000000000000000 to remove decimals
        // int timesAmount = 10**18;
        // request.addInt("times", timesAmount);
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    /**
     * Receive the response in the form of uint256
     */ 
    function fulfill(bytes32 _requestId, uint256 _rewardProportion) public recordChainlinkFulfillment(_requestId)
    {
        rewardProportion = _rewardProportion;

        // TODO: FIGURE OUT THE REWARD SYSTEM HERE.
        // E.g. if result = 1, i.e. sensor online, read the time since when the sensor is online, 
        // calculate how long has it been (current_time - online_since), calculate earned rewards balance. If more thhan 0.1 ETH
        // then set the online_since to the current datetime and payout. 
        // If result is not 1 (i.e. the sensor offline), save the time when the sensor went offline. How to handle payout or track rewward balance?!?!

        // if (rewardProportion > 0) {
            // TODO: Here call the function to make payout rewards ??
        // }
    }

    // function payoutRewards() {

    //         // TODO: figure out how to get the host of the device from the request to make the payout accordingly. 
    //         deviceHostIndex = 0; // TEMP TEMP . Need to be the index of the actual device host
            
    //         // This is the current recommended method to use. 
    //         (bool sent, bytes memory data) = deviceHosts[deviceHostIndex].call{value: rewardUnit}("");
    //         require(sent, "Failed to send the reward");
    // }

    // function stringToBytes32(string memory source) public pure returns (bytes32 result) {
    //     bytes memory tempEmptyStringTest = bytes(source);
    //     if (tempEmptyStringTest.length == 0) {
    //         return 0x0;
    //     }

    //     assembly {
    //         result := mload(add(source, 32))
    //     }
    // }
}
