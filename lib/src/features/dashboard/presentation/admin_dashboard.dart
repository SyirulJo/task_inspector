import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../authentication/data/auth_repository.dart';
import '../../assets/data/asset_repository.dart';
import '../../reports/data/report_repository.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetsListProvider);
    final reportsAsync = ref.watch(reportsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              context.push('/analytics');
            },
            tooltip: 'Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCards(context, assetsAsync, reportsAsync),
            const SizedBox(height: 24),
            Text(
              'Managed Assets',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildAssetsList(assetsAsync),
            const SizedBox(height: 24),
            Text(
              'Recent Reports',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildReportsList(reportsAsync),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create-task');
        },
        label: const Text('Assign Task'),
        icon: const Icon(Icons.add_task),
      ),
    );
  }

  Widget _buildStatCards(
    BuildContext context, 
    AsyncValue<List<dynamic>> assets, 
    AsyncValue<List<dynamic>> reports,
  ) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Total Assets', style: TextStyle(color: Colors.white70)),
                  Text(
                    assets.when(
                      data: (d) => d.length.toString(), 
                      error: (_,__) => '-', 
                      loading: () => '...'
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            color: Theme.of(context).colorScheme.secondary,
             child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Reports Today', style: TextStyle(color: Colors.white)),
                  Text(
                    reports.when(
                      data: (d) => d.length.toString(), 
                      error: (_,__) => '-', 
                      loading: () => '...'
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetsList(AsyncValue<dynamic> assetsAsync) {
    return assetsAsync.when(
      data: (assets) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: assets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final asset = assets[index];
          return ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
            title: Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(asset.location),
            trailing: IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () {
                showDialog(
                  context: context, 
                  builder: (_) => AlertDialog(
                    title: Text(asset.name),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_2, size: 200),
                        Text(asset.qrCode, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  )
                );
              },
            ),
          );
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildReportsList(AsyncValue<dynamic> reportsAsync) {
    return reportsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No reports submitted yet.'),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final report = reports[index];
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white),
              ),
              title: Text('Task Completed', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(report.submittedAt)),
            );
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
       error: (e, _) => Text('Error: $e'),
    );
  }
}
