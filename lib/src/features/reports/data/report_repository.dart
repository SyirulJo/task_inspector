import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/report.dart';

List<Report> _mockReports = [];

class ReportRepository {
  Future<void> submitReport(Report report) async {
    _mockReports.add(report);
  }

  Future<List<Report>> getAllReports() async {
    return _mockReports;
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository();
});

final reportsListProvider = FutureProvider<List<Report>>((ref) async {
  return ref.watch(reportRepositoryProvider).getAllReports();
});
