// ignore_for_file: avoid_print, unused_local_variable, no_leading_underscores_for_local_identifiers, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart' as path;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:stock/dataBase/sql.dart';
import 'package:stock/screens/produitDetails.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  List<String> dataTitle = [];
  List<int> dataTitleCount = [];
  late bool isEmpty;
  bool downloadData = true;
  String scanResult = '';

  @override
  void initState() {
    isTableEmpty();

    super.initState();
  }

  //to display data on the screen
  Future<void> getData(String table, String columnName) async {
    final _db = SqlDb();
    final datas = await _db.getData(table);
    Map<String, int> categoryCounts = {}; // Use a Map to store category counts
    dataTitle.clear();

    for (final data in datas) {
      final category = data[columnName];
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    categoryCounts.forEach((category, count) {
      dataTitle.add(category);
      dataTitleCount.add(count);
      print('$columnName: $category, Count: $count');
    });

    setState(() {
      downloadData = false;
    });

    print(dataTitle);
  }

  //to scan qr and bar code
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

  //check if the table is empty or not
  Future<void> isTableEmpty() async {
    final _db = SqlDb();
    isEmpty = await _db.isTableEmpty('stock');
    if (!isEmpty) {
      getData('stock', 'categorie');
    } else {}
    setState(() {
      downloadData = false;
    });
    print('Is table empty? $isEmpty');
  }

  Future<void> checkReferenceExists(String reference) async {
    final _db = SqlDb();
    final datas = await _db.getReference('stock', reference);

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 234, 231, 231),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 47, 213),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          )),
          toolbarHeight: 65,
          centerTitle: true,
          title: const Text(' Stock', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        ),
        body: Stack(
          children: [
            Column(
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
                    )),
                const SizedBox(height: 30),
                downloadData
                    ? const Expanded(
                        child: SpinKitWaveSpinner(
                          size: 50,
                          color: Colors.blue,
                        ),
                      )
                    : isEmpty
                        ? Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: const Text(
                                  "Il n'y a pas de données, veuillez ajouter un fichier à partir du bouton ci-dessous",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: 100,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: dataTitle.length,
                              itemBuilder: (BuildContext context, int index) {
                                String item = dataTitle[index];
                                int count = dataTitleCount[index];
                                double percent = count / 100;
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 10),
                                  child: Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20.0, right: 10, top: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '$count',
                                                  style: const TextStyle(fontSize: 18),
                                                ),
                                                item == 'Food'
                                                    ? const Icon(
                                                        Icons.fastfood,
                                                        color: Colors.green,
                                                      )
                                                    : (item == 'Phone'
                                                        ? const Icon(
                                                            Icons.smartphone,
                                                            color: Colors.blue,
                                                          )
                                                        : (item == 'pc'
                                                            ? const Icon(
                                                                Icons.laptop,
                                                                color: Colors.red,
                                                              )
                                                            : const Icon(Icons.cancel))),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: const Alignment(-1, -1),
                                            child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 20),
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                  ),
                                                )),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: LinearPercentIndicator(
                                              lineHeight: 2.5,
                                              percent: percent,
                                              progressColor: item == 'Food'
                                                  ? Colors.green
                                                  : item == 'Phone'
                                                      ? Colors.blue
                                                      : item == 'pc'
                                                          ? Colors.red
                                                          : Colors.grey,
                                            ),
                                          )
                                        ],
                                      )),
                                );
                              },
                            ),
                          )
              ],
            ),
            Positioned(
              bottom: 25.0,
              right: 20.0,
              child: SpeedDial(
                backgroundColor: const Color.fromARGB(255, 1, 47, 213),
                animatedIcon: AnimatedIcons.menu_close,
                animatedIconTheme: const IconThemeData(size: 22.0),
                spacing: 15,
                spaceBetweenChildren: 10,
                children: [
                  SpeedDialChild(
                    child: const Icon(
                      Icons.move_to_inbox,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.green,
                    label: 'ajouter une fichier',
                    onTap: () {
                      printExcelSheetData();
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(
                      Icons.qr_code,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.red,
                    label: 'Scan',
                    onTap: () {
                      scan();
                      // Handle scan button press
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //to upload the excel file
  void printExcelSheetData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.first.path!);

      print('Selected file path: ${file.path}');
      print('Selected file extension: ${path.extension(file.path)}');

      var bytes = await file.readAsBytes();
      var excel = Excel.decodeBytes(bytes);

      // Specify the sheet name
      String sheetName = 'Sheet1';

      if (excel.tables.containsKey(sheetName)) {
        var sheet = excel.tables[sheetName]!;

        // Retrieve the number of columns
        var columnCount = sheet.maxCols;

        // Define the column indexes for the required data
        var categorieIndex = 0;
        var referenceIndex = 1;
        var nomProduitIndex = 2;
        var prixVenteHtIndex = 3;
        var coutRevientProductionIndex = 4;
        var margeIndex = 5;
        var tauxMargeIndex = 6;

        clean('stock');

        // Iterate through each row and retrieve the data values
        for (var rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
          var row = sheet.rows[rowIndex];

          var categorie = row[categorieIndex]?.value?.toString() ?? '';
          var reference = row[referenceIndex]?.value?.toString() ?? '';
          var nomProduit = row[nomProduitIndex]?.value?.toString() ?? '';
          var prixVenteHt = row[prixVenteHtIndex]?.value as double?;
          var coutRevientProduction = row[coutRevientProductionIndex]?.value as double?;
          var marge = row[margeIndex]?.value as double?;
          var tauxMarge = row[tauxMargeIndex]?.value?.toString() ?? '';

          // Save the data in the SQLite table
          await saveData(categorie, reference, nomProduit, prixVenteHt, coutRevientProduction, marge, tauxMarge);
        }
        getData('stock', 'categorie');
        setState(() {
          isEmpty = false;
        });
      } else {
        print('Sheet "$sheetName" not found.');
      }
    } else {
      print('No file selected.');
    }
  } // Extract the data for each column

  Future<void> saveData(String categorie, String reference, String nomProduit, double? prixVenteHt, double? coutRevientProduction,
      double? marge, String tauxMarge) async {
    final _db = SqlDb();
    await _db.insertProduit(
      categorie,
      reference,
      nomProduit,
      prixVenteHt ?? 0.0,
      coutRevientProduction ?? 0.0,
      marge ?? 0.0,
      tauxMarge,
    );
    print('data saved seccessfuly');
  }

  void clean(table) async {
    final _db = SqlDb();
    await _db.cleanTable(table);
  }
}
