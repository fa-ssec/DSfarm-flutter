/// Reminder Repository
/// 
/// Handles database operations for reminders.

library;

import '../core/services/supabase_service.dart';
import '../models/reminder.dart';

class ReminderRepository {
  static const String _tableName = 'reminders';

  /// Get all reminders for a farm
  Future<List<Reminder>> getByFarm(String farmId) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select()
        .eq('farm_id', farmId)
        .order('due_date');

    return (response as List)
        .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get pending reminders (not completed)
  Future<List<Reminder>> getPending(String farmId) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select()
        .eq('farm_id', farmId)
        .eq('is_completed', false)
        .order('due_date');

    return (response as List)
        .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get overdue reminders
  Future<List<Reminder>> getOverdue(String farmId) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final response = await SupabaseService.client
        .from(_tableName)
        .select()
        .eq('farm_id', farmId)
        .eq('is_completed', false)
        .lt('due_date', today)
        .order('due_date');

    return (response as List)
        .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Create a new reminder
  Future<Reminder> create({
    required String farmId,
    required ReminderType type,
    required String title,
    String? description,
    required DateTime dueDate,
    String? referenceId,
    String? referenceType,
  }) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .insert({
          'farm_id': farmId,
          'type': type.value,
          'title': title,
          'description': description,
          'due_date': dueDate.toIso8601String().split('T').first,
          'reference_id': referenceId,
          'reference_type': referenceType,
          'is_completed': false,
        })
        .select()
        .single();

    return Reminder.fromJson(response);
  }

  /// Mark reminder as completed
  Future<void> markCompleted(String id) async {
    await SupabaseService.client
        .from(_tableName)
        .update({
          'is_completed': true,
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  /// Delete reminder
  Future<void> delete(String id) async {
    await SupabaseService.client
        .from(_tableName)
        .delete()
        .eq('id', id);
  }

  /// Create breeding-related reminders automatically
  /// Uses H-1 timing (reminder day before actual event)
  Future<void> createBreedingReminders({
    required String farmId,
    required String breedingRecordId,
    required String damName,
    required DateTime matingDate,
    required DateTime? expectedBirthDate,
    int palpationReminderDays = 11,  // H-1 for palpation at H+12
    int birthReminderDays = 30,      // H-1 for birth at H+31
  }) async {
    // Palpation reminder (H-1: day 11 for palpation on day 12)
    await create(
      farmId: farmId,
      type: ReminderType.palpation,
      title: 'Palpasi $damName',
      description: 'Besok: Cek kebuntingan $damName',
      dueDate: matingDate.add(Duration(days: palpationReminderDays)),
      referenceId: breedingRecordId,
      referenceType: 'breeding_record',
    );

    // Expected birth reminder (H-1: day 30 for birth on day 31)
    if (expectedBirthDate != null) {
      await create(
        farmId: farmId,
        type: ReminderType.expectedBirth,
        title: 'Perkiraan lahir $damName',
        description: 'Besok: Siapkan kandang kelahiran untuk $damName',
        dueDate: matingDate.add(Duration(days: birthReminderDays)),
        referenceId: breedingRecordId,
        referenceType: 'breeding_record',
      );
    }
  }

  /// Create weaning reminder (to be called after birth is recorded)
  /// Uses H-1 timing (reminder day before weaning at H+35 from birth)
  Future<void> createWeaningReminder({
    required String farmId,
    required String breedingRecordId,
    required String damName,
    required DateTime birthDate,
    int weaningReminderDays = 34, // H-1 for weaning at H+35 after birth
  }) async {
    await create(
      farmId: farmId,
      type: ReminderType.weaning,
      title: 'Penyapihan $damName',
      description: 'Besok: Pisahkan anak dari induk $damName',
      dueDate: birthDate.add(Duration(days: weaningReminderDays)),
      referenceId: breedingRecordId,
      referenceType: 'breeding_record',
    );
  }
}
