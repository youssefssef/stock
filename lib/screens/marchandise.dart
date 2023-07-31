// ignore_for_file: unused_local_variable, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:stock/dataBase/sql.dart';
import 'package:path/path.dart' as path;

class MarchandisePage extends StatefulWidget {
  const MarchandisePage({super.key});

  @override
  State<MarchandisePage> createState() => _MarchandisePageState();
}

class _MarchandisePageState extends State<MarchandisePage> {
  List<String> marchandiseDetail = ['Référence', 'Nom du Produit', 'Catégorie', "Seuil d'alert", "Stock initial", "Prix Unitaire"];

  final TextEditingController totalController = TextEditingController();

  List<TextEditingController> textControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  // to save data into the table for each marchandise
  Future<void> insertMarchandise(String reference, String nomProduit, String categorie, double seuilAlert, double stockInitial,
      double prixUnitaire, double total) async {
    final sqlDb = SqlDb();
    await sqlDb.insertMarchandise(reference, nomProduit, categorie, seuilAlert, stockInitial, prixUnitaire, total);

    getData('marchandise');
    await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        barrierDismissible: true,
        title: 'success...',
        text: "la marchandise est enregistrée avec succès",
        confirmBtnText: 'nouvelle',
        cancelBtnText: "page d'accueil",
        showCancelBtn: true,
        onConfirmBtnTap: () {
          for (int i = 0; i < marchandiseDetail.length; i++) {
            textControllers[i].clear();
          }
          totalController.clear();
          Navigator.of(context).pop();
        },
        onCancelBtnTap: () {
          for (int i = 0; i < marchandiseDetail.length; i++) {
            textControllers[i].clear();
          }
          totalController.clear();
        });
  }

  @override
  Widget build(BuildContext context) {
    List<GlobalKey<FormState>> _formKeys = List.generate(
      marchandiseDetail.length,
      (index) => GlobalKey<FormState>(),
    );

    //to calculate the total
    void calculateTotal() {
      double prixUnitaire = double.tryParse(textControllers[4].text) ?? 0.0;
      double stockInitial = double.tryParse(textControllers[5].text) ?? 0.0;
      double total = prixUnitaire * stockInitial;

      // Update the Total field's controller with the calculated value
      totalController.text = total.toStringAsFixed(2); // Adjust the number of decimal places as needed
    }

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
        title: const Text('Nouvelle Marchandise', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () {
                printExcelSheetData();
              },
              icon: const Icon(
                Icons.file_open,
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
                'Veuillez saisir les informations de chaque marchandise ou importer un fichier Excel : ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 101, 100, 100)),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: marchandiseDetail.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 15),
                    child: Text(
                      '${marchandiseDetail[index]} :',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width / 1.1,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 226, 225, 225),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Form(
                        key: _formKeys[index],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: TextFormField(
                            controller: textControllers[index],
                            validator: (value) => value!.isEmpty ? 'ce champ ne devrait pas être vide' : null,
                            onChanged: (value) {
                              if (index == 5 || index == 4) {
                                calculateTotal();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: marchandiseDetail[index],
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
                    color: const Color.fromARGB(255, 226, 225, 225),
                    borderRadius: BorderRadius.circular(10),
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
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.3, vertical: 10),
            child: InkWell(
              onTap: () async {
                for (int i = 0; i < marchandiseDetail.length; i++) {
                  if (_formKeys[i].currentState!.validate()) {
                    String reference = textControllers[0].text;
                    String nomProduit = textControllers[1].text;
                    String categorie = textControllers[2].text;
                    double seuilAlert = double.tryParse(textControllers[3].text) ?? 0.0;
                    double stockInitial = double.tryParse(textControllers[4].text) ?? 0.0;
                    double prixUnitaire = double.tryParse(textControllers[5].text) ?? 0.0;
                    double total = double.tryParse(totalController.text) ?? 0.0;

                    await insertMarchandise(
                      reference,
                      nomProduit,
                      categorie,
                      seuilAlert,
                      stockInitial,
                      prixUnitaire,
                      total,
                    );
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
    );
  }

  void getData(table) async {
    final db = SqlDb();
    final datas = await db.getData(table);
    for (final data in datas) {
      print('reference : ${data['reference']}, nom_produit : ${data['nom_produit']}, categorie : ${data['categorie']}');
      print(
          'seuil_alerte : ${data['seuil_alerte']}, stock_initial : ${data['stock_initial']}, prix_unitaire : ${data['prix_unitaire']}, total : ${data['total']} ');
    }
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
        var seuilAlerteIndex = 3;
        var stockInitialIndex = 4;
        var prixUnitaireIndex = 5;
        var totalIndex = 6;

        //clean('stock');

        // Iterate through each row and retrieve the data values
        for (var rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
          var row = sheet.rows[rowIndex];

          // Extract the data for each column
          var reference = row[referenceIndex]?.value?.toString() ?? '';
          var nomProduit = row[nomProduitIndex]?.value?.toString() ?? '';
          var categorie = row[categorieIndex]?.value?.toString() ?? '';
          var seuilAlerte = row[seuilAlerteIndex]?.value as double;
          var stockInitial = row[stockInitialIndex]?.value as double;
          var prixUnitaire = row[prixUnitaireIndex]?.value as double;
          var total = row[totalIndex]?.value as double;

          // Save the data in the SQLite table
          await insertMarchandise(reference, nomProduit, categorie, seuilAlerte, stockInitial, prixUnitaire, total);
        }
      } else {
        print('Sheet "$sheetName" not found.');
      }
    } else {
      print('No file selected.');
    }
  }
}
