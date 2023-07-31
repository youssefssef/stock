import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;
  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  Future<Database> initialDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'local.db');
    Database mydb = await openDatabase(path, version: 6, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return mydb;
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) {
    print("onUpgrade=========================");
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
    CREATE TABLE "stock" (
      "categorie" TEXT,
      "reference" TEXT,
      "nom_produit" TEXT,
      "prix_vente_ht" REAL,
      "cout_revient_production" REAL,
      "marge" REAL,
      "taux_merge" TEXT
    )
     ''');
    await db.execute(''' 
    CREATE TABLE "marchandise" (
      "reference" TEXT,
      "nom_produit" TEXT,
      "categorie" TEXT,
      "seuil_alerte" REAL,
      "stock_initial" REAL,
      "prix_unitaire" REAL,
      "total" REAL
    )
     ''');
    await db.execute(''' 
    CREATE TABLE "entree" (
      "reference" TEXT,
      "nom_produit" TEXT,
      "categorie" TEXT,
      "prix_unitaire" REAL,
      "date" TEXT,
      "quantité" REAL,
      "total" REAL
    )
     ''');
    await db.execute(''' 
    CREATE TABLE "sortie" (
      "reference" TEXT,
      "nom_produit" TEXT,
      "categorie" TEXT,
      "prix_unitaire" REAL,
      "date" TEXT,
      "quantité" REAL,
      "total" REAL
    )
     ''');

    print('database created successfully');
  }

//to  get data from table
  Future<List<Map<String, dynamic>>> getData(table) async {
    final db = await this.db;
    return db!.query(table);
  }

  //to clean the table
  Future<void> cleanTable(table) async {
    final db = await this.db;
    await db!.delete(table);
  }

  Future<List<Map<String, dynamic>>> getReference(String table, String reference) async {
    final db = await this.db;
    return db!.query(table, where: 'reference = ?', whereArgs: [reference]);
  }

  Future<void> insertProduit(String categorie, String reference, String nomProduit, double prixVenteHt, double coutRevientProduction,
      double marge, String tauxMarge) async {
    final db = await this.db;
    await db!.insert('stock', {
      'categorie': categorie,
      'reference': reference,
      'nom_produit': nomProduit,
      'prix_vente_ht': prixVenteHt,
      'cout_revient_production': coutRevientProduction,
      'marge': marge,
      'taux_merge': tauxMarge
    });
  }

  Future<void> insertMarchandise(String reference, String nomProduit, String categorie, double seuilAlert, double stockInitial,
      double prixUnitaire, double total) async {
    final db = await this.db;
    await db!.insert('marchandise', {
      'reference': reference,
      'nom_produit': nomProduit,
      'categorie': categorie,
      'seuil_alerte': seuilAlert,
      'stock_initial': stockInitial,
      'prix_unitaire': prixUnitaire,
      'total': total
    });
  }

  Future<void> insertEntree(
      String reference, String nomProduit, String categorie, double prix_unitaire, String date, double quantite, double total) async {
    final db = await this.db;
    await db!.insert('entree', {
      'reference': reference,
      'nom_produit': nomProduit,
      'categorie': categorie,
      'prix_unitaire': prix_unitaire,
      'date': date,
      'quantité': quantite,
      'total': total
    });
  }

  Future<void> insertSortie(
      String reference, String nomProduit, String categorie, double prix_unitaire, String date, double quantite, double total) async {
    final db = await this.db;
    await db!.insert('entree', {
      'reference': reference,
      'nom_produit': nomProduit,
      'categorie': categorie,
      'prix_unitaire': prix_unitaire,
      'date': date,
      'quantité': quantite,
      'total': total
    });
  }

  Future<bool> isTableEmpty(table) async {
    final db = await this.db;
    final result = await db!.rawQuery('SELECT COUNT(*) FROM $table');
    final count = Sqflite.firstIntValue(result);
    return count == 0;
  }
}
