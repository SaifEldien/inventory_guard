import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../cubit/warehouse_cubit.dart';
import '../cubit/warehouse_state.dart';
import '../../domain/entities/warehouse.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class WarehouseListScreen extends StatelessWidget {
  const WarehouseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<WarehouseCubit, WarehouseState>(
        builder: (context, state) {
          if (state is WarehouseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WarehouseLoaded) {
            if (state.warehouses.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.warehouse_outlined,
                title: 'No warehouses registered',
                subtitle: 'Your warehouse network is empty.\nAdd your first warehouse to get started.',
              );
            }
            return _buildContent(context, state.warehouses);
          }

          return const EmptyStateWidget(
            icon: Icons.warehouse_outlined,
            title: 'No warehouses found',
            subtitle: 'Your warehouse network is empty.\nAdd your first warehouse to get started.',
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWarehouseDialog(context),
        label: const Text('Add Warehouse', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Warehouse> warehouses) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Warehouses & Locations',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisExtent: 320,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: warehouses.length,
              itemBuilder: (context, index) {
                final wh = warehouses[index];
                return _buildWarehouseCard(context, wh);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseCard(BuildContext context, Warehouse wh) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                if (wh.latitude != null && wh.longitude != null)
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(wh.latitude!, wh.longitude!),
                      initialZoom: 13,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(wh.latitude!, wh.longitude!),
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on_rounded,
                              color: AppColors.error,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Container(
                    color: AppColors.background,
                    child: Center(
                      child: Icon(Icons.map_outlined, color: AppColors.textTertiary, size: 48),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: wh.isActive ? AppColors.success.withValues(alpha: 0.9) : AppColors.textTertiary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      wh.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wh.name,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        wh.location,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(context, wh),
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        tooltip: 'Delete Warehouse',
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _showAddWarehouseDialog(context, warehouse: wh),
                        child: const Text('Edit Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWarehouseDialog(BuildContext context, {Warehouse? warehouse}) {
    final cubit = context.read<WarehouseCubit>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: AddWarehouseDialog(warehouse: warehouse),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Warehouse warehouse) {
    final cubit = context.read<WarehouseCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Warehouse', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${warehouse.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.deleteWarehouse(warehouse.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${warehouse.name} deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AddWarehouseDialog extends StatefulWidget {
  final Warehouse? warehouse;
  const AddWarehouseDialog({super.key, this.warehouse});

  @override
  State<AddWarehouseDialog> createState() => _AddWarehouseDialogState();
}

class _AddWarehouseDialogState extends State<AddWarehouseDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.warehouse?.name);
    _locationController = TextEditingController(text: widget.warehouse?.location);
    if (widget.warehouse?.latitude != null && widget.warehouse?.longitude != null) {
      _selectedLocation = LatLng(widget.warehouse!.latitude!, widget.warehouse!.longitude!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.warehouse != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Warehouse' : 'Add New Warehouse', 
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold)
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Warehouse Name',
                  hintText: 'e.g. North Logistics Center',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'City / Address',
                  hintText: 'e.g. Chicago, IL',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pinpoint Location on Map',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation ?? const LatLng(20, 0),
                        initialZoom: _selectedLocation != null ? 12 : 2,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                        onTap: (tapPosition, point) {
                          setState(() {
                            _selectedLocation = point;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        if (_selectedLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation!,
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.accent,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'zoom_in',
                            onPressed: () {
                              final currentZoom = _mapController.camera.zoom;
                              _mapController.move(_mapController.camera.center, currentZoom + 1);
                            },
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.add, color: AppColors.primary),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: 'zoom_out',
                            onPressed: () {
                              final currentZoom = _mapController.camera.zoom;
                              _mapController.move(_mapController.camera.center, currentZoom - 1);
                            },
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.remove, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Selected: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: AppColors.accent),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && _locationController.text.isNotEmpty) {
              final warehouse = Warehouse(
                id: isEditing ? widget.warehouse!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                location: _locationController.text,
                latitude: _selectedLocation?.latitude,
                longitude: _selectedLocation?.longitude,
                isActive: widget.warehouse?.isActive ?? true,
              );
              
              if (isEditing) {
                context.read<WarehouseCubit>().updateWarehouse(warehouse);
              } else {
                context.read<WarehouseCubit>().addWarehouse(warehouse);
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${warehouse.name} ${isEditing ? 'updated' : 'added'} successfully')),
              );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Update Warehouse' : 'Save Warehouse'),
        ),
      ],
    );
  }
}
