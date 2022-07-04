import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'QR CODE SCANNER'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> results = [];

  Future<void> _scanQRCode() async {
    try {
      String result = await _scan();
      _addResult(result);
      _launchURL(result);
    } catch (error) {
      _showMessage(error.toString());
    }

    if (!mounted) return;
  }

  Future<String> _scan() async {
    return await FlutterBarcodeScanner.scanBarcode(
      '#005599',
      'Cancel',
      false,
      ScanMode.QR,
    );
  }

  _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
  }

  _addResult(String result) {
    setState(() {
      if (!results.contains(result) && result != '-1') {
        results.add(result);
      }
    });
  }

  _removeResult(index) {
    setState(() {
      results.remove(results[index]);
    });
  }

  _launchURL(String result) async {
    if (Uri.parse(result).isAbsolute) {
      if (await canLaunchUrlString(result)) {
        await launchUrlString(result);
      }
    }
  }

  _copy(String result) {
    Clipboard.setData(ClipboardData(text: result));
    _showMessage('Copiado');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: buildListView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanQRCode(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  ListView buildListView() => ListView.separated(
        separatorBuilder: (context, index) => const Divider(
          color: Colors.blueAccent,
        ),
        itemCount: results.length,
        itemBuilder: (_, int index) {
          return ListTile(
              minVerticalPadding: 20,
              onLongPress: () => _copy(results[index]),
              onTap: () => _launchURL(results[index]),
              trailing: IconButton(
                onPressed: () => _removeResult(index),
                icon: const Icon(
                  Icons.delete,
                ),
              ),
              title: Text(
                results[index],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ));
        },
      );
}
