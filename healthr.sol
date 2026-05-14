// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Healthr {
    
    struct PatientRecord {
        bytes32 ipfsHash;
        mapping(string => bytes32) fieldHashes; // fieldName => fieldHash
        address owner;
        mapping(address => bool) authorizedProviders;
        string emergencyPin;
        bool exists;
    }

    uint256 public patientCount;
    mapping(uint256 => PatientRecord) public records;

    event RecordAdded(
        uint256 indexed patientId,
        address owner,
        bytes32 ipfsHash
    );

    function addPatientRecord(
        bytes32 _ipfsHash,
        bytes32[] calldata _fieldHashes,
        string[] calldata _fieldNames
    ) external {
        patientCount++;
        uint256 patientId = patientCount;

        PatientRecord storage record = records[patientId];
        record.ipfsHash = _ipfsHash;
        record.owner = msg.sender;
        record.exists = true;

        for (uint i = 0; i < _fieldNames.length; i++) {
            record.fieldHashes[_fieldNames[i]] = _fieldHashes[i];
        }

        emit RecordAdded(patientId, msg.sender, _ipfsHash);
    }

    function grantAccess(uint256 _patientId, address _provider) external {
        require(records[_patientId].exists, "Patient record does not exist");
        require(records[_patientId].owner == msg.sender, "Only owner can grant access");
        
        records[_patientId].authorizedProviders[_provider] = true;
    }

    function revokeAccess(uint256 _patientId, address _provider) external {
        require(records[_patientId].exists, "Patient record does not exist");
        require(records[_patientId].owner == msg.sender, "Only owner can revoke access");
        
        records[_patientId].authorizedProviders[_provider] = false;
    }

    function setEmergencyPin(uint256 _patientId, string calldata _pin) external {
        require(records[_patientId].exists, "Patient record does not exist");
        require(records[_patientId].owner == msg.sender, "Only owner can set emergency PIN");
        
        records[_patientId].emergencyPin = _pin;
    }

    function emergencyAccess(uint256 _patientId, string calldata _pin) 
        external view returns (bytes32) 
    {
        require(records[_patientId].exists, "Patient record does not exist");
        require(
            keccak256(abi.encodePacked(records[_patientId].emergencyPin)) == 
            keccak256(abi.encodePacked(_pin)), 
            "Invalid emergency PIN"
        );
        
        return records[_patientId].ipfsHash;
    }

    function verifyRecordField(
        uint256 _patientId,
        string calldata _fieldName,
        string calldata _fieldValue
    ) external view returns (bool) {
        require(records[_patientId].exists, "Patient record does not exist");
        
        bytes32 storedHash = records[_patientId].fieldHashes[_fieldName];
        bytes32 computedHash = keccak256(abi.encodePacked(_fieldValue));
        
        return storedHash == computedHash;
    }

    function hasAccess(uint256 _patientId, address _provider) external view returns (bool) {
        return records[_patientId].authorizedProviders[_provider];
    }
}