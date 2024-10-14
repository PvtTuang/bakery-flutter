import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Products'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No products found.'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var productData = products[index];
              return ListTile(
                title: Text(productData['name']),
                subtitle: Text('Price: \$${productData['price']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditSpecificProductScreen(productId: productData.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _firestore.collection('products').doc(productData.id).delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditSpecificProductScreen extends StatefulWidget {
  final String productId;

  EditSpecificProductScreen({required this.productId});

  @override
  _EditSpecificProductScreenState createState() => _EditSpecificProductScreenState();
}

class _EditSpecificProductScreenState extends State<EditSpecificProductScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _linkController = TextEditingController(); // เพิ่มตัวควบคุมสำหรับลิงค์

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    DocumentSnapshot productSnapshot = await _firestore.collection('products').doc(widget.productId).get();
    _nameController.text = productSnapshot['name'];
    _priceController.text = productSnapshot['price'].toString();
    _linkController.text = productSnapshot['link'] ?? ''; // โหลดลิงค์จาก Firestore
  }

  Future<void> _updateProduct() async {
    String name = _nameController.text;
    double price = double.tryParse(_priceController.text) ?? 0.0;
    String link = _linkController.text; // รับลิงค์จาก TextField

    await _firestore.collection('products').doc(widget.productId).update({
      'name': name,
      'price': price,
      'link': link, // อัปเดตลิงค์ใน Firestore
    });

    Navigator.pop(context); // กลับไปที่หน้าจอก่อนหน้านี้
  }

  Future<void> _deleteProduct() async {
    await _firestore.collection('products').doc(widget.productId).delete();
    Navigator.pop(context); // กลับไปที่หน้าจอก่อนหน้านี้
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _linkController, // เพิ่ม TextField สำหรับลิงค์
              decoration: InputDecoration(labelText: 'Product Link'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProduct,
              child: Text('Update Product'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteProduct,
              child: Text('Delete Product'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
