# Healthr — Decentralized Health Records System

A blockchain-based decentralized healthcare record management system built using Ethereum smart contracts and IPFS for secure medical data storage and access control.

## About The Project

Healthr is a decentralized healthcare record management platform designed to securely store, manage, and verify patient medical records using blockchain technology.

The system enables:
- Patients to manage and control access to their medical data
- Healthcare providers to verify medical records cryptographically
- Emergency responders to access critical patient data securely using emergency PIN authentication

Healthr uses Ethereum smart contracts for tamper-proof record verification and IPFS for decentralized medical data storage.

## Features

### Patient Features
- Add patient medical records
- Upload decentralized medical data
- Grant access to healthcare providers
- Revoke provider access
- Set emergency access PIN

### Provider Features
- Verify patient record fields on blockchain
- Cryptographic data validation
- Secure access management

### Emergency Features
- Emergency medical access system
- PIN-based patient data retrieval
- IPFS hash retrieval for emergency care

### Security Features
- Blockchain-based verification
- Smart contract access control
- IPFS decentralized storage
- Tamper-proof record validation

## UI Screenshots

### Role Selection Screen

![Role Selection]()

### Patient Dashboard

![Patient Dashboard]()

### Provider Dashboard

![Provider Dashboard]()

### Emergency Access Screen

![Emergency Access]()

## Tech Stack

### Frontend
- DART

### Blockchain
- Solidity
- Ethereum
- Sepolia Testnet
- Smart Contracts

### Decentralized Storage
- IPFS
- Pinata

### Security
- Keccak256 Hashing
- Blockchain Verification
- Access Control Mechanisms

## Smart Contract Functionalities

### Patient Operations
- addPatientRecord()
- grantAccess()
- revokeAccess()
- setEmergencyPin()

### Provider Operations
- verifyRecordField()

### Emergency Operations
- emergencyAccess()

## Workflow

1. Patient adds medical record
2. Data is uploaded to IPFS
3. Record hashes are stored on Ethereum blockchain
4. Patient grants provider access
5. Provider verifies records on-chain
6. Emergency responders access records using emergency PIN

## Security Architecture

- Patient records are hashed using keccak256
- Sensitive medical data is stored on IPFS
- Blockchain stores only verification hashes
- Access permissions are controlled via smart contracts
- Emergency access requires PIN verification

## ⚡ Installation

Clone the repository:

```bash
https://github.com/KumaresanKarthikeyan575/decentralized-health-record-management.git
cd healthr
open main.dart
```

---

# Folder Structure

```md
## Folder Structure
```

```bash
Healthr/
│
├── healthr.sol
├── main.dart
├── pubspec.yaml
├── Readme.md
```

---

# 12. Future Enhancements

```md
## Future Enhancements
```

- Real wallet integration
- Medical file upload support
- AI-powered health analysis
- NFT-based medical identity
- Multi-hospital integration
- Mobile application support
- Real-time emergency alerts

## Author

Kumaresan Karthikeyan

- Blockchain Developer
- Java Full Stack Developer
- Smart Contract Enthusiast
