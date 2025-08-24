import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../shared/models/client.dart';

// Abstract data source for client operations
abstract class ClientDataSource {
  Future<void> addClient(Client client);
  Future<void> updateClient(Client client);
  Future<void> deleteClient(String clientId);
  Future<List<Client>> getAllClients();
}

// Firebase implementation of the client data source
class FirebaseClientDataSource implements ClientDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addClient(Client client) async {
    // Store client data in Firestore 'clients' collection
    final clientData = client.toMap();
    // Ensure createdAt is set if not already provided
    if (clientData['createdAt'] == null) {
      clientData['createdAt'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('clients')
        .doc(client.phoneNumber)
        .set(clientData);
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

  @override
  Future<List<Client>> getAllClients() async {
    // Retrieve all clients from Firestore

    final snapshot = await _firestore.collection('clients').get();
    return snapshot.docs
        .map((doc) => Client.fromMap(doc.id, doc.data()))
        .toList();
  }
}
