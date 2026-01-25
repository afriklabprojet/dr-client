import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/prescriptions_provider.dart';
import 'prescription_details_page.dart';
import '../../../../config/theme/app_colors.dart';

class PrescriptionsListPage extends ConsumerStatefulWidget {
  const PrescriptionsListPage({super.key});

  @override
  ConsumerState<PrescriptionsListPage> createState() => _PrescriptionsListPageState();
}

class _PrescriptionsListPageState extends ConsumerState<PrescriptionsListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(prescriptionsProvider.notifier).loadPrescriptions());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prescriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ordonnances'),
      ),
      body: Builder(
        builder: (context) {
          if (state.status.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(state.errorMessage!, textAlign: TextAlign.center),
                   ElevatedButton(
                     onPressed: () => ref.read(prescriptionsProvider.notifier).loadPrescriptions(),
                     child: const Text('Réessayer'),
                   )
                ],
              ),
            );
          }

          if (state.prescriptions.isEmpty) {
            return const Center(child: Text("Aucune ordonnance"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = state.prescriptions[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(prescription.status).withOpacity(0.1),
                    child: Icon(Icons.description, color: _getStatusColor(prescription.status)),
                  ),
                  title: Text('Ordonnance #${prescription.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(prescription.createdAt)}'),
                      _getStatusChip(prescription.status),
                      if (prescription.status == 'quoted' && prescription.quoteAmount != null)
                        Text(
                          'Devis Reçu: ${NumberFormat.currency(symbol: 'FCFA', decimalDigits: 0).format(prescription.quoteAmount)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrescriptionDetailsPage(prescriptionId: prescription.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to upload page (assuming it is available via routing or direct import)
          // For now let's just use the router or assume standard nav
          // Navigator.pushNamed(context, '/prescriptions/upload'); 
          // Or direct:
           Navigator.pushNamed(context, '/upload-prescription'); // Needs valid route
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'quoted': return Colors.blue;
      case 'validated': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _getStatusChip(String status) {
    String label;
    switch (status) {
       case 'pending': label = 'En attente'; break;
       case 'quoted': label = 'Devis Reçu'; break;
       case 'validated': label = 'Validée'; break;
       case 'rejected': label = 'Refusée'; break;
       default: label = status;
    }
    return Text(label, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold));
  }
}
