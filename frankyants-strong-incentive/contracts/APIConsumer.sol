// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

contract APIConsumer is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    uint256 public rewardProportion;
    uint256 public rewardUnit; // In Wei
    address payable[] private deviceHosts;
    mapping(address => uint256[]) private hostedDevices;
    uint256 private deviceHostIndex;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    // event MakePayout(uint256 deviceHostIndex, uint256 rewardProportion);

    /**
     * Network: Kovan
     * Oracle: 0xc57b33452b4f7bb189bb5afae9cc4aba1f7a4fd8
     * Job ID: d5270d1c311941d0b08bead21fea7747
     * Fee: 0.1 LINK
     */
    constructor(
        address _oracle,
        bytes32 _jobId,
        uint256 _fee,
        uint256 _rewardUnit,
        address _link
    ) {
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
    function requestRewardData() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // Set the URL to perform the GET request on
        request.add(
            "get",
            "https://us-central1-my-testing-and-learning.cloudfunctions.net/fra-purple-air-ext-adapter?id=99&sensor_index=132143"
        );

        // TODO: after the external adapter is published on an oracle and a job is available, use the new job to request the sensor data.

        // Set the path to find the desired data in the API response, where the response format is:
        // {
        //   "data":
        //    {
        //      "result": 1,
        //     },
        //  }
        request.add("path", "data.result");

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(
        bytes32 _requestId,
        // uint256 _deviceHostIndex,
        uint256 _rewardProportion
    ) public recordChainlinkFulfillment(_requestId) 
    {
        // deviceHostIndex = _deviceHostIndex;
        rewardProportion = _rewardProportion;

        // emit MakePayout(deviceHostIndex, rewardProportion);
    }

    // TODO: Finish the payout function. Use openzeppelin/../Ownable.sol
    // function payoutRewards(uint256 _deviceHostIndex, uint256 _rewardProportion) private
    // {
    //     if (rewardProportion > 0) 
    //     {
    //         // TODO: Here call the function to make payout

    //         // TODO: FIGURE OUT THE REWARD SYSTEM HERE.
    //         // E.g. rewardAmount = rewardUnit * rewardProportion / 100
    //         // This is the current recommended method to use.
    //         (bool sent, bytes memory data) = deviceHosts[_deviceHostIndex].call{value: rewardAmount}("");
    //         require(sent, "Failed to send the reward");
    //     }
    // }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract

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
