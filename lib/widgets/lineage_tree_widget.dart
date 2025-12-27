/// Lineage Tree Widget
/// 
/// Widget untuk menampilkan pohon silsilah (pedigree) ternak.
/// Menggunakan CustomPaint untuk menggambar tree.

library;

import 'package:flutter/material.dart';
import '../services/lineage_service.dart';

/// Widget untuk menampilkan lineage tree
class LineageTreeWidget extends StatelessWidget {
  final LineageNode rootNode;
  final VoidCallback? onNodeTap;

  const LineageTreeWidget({
    super.key,
    required this.rootNode,
    this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildTree(context, rootNode, 0),
        ),
      ),
    );
  }

  /// Build tree recursively
  Widget _buildTree(BuildContext context, LineageNode node, int generation) {
    final hasParents = node.dam != null || node.sire != null;

    if (!hasParents) {
      // Leaf node - no parents
      return _NodeCard(node: node, generation: generation);
    }

    // Node with parents
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Current node
        _NodeCard(node: node, generation: generation),
        
        // Connection line
        const SizedBox(width: 8),
        CustomPaint(
          size: const Size(40, 120),
          painter: _ConnectionPainter(),
        ),
        const SizedBox(width: 8),
        
        // Parents column
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sire (father) - top
            if (node.sire != null)
              _buildTree(context, node.sire!, generation + 1)
            else
              _EmptyParentCard(label: 'Pejantan', generation: generation + 1),
            
            const SizedBox(height: 16),
            
            // Dam (mother) - bottom
            if (node.dam != null)
              _buildTree(context, node.dam!, generation + 1)
            else
              _EmptyParentCard(label: 'Induk', generation: generation + 1),
          ],
        ),
      ],
    );
  }
}

/// Card untuk menampilkan node
class _NodeCard extends StatelessWidget {
  final LineageNode node;
  final int generation;

  const _NodeCard({required this.node, required this.generation});

  @override
  Widget build(BuildContext context) {
    // Color berdasarkan gender
    final color = switch (node.gender) {
      'male' => Colors.blue,
      'female' => Colors.pink,
      _ => Colors.grey,
    };

    // Ukuran lebih kecil untuk generasi lebih tinggi
    final scale = 1.0 - (generation * 0.1).clamp(0.0, 0.3);
    final width = 140.0 * scale;

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gender icon
          Text(
            node.genderIcon,
            style: TextStyle(fontSize: 24 * scale),
          ),
          const SizedBox(height: 4),
          
          // Code
          Text(
            node.code,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
              color: color.shade(700),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Name (if different from code)
          if (node.name != null && node.name != node.code)
            Text(
              node.name!,
              style: TextStyle(
                fontSize: 12 * scale,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          
          // Breed
          if (node.breed != null)
            Text(
              node.breed!,
              style: TextStyle(
                fontSize: 10 * scale,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          
          // Type badge
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: node.type == 'offspring' ? Colors.orange : Colors.teal,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              node.type == 'offspring' ? 'Anakan' : 'Indukan',
              style: TextStyle(
                fontSize: 9 * scale,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card kosong untuk parent yang tidak diketahui
class _EmptyParentCard extends StatelessWidget {
  final String label;
  final int generation;

  const _EmptyParentCard({required this.label, required this.generation});

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 - (generation * 0.1).clamp(0.0, 0.3);
    final width = 140.0 * scale;

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_outline, size: 24 * scale, color: Colors.grey[400]),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * scale,
              color: Colors.grey[500],
            ),
          ),
          Text(
            'Tidak diketahui',
            style: TextStyle(
              fontSize: 10 * scale,
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter untuk menggambar garis penghubung
class _ConnectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Horizontal line dari kiri ke tengah
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width / 2, size.height / 2);
    
    // Vertical line dari top ke bottom
    path.moveTo(size.width / 2, 20);
    path.lineTo(size.width / 2, size.height - 20);
    
    // Branch ke top (sire)
    path.moveTo(size.width / 2, 20);
    path.lineTo(size.width, 20);
    
    // Branch ke bottom (dam)
    path.moveTo(size.width / 2, size.height - 20);
    path.lineTo(size.width, size.height - 20);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Extension untuk Color shade (karena tidak ada di Flutter default)
extension ColorShade on Color {
  Color shade(int shade) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (1.0 - shade / 1000).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
