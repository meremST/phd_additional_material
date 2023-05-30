// SPDX-License-Identifier: UNLICENSED
// The deployed contract address in Rinkeby is: https://rinkeby.etherscan.io/address/0x31fae75a7ee2094f367e9e6ce522ef234f5438da
/**
 *Submitted for verification at Etherscan.io on 2020-10-06
*/

pragma solidity >=0.7.0 <0.9.0;

contract remoteConfiguration
{
    //The keyword "public" makes those variables readable from outside and inside.
    //The address type is a 160-bit value that doesn't allow any arithmetic operations
    address public manufacturer;
    
    //This declares a new complex type which will be used for variables later. It will represent a single device.
    struct info {
        address owner;

        //uint256[] configurations;
        uint256 configurations0;
        uint256 configurations1;
        uint256 configurations2;

        uint256 currentConfig;
        uint256 configStartTime;
        uint256 configPeriod;
    }
    
    //The type maps unsigned integers to info. Mappings can be seen as hash tables which are virtually initialized such that
    //every possible key exists and is mapped to a value whose byte-representation is all zeros.
    mapping (uint256 => info) public idInfo;
    
    //bool tempUpdated;
    //uint256 lastTempUpdate;

    modifier onlyManufacturer()
    {
        require(
            msg.sender == manufacturer,
            "Only the mamanufacturer can register a new device."
        );
        _;
    }
    
    constructor() payable 
    {
        manufacturer = msg.sender;
        //manufacturer = 0xFAFC4C0769f69Fc583A09380bD6Ee3136Eb4754C;
        //manufacturer = _manufacturer;
        //tempUpdated = true;
        //lastTempUpdate = block.number;
    }

    function registerDevice(uint256 _identifier, uint256 config0, uint256 config1, uint256 config2) public payable onlyManufacturer {
        idInfo[_identifier].owner = msg.sender;
        idInfo[_identifier].configurations0 = config0; //this is the encrypted default configuration
        idInfo[_identifier].configurations1 = config1;
        idInfo[_identifier].configurations2 = config2;
    }
    
    function transferOwnership(uint _identifier, address buyer) public {
		require(
            msg.sender == idInfo[_identifier].owner,
            "Only the device owner can transfer the ownership."
        );
        idInfo[_identifier].owner = buyer;
        
    }
    
    function upgradeConfiguration(uint256 _identifier, uint256 requestedConfig, uint256 configTimer) public payable 
    {
        require(
            msg.sender == idInfo[_identifier].owner,
            "Only the device owner can request for configuration upgrade."
        );
        
        if( requestedConfig == 1 ){
            if (msg.value < 100000000000000000){ 
                revert(); 
            } else {
                idInfo[_identifier].currentConfig = idInfo[_identifier].configurations1 ;
            }
        } else if( requestedConfig == 2 ){
            if (msg.value < 200000000000000000){ 
                revert(); 
            } else {
                idInfo[_identifier].currentConfig = idInfo[_identifier].configurations2;
            }
        } else {
            revert();
        }
        idInfo[_identifier].configStartTime = block.timestamp;
        idInfo[_identifier].configPeriod = configTimer;
    }
    
        
    function queryConfiguration(uint256 _identifier) public view returns (uint256, uint256)
    {
        if (block.timestamp - idInfo[_identifier].configStartTime < idInfo[_identifier].configPeriod) {
            return (idInfo[_identifier].currentConfig, idInfo[_identifier].configPeriod);
        } else {
            revert();
        }
    }
}
