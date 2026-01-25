import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import '../../data/datasources/prescriptions_remote_datasource.dart';
import 'prescriptions_notifier.dart';
import 'prescriptions_state.dart';

// Prescriptions remote data source provider
final prescriptionsRemoteDataSourceProvider =
    Provider<PrescriptionsRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return PrescriptionsRemoteDataSourceImpl(apiClient);
    });

// Prescriptions provider
final prescriptionsProvider =
    StateNotifierProvider<PrescriptionsNotifier, PrescriptionsState>((ref) {
      final remoteDataSource = ref.watch(prescriptionsRemoteDataSourceProvider);
      return PrescriptionsNotifier(remoteDataSource);
    });
