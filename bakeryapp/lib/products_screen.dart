import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found.'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var productData = products[index];
              return ListTile(
                title: Text(productData['name'] ?? 'Unnamed Product'),
                subtitle: Text('Price: \$${productData['price']?.toString() ?? '0.0'}'),
                leading: productData['imageUrl'] != null
                    ? Image.network(productData['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : SizedBox(width: 50, height: 50), // Placeholder if there's no image
                onTap: () {
                  // คุณสามารถเพิ่มฟังก์ชันในการจัดการเมื่อคลิกที่รายการสินค้าได้ที่นี่
                },
              );
            },
          );
        },
      ),
    );
  }
}
