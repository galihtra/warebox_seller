import 'package:flutter/material.dart';
import 'package:warebox_seller/pages/warehouse/warehouse_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warebox_seller/pages/warehouse/edit_warehouse_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DetailWarehousePage extends StatefulWidget {
  final String warehouseId;
  // Parameter harus dideklarasikan di sini.

  // Ini adalah konstruktor untuk StatefulWidget.
  const DetailWarehousePage({Key? key, required this.warehouseId})
      : super(key: key);

  @override
  State<DetailWarehousePage> createState() => _DetailWarehousePageState();
}

class _DetailWarehousePageState extends State<DetailWarehousePage> {
  Warehouse? warehouse;

  @override
  void initState() {
    super.initState();
    _loadWarehouseData();
  }

  void _deleteWarehouse(BuildContext context) async {
    // Show confirmation dialog before deleting
    bool confirmDelete = await _showDeleteConfirmationDialog(context);
    if (confirmDelete) {
      // Proceed with deletion
      await FirebaseFirestore.instance
          .collection('warehouses')
          .doc(widget.warehouseId)
          .delete();

      // After deletion, pop out of the details page
      Navigator.of(context).pop(true); // true indicates something was deleted
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Delete'),
              content: Text('Are you sure you want to delete this warehouse?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Do not delete
                  },
                ),
                TextButton(
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Proceed with deletion
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  void _loadWarehouseData() async {
    DocumentSnapshot warehouseSnapshot = await FirebaseFirestore.instance
        .collection('warehouses')
        .doc(widget.warehouseId)
        .get();

    // Only update the state if the widget is still mounted
    if (mounted) {
      setState(() {
        warehouse = Warehouse.fromSnapshot(warehouseSnapshot);
      });
    }
  }

  void _navigateAndEditWarehouse(BuildContext context) async {
    if (warehouse != null) {
      // Check if warehouse is not null
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditWarehousePage(
              warehouse: warehouse!), // Pass the non-null warehouse
        ),
      );

      if (result == true) {
        _loadWarehouseData(); // Reload the data after editing
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if warehouse is loaded
    if (warehouse == null) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator()), // Show a loading indicator
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Details',
            textAlign: TextAlign.start,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          actions: <Widget>[
            // Icon Button Untuk Edit Warehouse
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () {
                _navigateAndEditWarehouse(context);
              },
            ),
            // Icon Button untuk Hapus Warehouse
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _deleteWarehouse(context);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('ID: ${warehouse!.id}', style: TextStyle(fontSize: 24)),
              SizedBox(height: 8),
              Text('Name: ${warehouse!.itemName}',
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 8),
              Text('Category: ${warehouse!.category}',
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 16),
              warehouse!.warehouseImageUrl != null
                  ? Image.network(warehouse!.warehouseImageUrl!)
                  : Container(
                      height: 200,
                      child: Center(child: Text('No image available')),
                    ),
              SizedBox(height: 16),
              warehouse!.detailImageUrls != null &&
                      warehouse!.detailImageUrls!.isNotEmpty
                  ? CarouselSlider(
                      options: CarouselOptions(
                        aspectRatio: 16 / 9,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                        autoPlay: true,
                      ),
                      items: warehouse!.detailImageUrls!.map((imageUrl) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    )
                  : Container(
                      height: 200,
                      child: Center(child: Text('No images available')),
                    ),
              // Tambahkan elemen UI lain sesuai kebutuhan
            ],
          ),
        ),
      );
    }
  }
}
