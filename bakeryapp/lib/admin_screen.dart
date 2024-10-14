import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product_screen.dart'; // เพิ่มการนำเข้า AddProductScreen
import 'edit_product_screen.dart'; // เพิ่มการนำเข้า EditProductScreen

class AdminScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          ElevatedButton(
            child: Text('Add Product'), // ข้อความที่จะแสดงบนปุ่ม
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductScreen()), // นำทางไปยังหน้าจอเพิ่มผลิตภัณฑ์
              );
            },
          ),
          ElevatedButton(
            child: Text('Edit Products'), // ปุ่มสำหรับไปยังหน้าแก้ไขสินค้า
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProductScreen()), // นำทางไปยังหน้าจอแก้ไขผลิตภัณฑ์
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userData = users[index];
              return ListTile(
                title: Text(userData['email']),
                subtitle: Text('Role: ${userData['role']}'),
              );
            },
          );
        },
      ),
    );
  }
}
