/// Finance Categories Settings Screen
/// 
/// CRUD screen for managing finance categories.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/finance.dart';
import '../../../providers/finance_provider.dart';

class FinanceCategoriesSettingsScreen extends ConsumerWidget {
  const FinanceCategoriesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(financeCategoriesNotifierProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kategori Keuangan'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pemasukan', icon: Icon(Icons.arrow_upward)),
              Tab(text: 'Pengeluaran', icon: Icon(Icons.arrow_downward)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context, ref),
          child: const Icon(Icons.add),
        ),
        body: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (categories) {
            final incomeCategories = categories
                .where((c) => c.type == TransactionType.income)
                .toList();
            final expenseCategories = categories
                .where((c) => c.type == TransactionType.expense)
                .toList();

            return TabBarView(
              children: [
                _CategoryList(
                  categories: incomeCategories,
                  emptyMessage: 'Belum ada kategori pemasukan',
                  onDelete: (c) => _confirmDelete(context, ref, c),
                ),
                _CategoryList(
                  categories: expenseCategories,
                  emptyMessage: 'Belum ada kategori pengeluaran',
                  onDelete: (c) => _confirmDelete(context, ref, c),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    TransactionType selectedType = TransactionType.income;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori *',
                  hintText: 'Penjualan, Pakan, dll',
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Jenis',
                  prefixIcon: Icon(Icons.swap_vert),
                ),
                items: TransactionType.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.displayName),
                )).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedType = value);
                },
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
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama wajib diisi')),
                  );
                  return;
                }

                Navigator.pop(context);

                try {
                  await ref.read(financeCategoriesNotifierProvider.notifier).create(
                    name: name,
                    type: selectedType,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kategori "$name" berhasil ditambahkan')),
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
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, FinanceCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text('Kategori "${category.name}" akan dihapus. Transaksi yang menggunakan kategori ini mungkin terpengaruh.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(financeCategoriesNotifierProvider.notifier).delete(category.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kategori "${category.name}" dihapus')),
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

class _CategoryList extends StatelessWidget {
  final List<FinanceCategory> categories;
  final String emptyMessage;
  final void Function(FinanceCategory) onDelete;

  const _CategoryList({
    required this.categories,
    required this.emptyMessage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: category.type == TransactionType.income
                ? Colors.green[100]
                : Colors.red[100],
            child: Icon(
              category.type == TransactionType.income
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: category.type == TransactionType.income
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          title: Text(category.name),
          subtitle: Text(category.type.displayName),
          trailing: category.isSystem
              ? const Chip(label: Text('System', style: TextStyle(fontSize: 10)))
              : IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => onDelete(category),
                ),
        );
      },
    );
  }
}
