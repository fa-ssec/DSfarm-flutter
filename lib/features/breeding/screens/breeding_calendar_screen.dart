/// Breeding Calendar Screen
/// 
/// Kalender visual untuk jadwal breeding.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../services/breeding_analytics_service.dart';
import '../../../providers/farm_provider.dart';

/// Provider untuk calendar events
final breedingCalendarEventsProvider = FutureProvider.family<List<BreedingEvent>, DateTime>((ref, month) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return [];
  
  final service = BreedingAnalyticsService(Supabase.instance.client);
  return service.getCalendarEvents(farm.id, month);
});

class BreedingCalendarScreen extends ConsumerStatefulWidget {
  const BreedingCalendarScreen({super.key});

  @override
  ConsumerState<BreedingCalendarScreen> createState() => _BreedingCalendarScreenState();
}

class _BreedingCalendarScreenState extends ConsumerState<BreedingCalendarScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(breedingCalendarEventsProvider(_currentMonth));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Breeding'),
      ),
      body: Column(
        children: [
          // Month Navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat('MMMM yyyy', 'id').format(_currentMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          
          // Legend
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: BreedingEventType.values.map((type) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(type.icon, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(type.label, style: const TextStyle(fontSize: 11)),
                ],
              )).toList(),
            ),
          ),
          
          const Divider(height: 1),
          
          // Calendar Grid
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (events) => _CalendarGrid(
                month: _currentMonth,
                events: events,
                selectedDate: _selectedDate,
                onDateTap: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
          ),
          
          // Events for selected date
          if (_selectedDate != null)
            eventsAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (events) {
                final dayEvents = events.where((e) =>
                    e.date.year == _selectedDate!.year &&
                    e.date.month == _selectedDate!.month &&
                    e.date.day == _selectedDate!.day).toList();
                
                if (dayEvents.isEmpty) return const SizedBox();
                
                return Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('d MMMM yyyy', 'id').format(_selectedDate!),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => setState(() => _selectedDate = null),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: dayEvents.length,
                          itemBuilder: (context, index) => _EventTile(event: dayEvents[index]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Calendar Grid
class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final List<BreedingEvent> events;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateTap;

  const _CalendarGrid({
    required this.month,
    required this.events,
    required this.selectedDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return Column(
      children: [
        // Weekday headers
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Row(
            children: [
              Expanded(child: Center(child: Text('Min', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
              Expanded(child: Center(child: Text('Sen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
              Expanded(child: Center(child: Text('Sel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
              Expanded(child: Center(child: Text('Rab', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
              Expanded(child: Center(child: Text('Kam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
              Expanded(child: Center(child: Text('Jum', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
              Expanded(child: Center(child: Text('Sab', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
            ],
          ),
        ),
        
        // Days grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 42, // 6 rows x 7 days
            itemBuilder: (context, index) {
              final dayOffset = index - startingWeekday;
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox();
              }
              
              final day = dayOffset + 1;
              final date = DateTime(month.year, month.month, day);
              final dayEvents = events.where((e) =>
                  e.date.year == date.year &&
                  e.date.month == date.month &&
                  e.date.day == date.day).toList();
              
              final isSelected = selectedDate != null &&
                  selectedDate!.year == date.year &&
                  selectedDate!.month == date.month &&
                  selectedDate!.day == date.day;
              
              final isToday = DateTime.now().year == date.year &&
                  DateTime.now().month == date.month &&
                  DateTime.now().day == date.day;
              
              return GestureDetector(
                onTap: () => onDateTap(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                        : null,
                    border: isToday 
                        ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (dayEvents.isNotEmpty)
                        Wrap(
                          spacing: 1,
                          children: dayEvents.take(3).map((e) => Text(
                            e.type.icon,
                            style: const TextStyle(fontSize: 8),
                          )).toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Event Tile
class _EventTile extends StatelessWidget {
  final BreedingEvent event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _getEventColor(event.type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getEventColor(event.type).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(event.type.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.type.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  event.title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(BreedingEventType type) {
    switch (type) {
      case BreedingEventType.mating:
        return Colors.red;
      case BreedingEventType.palpation:
        return Colors.amber;
      case BreedingEventType.expectedBirth:
        return Colors.orange;
      case BreedingEventType.birth:
        return Colors.green;
      case BreedingEventType.weaning:
        return Colors.blue;
    }
  }
}
