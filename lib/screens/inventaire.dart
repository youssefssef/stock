// ignore_for_file: unused_local_variable, use_build_context_synchronously, prefer_const_constructors

import 'dart:io';

import 'package:excel/excel.dart' as ex;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:path/path.dart' as path;
import 'package:quickalert/quickalert.dart';
import 'package:stock/dataBase/sql.dart';

import 'produitDetails.dart';

class InventairePage extends StatefulWidget {
  const InventairePage({super.key});

  @override
  State<InventairePage> createState() => _InventairePageState();
}

class _InventairePageState extends State<InventairePage> {
  TextEditingController searchController = TextEditingController();
  List<String> items = ['Importer', 'Identifier', 'Rapport', 'Inventaire'];
  List<String> dataTitle = [];
  List<int> dataTitleCount = [];

  List<Icon> icons = [
    const Icon(
      Icons.upload_file,
      color: Color.fromARGB(255, 37, 0, 101),
      size: 35,
    ),
    const Icon(
      Icons.qr_code,
      color: Color.fromARGB(255, 37, 0, 101),
      size: 35,
    ),
    const Icon(
      Icons.qr_code_scanner,
      color: Color.fromARGB(255, 37, 0, 101),
      size: 35,
    )
  ];
  List<String> images = ['assets/entrer.jpg', 'assets/sortie.jpg', 'assets/marchandise.jpg', 'assets/inventaire.jpg'];
  int rapportNumber = 0;
  List<String> scannedReferences = [];
  List<Map<String, dynamic>> searchResults = [];

  List<String> itemsSearch = [];
  List<String> filteredItems = [];
  List<String> itemReference = [];

  void filterSearchResults(String query) {
    List<String> tempList = [];
    if (query.isNotEmpty) {
      itemsSearch.forEach((item) {
        if (item.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(item);
        }
      });
    }
    setState(() {
      filteredItems = tempList;
    });
  }

  @override
  void initState() {
    super.initState();
    getName('stock', 'nom_produit');
    getReference('stock', 'reference');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 212, 207, 207),
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
                child: SearchBar(
                  controller: searchController,
                  hintText: 'Search...',
                  hintStyle: MaterialStatePropertyAll(TextStyle(fontSize: 16, color: const Color.fromARGB(255, 113, 112, 112))),
                  leading: Icon(Icons.search),
                  onTap: () {
                    setState(() {
                      filteredItems = [];
                    });
                  },
                  trailing: [
                    IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            filteredItems = [];
                          });
                        },
                        icon: Icon(Icons.clear))
                  ],
                  onChanged: filterSearchResults,
                )),
            const SizedBox(height: 20),
            Stack(children: [
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
                            printExcelSheetData();
                          }
                          if (index == 1) {
                            scan();
                          }
                          if (index == 3) {
                            startScanning();
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
                                if (index == 0) icons[index],
                                if (index == 1) icons[index],
                                if (index == 2)
                                  Text(
                                    '$rapportNumber',
                                    style:
                                        const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 37, 0, 101)),
                                  ),
                                if (index == 3) icons[2],
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
              if (filteredItems.isNotEmpty)
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 400,
                    width: MediaQuery.of(context).size.width / 1.04,
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black)),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final String itemName = filteredItems[index];
                        final int itemIndexInItemsSearch = itemsSearch.indexOf(itemName);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ListTile(
                            title: Text(itemName),
                            leading: Icon(Icons.search),
                            onTap: () {
                              // Handle item selection here.
                              _handleItemSelection(itemName, itemIndexInItemsSearch);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }

// to handle the selected item in search
  void _handleItemSelection(String selectedItem, int selectedIndexInItemsSearch) {
    // You can now use both the selected item and its index in the itemsSearch list.
    print('Selected item: $selectedItem');
    print('Index in itemsSearch list: $selectedIndexInItemsSearch');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProduitDetails(
                reference: itemReference[selectedIndexInItemsSearch],
              )),
    );
  }

  //data for search bar
  void getName(String table, String columnName) async {
    final _db = SqlDb();
    final datas = await _db.getData(table);
    itemsSearch.clear;

    for (final data in datas) {
      final name = data[columnName];
      itemsSearch.add(name);
    }
    print(itemsSearch);
  }

// to get the list of reference
  void getReference(String table, String columnName) async {
    final _db = SqlDb();
    final datas = await _db.getData(table);
    itemReference.clear;

    for (final data in datas) {
      final reference = data[columnName];
      itemReference.add(reference);
    }
    print(itemReference);
  }

//to upload excel file
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
      var excel = ex.Excel.decodeBytes(bytes);

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

        getName('stock', 'nom_produit');
        getReference('stock', 'reference');
      } else {
        print('Sheet "$sheetName" not found.');
      }
    } else {
      print('No file selected.');
    }
  }

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

  //to check refeencce does exist
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

  void startScanning() async {
    String? scanResult;
    do {
      scanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.QR,
      );

      if (scanResult != '-1') {
        setState(() {
          scannedReferences.add(scanResult!);
        });
      }
    } while (scanResult != '-1');

    // Scanning is finished (user pressed cancel), process the scannedReferences list
    processScannedReferences();
  }

  void processScannedReferences() async {
    List<String> enStockList = [];
    List<String> outOfStockList = [];
    final _db = SqlDb();

    for (String reference in scannedReferences) {
      final datas = await _db.getReference('stock', reference);

      if (datas.isNotEmpty) {
        enStockList.add('en stock');
      } else {
        outOfStockList.add('outOfStock');
      }
    }

    // Now you have two lists: enStockList and outOfStockList
    // Do whatever you want with these lists.
    print('En Stock References: $enStockList');
    print('Out of Stock References: $outOfStockList');
  }
}
