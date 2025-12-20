/// Breeds Settings Screen
/// 
/// CRUD screen for managing breeds (ras ternak).

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/breed.dart';
import '../../../providers/breed_provider.dart';

class BreedsSettingsScreen extends ConsumerWidget {
  const BreedsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breedsAsync = ref.watch(breedNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Ras'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: breedsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (breeds) {
          if (breeds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada ras',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(context, ref, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Ras'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: breeds.length,
            itemBuilder: (context, index) {
              final breed = breeds[index];
              return _BreedTile(
                breed: breed,
                onEdit: () => _showAddEditDialog(context, ref, breed),
                onDelete: () => _confirmDelete(context, ref, breed),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, WidgetRef ref, Breed? breed) {
    final codeController = TextEditingController(text: breed?.code ?? '');
    final nameController = TextEditingController(text: breed?.name ?? '');
    final isEditing = breed != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Ras' : 'Tambah Ras'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Kode *',
                hintText: 'NZW, REX, etc.',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama *',
                hintText: 'New Zealand White',
                prefixIcon: Icon(Icons.pets),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim();
              final name = nameController.text.trim();
              
              if (code.isEmpty || name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kode dan Nama wajib diisi')),
                );
                return;
              }

              Navigator.pop(context);

              try {
                if (isEditing) {
                  // TODO: Implement update when needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit belum diimplementasi')),
                  );
                } else {
                  await ref.read(breedNotifierProvider.notifier).create(
                    code: code,
                    name: name,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ras $code berhasil ditambahkan')),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Breed breed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Ras?'),
        content: Text('Ras "${breed.name}" akan dihapus. Aksi ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(breedNotifierProvider.notifier).delete(breed.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ras ${breed.code} dihapus')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _BreedTile extends StatelessWidget {
  final Breed breed;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BreedTile({
    required this.breed,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(breed.code.substring(0, breed.code.length.clamp(0, 2))),
      ),
      title: Text(breed.code),
      subtitle: Text(breed.name),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Hapus')),
        ],
      ),
    );
  }
}
