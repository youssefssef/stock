// ignore_for_file: prefer_const_constructors, must_be_immutable, sized_box_for_whitespace, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:stock/dataBase/sql.dart';

class ProduitDetails extends StatefulWidget {
  final String reference;
  const ProduitDetails({required this.reference, Key? key}) : super(key: key);

  @override
  State<ProduitDetails> createState() => _ProduitDetailsState();
}

class _ProduitDetailsState extends State<ProduitDetails> {
  List<String> titles = ['Categorie', 'Réference', 'Nom du produit', "Prix vente Ht", 'Cout revient production', 'Marge', 'Taux Merge'];
  List<dynamic> dataList = [];
  bool loading = true;

  @override
  void initState() {
    getDataFromTable('stock', widget.reference);
    super.initState();
  }

  // to get that of the specify reference
  Future<void> getDataFromTable(table, reference) async {
    final _db = SqlDb();
    List<Map<String, dynamic>> rows = await _db.getReference(table, reference);
    dataList.clear();
    if (rows.isNotEmpty) {
      Map<String, dynamic> rowData = rows.first;
      List<String> columnNames = [
        'categorie',
        'reference',
        'nom_produit',
        'prix_vente_ht',
        'cout_revient_production',
        'marge',
        'taux_merge'
      ];

      for (String columnName in columnNames) {
        dynamic columnValue = rowData[columnName];
        dataList.add(columnValue);
      }
      setState(() {
        loading = false;
      });
      print(dataList);
    } else {
      // No rows found with the given reference
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 243, 243),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 47, 213),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        )),
        toolbarHeight: 65,
        centerTitle: true,
        title: const Text("gestion d'inventaire", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
          itemCount: titles.length,
          itemBuilder: (context, index) {
            String textValue = loading ? '' : (index < dataList.length ? '${dataList[index]}' : '');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0, top: 20),
                      child: Text(
                        '${titles[index]} :',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Visibility(
                        visible: loading,
                        child: SpinKitSquareCircle(
                          size: 20,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                  child: Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width / 1.1,
                    decoration:
                        BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: TextEditingController(text: textValue),
                        enabled: false,
                        style: TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}
