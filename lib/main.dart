import 'package:flutter/material.dart';
import 'port_scanner.dart'; // Assuming PortScanner class is defined in this file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Port Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PortScannerPage(),
    );
  }
}

class PortScannerPage extends StatefulWidget {
  @override
  _PortScannerPageState createState() => _PortScannerPageState();
}

class _PortScannerPageState extends State<PortScannerPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _startPortController = TextEditingController();
  final TextEditingController _endPortController = TextEditingController();
  String _scanResults = '';

  void _performScan() async {
    String ipAddress = _ipController.text;
    int startPort = int.tryParse(_startPortController.text) ?? 0;
    int endPort = int.tryParse(_endPortController.text) ?? 0;

    String results = await PortScanner.scanPorts(ipAddress, startPort, endPort);
    setState(() {
      _scanResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Port Scanner'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'IP Address',
              ),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: _startPortController,
              decoration: InputDecoration(
                labelText: 'Start Port',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _endPortController,
              decoration: InputDecoration(
                labelText: 'End Port',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _performScan,
              child: Text('Scan Ports'),
            ),
            SizedBox(height: 20),
            Text(
              'Scan Results:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_scanResults),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
