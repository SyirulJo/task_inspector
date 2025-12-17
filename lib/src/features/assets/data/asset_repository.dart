import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/asset.dart';

final _mockAssets = [
  Asset(
    id: 'asset_1',
    name: 'Generator A',
    location: 'Basement 1',
    description: 'Main backup generator',
    qrCode: 'asset_1_qr_code',
  ),
  Asset(
    id: 'asset_2',
    name: 'HVAC Unit 3',
    location: 'Roof Level',
    description: 'East wing cooling unit',
    qrCode: 'asset_2_qr_code',
  ),
  Asset(
    id: 'asset_3',
    name: 'Fire Pump',
    location: 'Pump Room',
    description: 'Sprinkler system main pump',
    qrCode: 'asset_3_qr_code',
  ),
];

class AssetRepository {
  Future<List<Asset>> getAllAssets() async {
    return _mockAssets;
  }

  Future<Asset?> getAssetById(String id) async {
    return _mockAssets.firstWhere((a) => a.id == id);
  }
}

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepository();
});

final assetsListProvider = FutureProvider<List<Asset>>((ref) async {
  return ref.watch(assetRepositoryProvider).getAllAssets();
});
