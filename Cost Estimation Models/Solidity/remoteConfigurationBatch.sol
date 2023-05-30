// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

contract remoteConfiguration
{
    //The keyword "public" makes those variables readable from outside and inside.
    //The address type is a 160-bit value that doesn't allow any arithmetic operations
    address public manufacturer;

    struct batchInfo {
        string batchRootProof; //64 bytes certificate it's signed by batchOwner addr AND THEN by the owner of the parent batch
        string signedRoot; //64 bytes signature of batchroot, by current batchOwner
        string batchRoot; //is the current batch accumulator root
    }

    struct configList {
        uint256 configurations0;
        uint256 configurations1;
        uint256 configurations2;
    }
    
    //This declares a new complex type which will be used for variables later. It will represent a single device.
    struct info {
        address owner;
        uint256 id;
        uint256 idBrother;
        uint256 idFather;
        uint16 depth;
        bool isAlive;

        batchInfo batch;
        configList configurations;

        uint256 currentConfig;
        uint256 configStartTime;
        uint256 configPeriod;
    }
    
    //The type maps unsigned integers to info. Mappings can be seen as hash tables which are virtually initialized such that
    //every possible key exists and is mapped to a value whose byte-representation is all zeros.
    mapping (uint256 => info) public idInfo;
    
    //bool tempUpdated;
    //uint256 lastTempUpdate;
    uint256 lastBatchID;

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
        lastBatchID = 0;
    }

    function registerBatch(uint256 config0, uint256 config1, uint256 config2, batchInfo memory BInfo) public payable onlyManufacturer returns (uint256 id) {
        id = ++lastBatchID;
        configList memory Clist = configList(
            config0, //this is the encrypted default configuration
            config1,
            config2);

        idInfo[id] = info(
                msg.sender,          //     address owner
                id,                  //     uint256 id
                0,                   //     uint256 idBrother;
                0,                   //     uint256 idFather;
                0,                   //     uint16 depth;
                true,                //     bool isAlive;
                BInfo,               //     batchInfo batch;
                Clist,               //     configList configurations;
                config0,             //     uint256 currentConfig;
                0,                   //     uint256 configStartTime;
                0);                  //     uint256 configPeriod;

        return id;
    }
    
    function transferOwnership(uint256 _identifier, address buyer, batchInfo memory newBInfo)  public returns (uint256 newID){
		require(
            msg.sender == idInfo[_identifier].owner,
            "Only the device owner can transfer the ownership."
        );
        newID = ++lastBatchID;
        idInfo[_identifier].owner = buyer;

        idInfo[newID] = info(
                buyer,                                              //     address owner
                newID,                                              //     uint256 id
                0,                                                  //     uint256 idBrother;
                idInfo[_identifier].id,                             //     uint256 idFather;
                idInfo[_identifier].depth+1,                        //     uint16 depth;
                true,                                               //     bool isAlive;
                newBInfo,                                           //     batchInfo batch;
                idInfo[_identifier].configurations,                 //     configList configurations;
                idInfo[_identifier].currentConfig,                  //     uint256 currentConfig;
                idInfo[_identifier].configStartTime,                //     uint256 configStartTime;
                idInfo[_identifier].configPeriod);                  //     uint256 configPeriod;
        
        idInfo[_identifier].isAlive = false;

        return newID;
        
    }

    // Contracts doesn't verify if batches info are valid or not it's the role of the users to verify this offchain and don't accept any transaction that contains fake data
    function divideAndTransfer(uint256 _identifier, address batchOwner1, address batchOwner2, batchInfo memory dataB1, batchInfo memory dataB2) public returns (uint256 newID1, uint256 newID2) {
		require(
            msg.sender == idInfo[_identifier].owner,
            "Only the device owner can transfer the ownership."
        );
        require(
            idInfo[_identifier].isAlive == true, "You tried to divide an already divided batch"
        );
        newID1 = ++lastBatchID;
        newID2 = ++lastBatchID;

        idInfo[newID1] = info(
                batchOwner1,                                        //     address owner
                newID1,                                             //     uint256 id
                newID2,                                             //     uint256 idBrother;
                idInfo[_identifier].id,                             //     uint256 idFather;
                idInfo[_identifier].depth+1,                        //     uint16 depth;
                true,                                               //     bool isAlive;
                dataB1,                                             //     batchInfo batch;
                idInfo[_identifier].configurations,                 //     configList configurations;
                idInfo[_identifier].currentConfig,                  //     uint256 currentConfig;
                idInfo[_identifier].configStartTime,                //     uint256 configStartTime;
                idInfo[_identifier].configPeriod);                  //     uint256 configPeriod;
        
        idInfo[newID2] = info(
                batchOwner2,                                        //     address owner
                newID2,                                             //     uint256 id
                newID1,                                             //     uint256 idBrother;
                idInfo[_identifier].id,                             //     uint256 idFather;
                idInfo[_identifier].depth+1,                        //     uint16 depth;
                true,                                               //     bool isAlive;
                dataB2,                                             //     batchInfo batch;
                idInfo[_identifier].configurations,                 //     configList configurations;
                idInfo[_identifier].currentConfig,                  //     uint256 currentConfig;
                idInfo[_identifier].configStartTime,                //     uint256 configStartTime;
                idInfo[_identifier].configPeriod);                  //     uint256 configPeriod;

        idInfo[_identifier].isAlive = false;

        return (newID1,newID2);
    }
    
    function upgradeConfiguration(uint256 _identifier, uint256 requestedConfig, uint256 configTimer) public payable 
    {
        require(
            msg.sender == idInfo[_identifier].owner,
            "Only the device owner can request for configuration upgrade."
        );

        require(
            idInfo[_identifier].isAlive == true,
            "You can't upgrade a dead batch"
        );
        
        if( requestedConfig == 1 ){
            if (msg.value < 100000000000000000){ 
                revert(); 
            } else {
                idInfo[_identifier].currentConfig = idInfo[_identifier].configurations.configurations1;
            }
        } else if( requestedConfig == 2 ){
            if (msg.value < 200000000000000000){ 
                revert(); 
            } else {
                idInfo[_identifier].currentConfig = idInfo[_identifier].configurations.configurations2;
            }
        } else {
            revert();
        }
        idInfo[_identifier].configStartTime = block.timestamp;
        idInfo[_identifier].configPeriod = configTimer;
    }

    //Give basic batch infos
    /*function getBatchInfo(uint256 id) external view returns(bool alive, string memory batchRootProof, string memory signedRoot, string memory batchRoot, uint16 depth) {
        batchRootProof = idInfo[id].batch.batchRootProof;
        signedRoot = idInfo[id].batch.signedRoot;
        batchRoot = idInfo[id].batch.batchRoot;
        depth = idInfo[id].depth;
        alive = idInfo[id].isAlive;

        return (alive, batchRootProof, signedRoot, batchRoot, depth);
    }*/

    // must return accProof, signedAcc, accumulators, tid and ownerAddr.
    // https://stackoverflow.com/questions/68010434/why-cant-i-return-dynamic-array-in-solidity
    function getBatchProofs(uint256 id) external view returns (uint256[] memory ids, address[] memory owners, string[] memory batchRootProofs, string[] memory signedRoots, string[] memory batchRoots) {
        require(idInfo[id].isAlive == true, "Batch is not alive");

        uint256[] memory idList = new uint256[](idInfo[id].depth+1);
        string[] memory batchRootProofList = new string[](idInfo[id].depth+1);
        string[] memory signedRootList = new string[](idInfo[id].depth+1);
        string[] memory batchRootList = new string[](idInfo[id].depth+1);
        address[] memory ownerList = new address[](idInfo[id].depth+1);
                
        uint256 currentID = id;

        for(uint16 i=0;i<idInfo[id].depth+1; i++){
            idList[i] = idInfo[currentID].id;
            batchRootProofList[i] = idInfo[currentID].batch.batchRootProof;
            batchRootList[i] = idInfo[currentID].batch.batchRoot;
            ownerList[i] = idInfo[currentID].owner;
            signedRootList[i] = idInfo[currentID].batch.signedRoot;

            if(idInfo[currentID].idFather != 0){
                currentID = idInfo[currentID].idFather;
            }
        }
        return (idList,ownerList,batchRootProofList,signedRootList,batchRootList);
    }
    
        
    function queryConfiguration(uint _identifier) public view returns (uint256, uint256)
    {
        require(idInfo[_identifier].isAlive == true, "Batch is not alive");
        if (block.timestamp - idInfo[_identifier].configStartTime < idInfo[_identifier].configPeriod) {
            return (idInfo[_identifier].currentConfig, idInfo[_identifier].configPeriod);
        } else {
            revert();
        }
    }
}
