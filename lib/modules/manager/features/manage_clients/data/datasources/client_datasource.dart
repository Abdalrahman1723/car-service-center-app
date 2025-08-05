import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../../shared/models/client.dart';

// Abstract data source for client operations
abstract class ClientDataSource {
  Future<void> addClient(Client client);
  Future<void> updateClient(Client client);
  Future<void> deleteClient(String clientId);
}

// Firebase implementation of the client data source
class FirebaseClientDataSource implements ClientDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addClient(Client client) async {
    // Store client data in Firestore 'clients' collection
    await _firestore.collection('clients').doc(client.id).set(client.toMap());
  }

  @override
  Future<void> updateClient(Client client) async {
    // Update client data in Firestore
    await _firestore
        .collection('clients')
        .doc(client.id)
        .update(client.toMap());
  }

  @override
  Future<void> deleteClient(String clientId) async {
    // Delete client from Firestore
    await _firestore.collection('clients').doc(clientId).delete();
  }
}
