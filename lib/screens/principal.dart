// ignore_for_file: use_build_context_synchronously, avoid_print, unused_local_variable, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:quickalert/quickalert.dart';
import 'package:stock/dataBase/sql.dart';
import 'package:stock/screens/marchandise.dart';
import 'package:stock/screens/operation.dart';
import 'package:stock/screens/produitDetails.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  TextEditingController searchController = TextEditingController();
  List<String> items = ['Entrer', 'Sortie', 'Marchandise', 'Inventaire'];
  List<String> images = ['assets/entrer.jpg', 'assets/sortie.jpg', 'assets/marchandise.jpg', 'assets/inventaire.jpg'];
  List<Icon> icons = [
    const Icon(
      Icons.add_circle,
      color: Color.fromARGB(255, 37, 0, 101),
      size: 35,
    ),
    const Icon(
      Icons.add_circle,
      color: Color.fromARGB(255, 37, 0, 101),
      size: 35,
    ),
    const Icon(
      Icons.add_circle,
      color: Color.fromARGB(255, 37, 0, 101),
      size: 35,
    ),
    const Icon(
      Icons.qr_code,
      color: Color.fromARGB(255, 37, 0, 101),
      size: 35,
    )
  ];

  final List<Map<String, dynamic>> categoryData = [
    {'category': 'Smart Phone', 'enter': 80, 'sortie': 60},
    {'category': 'PC', 'enter': 100, 'sortie': 20},
    {'category': 'tv', 'enter': 60, 'sortie': 30},
    // Add more categories here...
  ];
  final List<Map<String, dynamic>> stockData = [
    {'category': 'Smart Phone', 'stock': 50},
    {'category': 'PC', 'stock': 80},
    {'category': 'tv', 'stock': 100},
    {'category': 'laptop', 'stock': 20},
    // Add more categories here...
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 234, 232, 232),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 30, 137),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        )),
        toolbarHeight: 65,
        centerTitle: true,
        title: const Text('Gestion de Stock', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Adjust the position of the shadow
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextField(
                          controller: searchController,
                          minLines: null,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search...',
                          ),
                          onChanged: (String value) {
                            // Handle search input changes
                          },
                          onSubmitted: (String query) {
                            // Handle search submission
                          },
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          searchController.clear();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(Icons.clear),
                        ))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 397,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns in the grid
                    crossAxisSpacing: 12.0, // Spacing between columns
                    mainAxisSpacing: 12.0, // Spacing between rows
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (index == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OperationPage(operation: true)),
                          );
                        }
                        if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OperationPage(operation: false)),
                          );
                        }
                        if (index == 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MarchandisePage()),
                          );
                        } else {
                          scan();
                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(image: AssetImage(images[index]), fit: BoxFit.fitHeight, opacity: 0.35),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              icons[index],
                              Text(
                                items[index],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          )),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 350,
              child: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  title: ChartTitle(
                    text: 'Stock initial de chaque categorie',
                    textStyle: TextStyle(color: const Color.fromARGB(255, 90, 87, 87), fontWeight: FontWeight.bold),
                  ),
                  primaryYAxis: NumericAxis(),
                  series: <ChartSeries>[
                    ColumnSeries<Map<String, dynamic>, String>(
                      dataSource: stockData,
                      xValueMapper: (data, _) => data['category'].toString(),
                      yValueMapper: (data, _) => (data['stock'] as int).toDouble(),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 350,
              child: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  title: ChartTitle(
                      text: "Quantité d'entrée et de sortie pour chaque catégorie",
                      textStyle: TextStyle(color: const Color.fromARGB(255, 90, 87, 87), fontWeight: FontWeight.bold)),
                  series: <ChartSeries>[
                    ColumnSeries<Map<String, dynamic>, String>(
                      dataSource: categoryData,
                      xValueMapper: (data, _) => data['category'].toString(),
                      yValueMapper: (data, _) => (data['enter'] as int).toDouble(),
                      name: 'Entrer',
                      color: Colors.blue,
                    ),
                    ColumnSeries<Map<String, dynamic>, String>(
                      dataSource: categoryData,
                      xValueMapper: (data, _) => data['category'].toString(),
                      yValueMapper: (data, _) => (data['sortie'] as int).toDouble(),
                      name: 'Sortie',
                      color: Colors.red,
                    ),
                  ],
                  legend: Legend(isVisible: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scan() async {
    String scanResult = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Color for the scanner overlay
      'Cancel', // Text for the cancel button
      true, // Enable flash option
      ScanMode.BARCODE, // Scan barcodes
    );

    if (scanResult == '-1') {
      // Barcode scan was cancelled
      print('Barcode scan cancelled');
    } else {
      // Barcode scan result
      print('Barcode scan result: $scanResult');
      setState(() {
        scanResult = scanResult;
      });
      checkReferenceExists(scanResult);
    }

    String qrResult = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Color for the scanner overlay
      'Cancel', // Text for the cancel button
      true, // Enable flash option
      ScanMode.QR, // Scan QR codes
    );

    if (qrResult == '-1') {
      // QR code scan was cancelled
      print('QR code scan cancelled');
    } else {
      // QR code scan result
      print('QR code scan result: $qrResult');
      setState(() {
        scanResult = qrResult;
      });
      checkReferenceExists(qrResult);
    }
  }

  Future<void> checkReferenceExists(String reference) async {
    final _db = SqlDb();
    final datas = await _db.getReference('marchandise', reference);

    if (datas.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProduitDetails(reference: reference)),
      );

      print('Reference exists');
      // Perform your desired actions here
    } else {
      // Reference does not exist in the table
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        barrierDismissible: true,
        title: 'oops...',
        text: "Le produit que vous recherchez n'existe pas",
        confirmBtnText: 'Okey',
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        },
      );
      print('Reference does not exist');
      // Perform your desired actions here
    }
  }
}
