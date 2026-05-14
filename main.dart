import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/digests/keccak.dart';
import 'dart:typed_data';

void main() {
  runApp(HealthrApp());
}

class HealthrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthr - decentralized Health Records',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: RoleSelectionScreen(),
    );
  }
}

// Role Selection Screen
class RoleSelectionScreen extends StatefulWidget {
  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool isPatient = false;
  bool isProvider = false;
  bool isEmergencyAccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Role'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who are you?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text('Patient'),
              value: isPatient,
              onChanged: (value) {
                setState(() {
                  isPatient = value!;
                });
              },
              activeColor: Colors.teal,
            ),
            CheckboxListTile(
              title: Text('Provider'),
              value: isProvider,
              onChanged: (value) {
                setState(() {
                  isProvider = value!;
                });
              },
              activeColor: Colors.teal,
            ),
            CheckboxListTile(
              title: Text('Emergency Access'),
              value: isEmergencyAccess,
              onChanged: (value) {
                setState(() {
                  isEmergencyAccess = value!;
                });
              },
              activeColor: Colors.teal,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (!isPatient && !isProvider && !isEmergencyAccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select at least one role')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        isPatient: isPatient,
                        isProvider: isProvider,
                        isEmergencyAccess: isEmergencyAccess,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Screen with Role-Based UI
class HomeScreen extends StatefulWidget {
  final bool isPatient;
  final bool isProvider;
  final bool isEmergencyAccess;

  HomeScreen({
    required this.isPatient,
    required this.isProvider,
    required this.isEmergencyAccess,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Blockchain configuration
  final String rpcUrl = "https://eth-sepolia.g.alchemy.com/v2/JcSMBjv-ymvbrnape09eUnUOHDGI_43L";
  final String privateKey = "160fe44ba095dee007557d6a639498331b50914c81c418838a0b575e784e2fdb"; // Patient private key
  final String providerPrivateKey = "5dbd60c982eb9039a67c9fe990527e69db31699dfb337f7e253b68bf32f72383"; // Provider private key (replace with a real key)
  final String contractAddress = "0x1c239139e3819ed5678574a981e90abadcea1f68";

  // Smart contract ABI (updated with setEmergencyPin and revokeAccess)
  final String contractAbi = '''[
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "_ipfsHash",
          "type": "bytes32"
        },
        {
          "internalType": "bytes32[]",
          "name": "_fieldHashes",
          "type": "bytes32[]"
        },
        {
          "internalType": "string[]",
          "name": "_fieldNames",
          "type": "string[]"
        }
      ],
      "name": "addPatientRecord",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_patientId",
          "type": "uint256"
        },
        {
          "internalType": "address",
          "name": "_provider",
          "type": "address"
        }
      ],
      "name": "grantAccess",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_patientId",
          "type": "uint256"
        },
        {
          "internalType": "address",
          "name": "_provider",
          "type": "address"
        }
      ],
      "name": "revokeAccess",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_patientId",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "_pin",
          "type": "string"
        }
      ],
      "name": "setEmergencyPin",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_patientId",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "_pin",
          "type": "string"
        }
      ],
      "name": "emergencyAccess",
      "outputs": [
        {
          "internalType": "bytes32",
          "name": "ipfsHash",
          "type": "bytes32"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_patientId",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "_fieldName",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "_fieldValue",
          "type": "string"
        }
      ],
      "name": "verifyRecordField",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "patientId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "bytes32",
          "name": "ipfsHash",
          "type": "bytes32"
        }
      ],
      "name": "RecordAdded",
      "type": "event"
    }
  ]''';

  late Web3Client ethClient;
  late Credentials credentials; // Patient credentials
  late Credentials providerCredentials; // Provider credentials
  late DeployedContract contract;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    // Initialize Web3Client
    ethClient = Web3Client(rpcUrl, http.Client());

    // Initialize patient credentials (used for PatientScreen)
    credentials = EthPrivateKey.fromHex(privateKey);
    final patientAddress = await credentials.extractAddress();
    print("Patient Address: ${patientAddress.hex}");

    // Initialize provider credentials (used for ProviderScreen)
    providerCredentials = EthPrivateKey.fromHex(providerPrivateKey);
    final providerAddress = await providerCredentials.extractAddress();
    print("Provider Address: ${providerAddress.hex}");

    // Initialize the contract
    contract = DeployedContract(
      ContractAbi.fromJson(contractAbi, "Healthr"),
      EthereumAddress.fromHex(contractAddress),
    );

    // Update the state to indicate initialization is complete
    setState(() {
      _isInitialized = true;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until initialization is complete
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Healthr Dashboard'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Count the number of selected roles
    int selectedRolesCount = 0;
    if (widget.isPatient) selectedRolesCount++;
    if (widget.isProvider) selectedRolesCount++;
    if (widget.isEmergencyAccess) selectedRolesCount++;

    // Build the list of screens based on selected roles
    List<Widget> _widgetOptions = <Widget>[];
    if (widget.isPatient) {
      _widgetOptions.add(PatientScreen(
          ethClient: ethClient, credentials: credentials, contract: contract));
    }
    if (widget.isProvider) {
      _widgetOptions.add(ProviderScreen(
          ethClient: ethClient, credentials: providerCredentials, contract: contract));
    }
    if (widget.isEmergencyAccess) {
      _widgetOptions.add(
          EmergencyAccessScreen(ethClient: ethClient, contract: contract));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Healthr Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: _widgetOptions[_selectedIndex],
      // Only show BottomNavigationBar if more than one role is selected
      bottomNavigationBar: selectedRolesCount > 1
          ? BottomNavigationBar(
        items: [
          if (widget.isPatient)
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Patient',
            ),
          if (widget.isProvider)
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Provider',
            ),
          if (widget.isEmergencyAccess)
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency),
              label: 'Emergency',
            ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      )
          : null, // Hide BottomNavigationBar if only one role is selected
    );
  }
}

// Patient Screen (Add Record, Grant/Revoke Access, Set Emergency PIN)
class PatientScreen extends StatefulWidget {
  final Web3Client ethClient;
  final Credentials credentials;
  final DeployedContract contract;

  PatientScreen({required this.ethClient, required this.credentials, required this.contract});

  @override
  _PatientScreenState createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController(text: "0");
  final _nameController = TextEditingController(text: "John Doe");
  final _dobController = TextEditingController(text: "1990-01-01");
  final _genderController = TextEditingController(text: "Male");
  final _nationalIdController = TextEditingController(text: "123456789");
  final _insuranceIdController = TextEditingController(text: "INS12345");
  final _bloodTypeController = TextEditingController(text: "A+");
  final _phoneController = TextEditingController(text: "555-1234");
  final _addressController = TextEditingController(text: "123 Main St");
  final _allergiesController = TextEditingController(text: '["peanuts", "penicillin"]');
  final _medicalHistoryController = TextEditingController(text: '["asthma", "hypertension"]');
  final _medicationsController = TextEditingController(text: '["albuterol", "lisinopril"]');
  final _emergencyContactController = TextEditingController(text: "Jane Doe - 555-5678");
  final _organDonorStatusController = TextEditingController(text: "Yes");
  final _vaccinationRecordsController = TextEditingController(text: '["COVID-19", "Flu"]');
  final _lastCheckupController = TextEditingController(text: "2025-03-01");
  final _doctorNoteController = TextEditingController(text: "Stable condition");
  final _wearableDeviceDataController = TextEditingController(text: '{"steps": 10000, "heartRate": 72}');
  final _fitnessLevelController = TextEditingController(text: "Moderate");
  final _dietPlanController = TextEditingController(text: "Low sodium");
  final _providerAddressController = TextEditingController();
  final _emergencyPinController = TextEditingController(text: "123456");

  String status = "Ready to add record";
  String solidityOutput = "";
  bool isLoading = false;

  Future<String> uploadToIpfs(Map<String, dynamic> data) async {
    final String pinataApiKey = "8c20b29f2724c13f2c8f";
    final String pinataSecretApiKey = "66579590acd4f5994b80c7841c897a4cf6f70f9d2fcfab8bbf5ba69aab4a628c";

    final response = await http.post(
      Uri.parse('https://api.pinata.cloud/pinning/pinJSONToIPFS'),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
        'pinata_api_key': pinataApiKey,
        'pinata_secret_api_key': pinataSecretApiKey,
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['IpfsHash'];
    } else {
      throw Exception('Failed to upload to IPFS: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> addPatientRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      status = "Preparing data...";
      solidityOutput = "";
    });

    try {
      // Step 1: Create JSON from user input
      final patientData = {
        "name": _nameController.text,
        "dob": _dobController.text,
        "gender": _genderController.text,
        "nationalId": _nationalIdController.text,
        "insuranceId": _insuranceIdController.text,
        "bloodType": _bloodTypeController.text,
        "phone": _phoneController.text,
        "address": _addressController.text,
        "allergies": jsonDecode(_allergiesController.text),
        "medicalHistory": jsonDecode(_medicalHistoryController.text),
        "medications": jsonDecode(_medicationsController.text),
        "emergencyContact": _emergencyContactController.text,
        "organDonorStatus": _organDonorStatusController.text,
        "vaccinationRecords": jsonDecode(_vaccinationRecordsController.text),
        "lastCheckup": _lastCheckupController.text,
        "doctorNote": _doctorNoteController.text,
        "wearableDeviceData": jsonDecode(_wearableDeviceDataController.text),
        "fitnessLevel": _fitnessLevelController.text,
        "dietPlan": _dietPlanController.text,
        "timestamp": DateTime.now().toIso8601String(),
      };

      setState(() {
        status = "Computing hashes...";
      });

      // Step 2: Compute hashes for each field
      final fieldNames = patientData.keys.toList();
      final fieldValues = patientData.values.toList();
      final fieldHashes = fieldValues.map((value) {
        final stringValue = value is Map || value is List ? jsonEncode(value) : value.toString();
        return keccakUtf8(stringValue);
      }).toList();

      setState(() {
        status = "Uploading to IPFS...";
      });

      // Step 3: Upload the JSON to IPFS
      final ipfsHash = await uploadToIpfs(patientData);
      final ipfsHashBytes = utf8.encode(ipfsHash);
      final ipfsHashBytes32 = Uint8List(32);
      for (int i = 0; i < ipfsHashBytes.length && i < 32; i++) {
        ipfsHashBytes32[i] = ipfsHashBytes[i];
      }

      setState(() {
        status = "Calling smart contract...";
      });

      // Step 4: Call the addPatientRecord function
      final function = widget.contract.function('addPatientRecord');
      final tx = await widget.ethClient.sendTransaction(
        widget.credentials,
        Transaction.callContract(
          contract: widget.contract,
          function: function,
          parameters: [
            ipfsHashBytes32,
            fieldHashes,
            fieldNames,
          ],
        ),
        chainId: 11155111, // Sepolia chain ID
      );

      setState(() {
        status = "Transaction sent: $tx";
      });

      // Step 5: Wait for the transaction to be mined and parse the event logs
      final receipt = await widget.ethClient.getTransactionReceipt(tx);
      if (receipt != null) {
        final event = widget.contract.event('RecordAdded');
        for (var log in receipt.logs) {
          if (log.topics != null && log.topics!.isNotEmpty) {
            final decoded = event.decodeResults(log.topics!, log.data!);
            final patientId = decoded[0] as BigInt;
            final owner = decoded[1] as EthereumAddress;
            final ipfsHashFromEvent = decoded[2] as String;

            setState(() {
              status = "Transaction confirmed: $tx";
              solidityOutput = "Patient ID: $patientId\nOwner: ${owner.hex}\nIPFS Hash: $ipfsHash\nTransaction Hash: $tx";
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Record added successfully! Tx: $tx")),
            );
            break;
          }
        }
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
        solidityOutput = "Error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> grantAccess() async {
    if (_providerAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a provider address")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      status = "Granting access...";
      solidityOutput = "";
    });

    try {
      final function = widget.contract.function('grantAccess');
      final tx = await widget.ethClient.sendTransaction(
        widget.credentials,
        Transaction.callContract(
          contract: widget.contract,
          function: function,
          parameters: [
            BigInt.parse(_patientIdController.text),
            EthereumAddress.fromHex(_providerAddressController.text),
          ],
        ),
        chainId: 11155111, // Sepolia chain ID
      );

      setState(() {
        status = "Access granted: $tx";
      });

      final receipt = await widget.ethClient.getTransactionReceipt(tx);
      if (receipt != null) {
        setState(() {
          status = "Access confirmed: $tx";
          solidityOutput = "Transaction Hash: $tx";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Access granted successfully! Tx: $tx")),
        );
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
        solidityOutput = "Error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> revokeAccess() async {
    if (_providerAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a provider address")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      status = "Revoking access...";
      solidityOutput = "";
    });

    try {
      final function = widget.contract.function('revokeAccess');
      final tx = await widget.ethClient.sendTransaction(
        widget.credentials,
        Transaction.callContract(
          contract: widget.contract,
          function: function,
          parameters: [
            BigInt.parse(_patientIdController.text),
            EthereumAddress.fromHex(_providerAddressController.text),
          ],
        ),
        chainId: 11155111, // Sepolia chain ID
      );

      setState(() {
        status = "Access revoked: $tx";
      });

      final receipt = await widget.ethClient.getTransactionReceipt(tx);
      if (receipt != null) {
        setState(() {
          status = "Access revocation confirmed: $tx";
          solidityOutput = "Transaction Hash: $tx";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Access revoked successfully! Tx: $tx")),
        );
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
        solidityOutput = "Error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> setEmergencyPin() async {
    if (_emergencyPinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter an emergency PIN")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      status = "Setting emergency PIN...";
      solidityOutput = "";
    });

    try {
      final function = widget.contract.function('setEmergencyPin');
      final tx = await widget.ethClient.sendTransaction(
        widget.credentials,
        Transaction.callContract(
          contract: widget.contract,
          function: function,
          parameters: [
            BigInt.parse(_patientIdController.text),
            _emergencyPinController.text,
          ],
        ),
        chainId: 11155111, // Sepolia chain ID
      );

      setState(() {
        status = "Emergency PIN set: $tx";
      });

      final receipt = await widget.ethClient.getTransactionReceipt(tx);
      if (receipt != null) {
        setState(() {
          status = "Emergency PIN confirmed: $tx";
          solidityOutput = "Transaction Hash: $tx";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Emergency PIN set successfully! Tx: $tx")),
        );
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
        solidityOutput = "Error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Patient Record',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            _buildTextField("Patient ID", _patientIdController, "Please enter patient ID"),
            SizedBox(height: 10),
            _buildTextField("Name", _nameController, "Please enter name"),
            SizedBox(height: 10),
            _buildTextField("Date of Birth (YYYY-MM-DD)", _dobController, "Please enter DOB"),
            SizedBox(height: 10),
            _buildTextField("Gender", _genderController, "Please enter gender"),
            SizedBox(height: 10),
            _buildTextField("National ID", _nationalIdController, "Please enter national ID"),
            SizedBox(height: 10),
            _buildTextField("Insurance ID", _insuranceIdController, "Please enter insurance ID"),
            SizedBox(height: 10),
            _buildTextField("Blood Type", _bloodTypeController, "Please enter blood type"),
            SizedBox(height: 10),
            _buildTextField("Phone", _phoneController, "Please enter phone number"),
            SizedBox(height: 10),
            _buildTextField("Address", _addressController, "Please enter address"),
            SizedBox(height: 10),
            _buildTextField("Allergies (JSON format)", _allergiesController, "Please enter allergies"),
            SizedBox(height: 10),
            _buildTextField("Medical History (JSON format)", _medicalHistoryController, "Please enter medical history"),
            SizedBox(height: 10),
            _buildTextField("Medications (JSON format)", _medicationsController, "Please enter medications"),
            SizedBox(height: 10),
            _buildTextField("Emergency Contact", _emergencyContactController, "Please enter emergency contact"),
            SizedBox(height: 10),
            _buildTextField("Organ Donor Status", _organDonorStatusController, "Please enter organ donor status"),
            SizedBox(height: 10),
            _buildTextField("Vaccination Records (JSON format)", _vaccinationRecordsController, "Please enter vaccination records"),
            SizedBox(height: 10),
            _buildTextField("Last Checkup (YYYY-MM-DD)", _lastCheckupController, "Please enter last checkup date"),
            SizedBox(height: 10),
            _buildTextField("Doctor Note", _doctorNoteController, "Please enter doctor note"),
            SizedBox(height: 10),
            _buildTextField("Wearable Device Data (JSON format)", _wearableDeviceDataController, "Please enter wearable device data"),
            SizedBox(height: 10),
            _buildTextField("Fitness Level", _fitnessLevelController, "Please enter fitness level"),
            SizedBox(height: 10),
            _buildTextField("Diet Plan", _dietPlanController, "Please enter diet plan"),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Status: $status',
                style: TextStyle(fontSize: 16, color: Colors.teal),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Solidity Output:\n$solidityOutput',
                style: TextStyle(fontSize: 16, color: Colors.teal),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: addPatientRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Add Record to Blockchain',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Grant Access to Provider',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            _buildTextField("Provider Address", _providerAddressController, "Please enter provider address"),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: grantAccess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Grant Access',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Revoke Access from Provider',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            _buildTextField("Provider Address", _providerAddressController, "Please enter provider address"),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: revokeAccess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Revoke Access',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Set Emergency PIN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            _buildTextField("Emergency PIN", _emergencyPinController, "Please enter emergency PIN"),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: setEmergencyPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Set Emergency PIN',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String validationMessage) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }
}

// Provider Screen (Verify Record)
class ProviderScreen extends StatefulWidget {
  final Web3Client ethClient;
  final Credentials credentials;
  final DeployedContract contract;

  ProviderScreen({required this.ethClient, required this.credentials, required this.contract});

  @override
  _ProviderScreenState createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  final _patientIdController = TextEditingController(text: "0");
  final _fieldNameController = TextEditingController(text: "name");
  final _fieldValueController = TextEditingController(text: "John Doe");

  String status = "Ready to verify";
  bool isLoading = false;

  Future<void> verifyRecordField() async {
    setState(() {
      isLoading = true;
      status = "Verifying record...";
    });

    try {
      final function = widget.contract.function('verifyRecordField');
      final result = await widget.ethClient.call(
        contract: widget.contract,
        function: function,
        params: [
          BigInt.parse(_patientIdController.text),
          _fieldNameController.text,
          _fieldValueController.text,
        ],
      );

      setState(() {
        status = "Verification result: ${result[0]}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification result: ${result[0]}")),
      );
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify Patient Record',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _patientIdController,
            decoration: InputDecoration(
              labelText: "Patient ID",
              labelStyle: TextStyle(color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _fieldNameController,
            decoration: InputDecoration(
              labelText: "Field Name (e.g., name, dob)",
              labelStyle: TextStyle(color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _fieldValueController,
            decoration: InputDecoration(
              labelText: "Field Value",
              labelStyle: TextStyle(color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Status: $status',
              style: TextStyle(fontSize: 16, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: verifyRecordField,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Verify Record',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Emergency Access Screen
class EmergencyAccessScreen extends StatefulWidget {
  final Web3Client ethClient;
  final DeployedContract contract;

  EmergencyAccessScreen({required this.ethClient, required this.contract});

  @override
  _EmergencyAccessScreenState createState() => _EmergencyAccessScreenState();
}

class _EmergencyAccessScreenState extends State<EmergencyAccessScreen> {
  final _patientIdController = TextEditingController(text: "0");
  final _pinController = TextEditingController();

  String status = "Ready to access";
  bool isLoading = false;

  Future<void> emergencyAccess() async {
    setState(() {
      isLoading = true;
      status = "Accessing record...";
    });

    try {
      final function = widget.contract.function('emergencyAccess');
      final result = await widget.ethClient.call(
        contract: widget.contract,
        function: function,
        params: [
          BigInt.parse(_patientIdController.text),
          _pinController.text,
        ],
      );

      setState(() {
        status = "IPFS Hash: ${result[0]}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Access granted! IPFS Hash: ${result[0]}")),
      );
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Access',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _patientIdController,
            decoration: InputDecoration(
              labelText: "Patient ID",
              labelStyle: TextStyle(color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _pinController,
            decoration: InputDecoration(
              labelText: "Emergency PIN",
              labelStyle: TextStyle(color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Status: $status',
              style: TextStyle(fontSize: 16, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: emergencyAccess,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Access Record',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to compute keccak256 hash
List<int> keccakUtf8(String input) {
  final bytes = utf8.encode(input);
  return keccak256(bytes);
}

List<int> keccak256(List<int> input) {
  final keccak = KeccakDigest(256);
  return keccak.process(Uint8List.fromList(input));
}

// Helper function to convert bytes to hex string
String bytesToHex(List<int> bytes, {bool include0x = true}) {
  final buffer = StringBuffer();
  if (include0x) {
    buffer.write('0x');
  }
  for (var byte in bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

