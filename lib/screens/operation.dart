// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:stock/dataBase/sql.dart';

class OperationPage extends StatefulWidget {
  final bool operation;
  const OperationPage({required this.operation, Key? key}) : super(key: key);

  @override
  State<OperationPage> createState() => _OperationPageState();
}

class _OperationPageState extends State<OperationPage> {
  List<String> operationDetails = ['Référence', 'Nom du Produit', 'Catégorie', "Prix Unitaire", "Date", "Quantité"];
  final TextEditingController totalController = TextEditingController();
  DateTime currentDate = DateTime.now();
  String scanResult = '';
  List<dynamic> dataList = [];

  List<TextEditingController> textControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

//to save the date to the table of the operation
  Future<void> insertOperation(
      String reference, String nomProduit, String categorie, double prixUnitaire, String date, double quantite, double total) async {
    final sqlDb = SqlDb();
    try {
      widget.operation
          ? await sqlDb.insertEntree(reference, nomProduit, categorie, prixUnitaire, date, quantite, total)
          : await sqlDb.insertSortie(reference, nomProduit, categorie, prixUnitaire, date, quantite, total);

      // Refresh the data in the UI (optional)
      getData(widget.operation ? 'entree' : 'sortie');

      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        barrierDismissible: true,
        title: 'success...',
        text: widget.operation
            ? "les détails de la nouvelle entrée sont enregistrés avec succès"
            : "les détails de la nouvelle sortie sont enregistrés avec succès",
        confirmBtnText: 'nouvelle',
        cancelBtnText: "page d'accueil",
        showCancelBtn: true,
        onConfirmBtnTap: () {
          for (int i = 0; i < operationDetails.length; i++) {
            textControllers[i].clear();
          }
          totalController.clear();
          Navigator.of(context).pop();
        },
        onCancelBtnTap: () {
          for (int i = 0; i < operationDetails.length; i++) {
            textControllers[i].clear();
          }
          totalController.clear();
        },
      );
    } catch (e) {
      // Handle any exceptions that might occur during the insertion
      print("Error inserting data: $e");
      // You can show an error message to the user if desired.
    }
  }

  @override
  Widget build(BuildContext context) {
    List<GlobalKey<FormState>> _formKeys = List.generate(
      operationDetails.length,
      (index) => GlobalKey<FormState>(),
    );
    void calculateTotal() {
      double prixUnitaire = double.tryParse(textControllers[3].text) ?? 0.0;
      double stockInitial = double.tryParse(textControllers[5].text) ?? 0.0;
      double total = prixUnitaire * stockInitial;

      // Update the Total field's controller with the calculated value
      totalController.text = total.toStringAsFixed(2); // Adjust the number of decimal places as needed
    }

    String formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);
    textControllers[4].text = formattedDate.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 30, 137),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        )),
        toolbarHeight: 65,
        centerTitle: true,
        title: Text(
          widget.operation ? 'Nouvelle Entrée' : 'Nouvelle Sortie',
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                scan();
              },
              icon: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 25,
              ))
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.1,
              child: const Text(
                "Veuillez saisir les détails de l'operation de vente d'achat ou vous pouvez scanner le code qr/barre : ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3, color: Color.fromARGB(255, 101, 100, 100)),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: operationDetails.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 15),
                    child: Text(
                      '${operationDetails[index]} :',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width / 1.1,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Form(
                        key: _formKeys[index],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: TextFormField(
                            controller: textControllers[index],
                            validator: (value) => value!.isEmpty ? 'ce champ ne devrait pas être vide' : null,
                            onChanged: (value) {
                              if (index == 0) {
                                getDataFromTable('marchandise', textControllers[index].text);
                              }

                              if (index == 5 || index == 4) {
                                calculateTotal();
                              }
                            },
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: operationDetails[index],
                              border: InputBorder.none,
                              filled: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0, top: 15),
                child: Text(
                  'Total :',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width / 1.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      controller: totalController,
                      style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                      enabled: false, // Make this field read-only
                      decoration: const InputDecoration(
                        hintText: 'Total', // You can customize the hint text here
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.3, vertical: 10),
                child: InkWell(
                  onTap: () async {
                    for (int i = 0; i < operationDetails.length; i++) {
                      if (_formKeys[i].currentState!.validate()) {
                        String reference = textControllers[0].text;
                        String nomProduit = textControllers[1].text;
                        String categorie = textControllers[2].text;
                        double prixUnitaire = double.tryParse(textControllers[3].text) ?? 0.0;
                        String date = textControllers[4].text;
                        double quantite = double.tryParse(textControllers[5].text) ?? 0.0;
                        double total = double.tryParse(totalController.text) ?? 0.0;

                        await insertOperation(reference, nomProduit, categorie, prixUnitaire, date, quantite, total);
                      }
                    }
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 44, 0, 120),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Ajouter',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void cleanTable(table) async {
    final _db = SqlDb();
    await _db.cleanTable(table);
    print('the table is clean');
  }

  void getData(table) async {
    final db = SqlDb();
    final datas = await db.getData(table);
    for (final data in datas) {
      print('reference : ${data['reference']}, nom_produit : ${data['nom_produit']}, categorie : ${data['categorie']}');
      print('prixUnitaire : ${data['prix_unitaire']}, date : ${data['date']}, quantité : ${data['quantité']}, total : ${data['total']} ');
    }
  }

//to get the information about the stock from the table
  Future<void> getDataFromTable(table, reference) async {
    final _db = SqlDb();
    List<Map<String, dynamic>> rows = await _db.getReference(table, reference);
    dataList.clear();
    if (rows.isNotEmpty) {
      Map<String, dynamic> rowData = rows.first;
      List<String> columnNames = [
        'reference',
        'nom_produit',
        'categorie',
        'prix_unitaire',
      ];

      for (String columnName in columnNames) {
        dynamic columnValue = rowData[columnName];
        dataList.add(columnValue.toString());
      }

      for (int i = 0; i < dataList.length; i++) {
        textControllers[i].text = dataList[i];
      }

      print(dataList);
    } else {
      // No rows found with the given reference
    }
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
      getDataFromTable('marchandise', scanResult);
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
      getDataFromTable('marchandise', qrResult);
    }
  }
}
