// lib/features/focus_pomodoro/presentation/pages/forest_view_page.dart

import 'package:flutter/material.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';

class ForestViewPage extends StatefulWidget {
  const ForestViewPage({super.key});

  @override
  State<ForestViewPage> createState() => _ForestViewPageState();
}

class _ForestViewPageState extends State<ForestViewPage> {
  String _selectedFilter = 'Día'; // 'Día', 'Semana', 'Mes'

  // Datos simulados de los árboles recuperados de la base local (PlantTree)
  final List<PlantTree> _trees = [
    PlantTree()
      ..uuid = 'tree_1'
      ..species = 'Roble Nobilis'
      ..status = TreeStatus.completed
      ..plantedAt = DateTime.now().subtract(const Duration(hours: 3))
      ..growthDurationMinutes = 25,
    PlantTree()
      ..uuid = 'tree_2'
      ..species = 'Pino Silvestre'
      ..status = TreeStatus.completed
      ..plantedAt = DateTime.now().subtract(const Duration(hours: 1))
      ..growthDurationMinutes = 50,
    PlantTree()
      ..uuid = 'tree_3'
      ..species = 'Bonsai Zen'
      ..status = TreeStatus.withered // Árbol marchito por abandonar la sesión
      ..plantedAt = DateTime.now().subtract(const Duration(minutes: 30))
      ..growthDurationMinutes = 10,
    PlantTree()
      ..uuid = 'tree_4'
      ..species = 'Roble Nobilis'
      ..status = TreeStatus.completed
      ..plantedAt = DateTime.now(),
  ];

  int get _completedTreesCount =>
      _trees.where((t) => t.status == TreeStatus.completed).length;

  int get _totalFocusMinutes => _trees
      .where((t) => t.status == TreeStatus.completed)
      .fold(0, (sum, t) => sum + t.growthDurationMinutes);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Bosque Virtual'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showForestSummaryDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Selector de Período y Métricas Rápidas
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Día', label: Text('Día')),
                    ButtonSegment(value: 'Semana', label: Text('Semana')),
                    ButtonSegment(value: 'Mes', label: Text('Mes')),
                  ],
                  selected: {_selectedFilter},
                  onSelectionChanged: (newSelection) {
                    setState(() => _selectedFilter = newSelection.first);
                  },
                ),
                Chip(
                  avatar: const Icon(Icons.park, color: Colors.green, size: 18),
                  label: Text('$_completedTreesCount Árboles'),
                  backgroundColor: Colors.green.shade50,
                ),
              ],
            ),
          ),
          const Divider(),

          // 2. Grilla Interactiva del Bosque
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100.withAlpha(100),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.green.shade300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 12, // Parcela de 12 espacios para el bosque
                  itemBuilder: (context, index) {
                    if (index < _trees.length) {
                      final tree = _trees[index];
                      return _buildTreePlot(context, tree);
                    }
                    // Terreno vacío para sembrar próximos árboles
                    return _buildEmptyPlot();
                  },
                ),
              ),
            ),
          ),

          // 3. Barra Inferior de Métricas de Tiempo Concentrado
          Container(
            padding: const EdgeInsets.all(20),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                    'Tiempo Enfoque', '$_totalFocusMinutes min', Icons.timer),
                _buildStatColumn(
                    'Efectividad',
                    '${((_completedTreesCount / _trees.length) * 100).toStringAsFixed(0)}%',
                    Icons.show_chart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreePlot(BuildContext context, PlantTree tree) {
    final bool isCompleted = tree.status == TreeStatus.completed;

    return InkWell(
      onTap: () => _showTreeDetailModal(context, tree),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.shade50 : Colors.brown.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? Colors.green.shade400 : Colors.brown.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.park : Icons.nature_outlined,
              size: 40,
              color:
                  isCompleted ? Colors.green.shade700 : Colors.brown.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              tree.species,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color:
                    isCompleted ? Colors.green.shade900 : Colors.brown.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlot() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade200,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.add_circle_outline,
          color: Colors.green.shade300,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.teal),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showTreeDetailModal(BuildContext context, PlantTree tree) {
    final isCompleted = tree.status == TreeStatus.completed;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.park : Icons.nature_outlined,
                  color: isCompleted ? Colors.green : Colors.brown,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  tree.species,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Duración del Enfoque'),
              subtitle: Text('${tree.growthDurationMinutes} minutos'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha de Siembra'),
              subtitle: Text(
                  '${tree.plantedAt.day}/${tree.plantedAt.month}/${tree.plantedAt.year}'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isCompleted
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
                color: isCompleted ? Colors.green : Colors.red,
              ),
              title: const Text('Estado'),
              subtitle: Text(
                isCompleted
                    ? 'Árbol sano y crecido completamente.'
                    : 'Árbol marchitado por interrupción/abandono de la sesión.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForestSummaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gamificación Estilo Forest'),
        content: const Text(
          'Cada sesión Pomodoro completada con éxito planta un árbol en tu bosque local. '
          'Si abandonas la sesión antes de tiempo, el árbol se marchitará como recordatorio de tu higiene cognitiva.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
