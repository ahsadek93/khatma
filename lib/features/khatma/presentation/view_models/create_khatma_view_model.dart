import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatmah/core/providers/app_providers.dart';
import 'package:khatmah/features/khatma/domain/entities/khatma.dart';
import 'package:khatmah/features/khatma/presentation/view_models/khatma_view_models.dart';

/// How the user expresses the finish goal. Day-count presets keep v1 calendar
/// agnostic; a Hijri-aware "Ramadan" preset can join later.
enum KhatmaGoalPreset { week, month, custom }

/// Immutable form state for creating a khatma.
class CreateKhatmaForm {
  const CreateKhatmaForm({
    required this.title,
    required this.preset,
    required this.startDate,
    required this.targetDate,
    this.submitting = false,
  });

  final String title;
  final KhatmaGoalPreset preset;
  final DateTime startDate;
  final DateTime targetDate;
  final bool submitting;

  /// Total span in days (inclusive of both ends).
  int get totalDays {
    final d = targetDate.difference(startDate).inDays + 1;
    return d < 1 ? 1 : d;
  }

  /// Ajzāʾ-per-day a reader would need to average to finish on time.
  int get dailyTargetPreview => (30 / totalDays).ceil();

  bool get isValid =>
      title.trim().isNotEmpty && !targetDate.isBefore(startDate);

  CreateKhatmaForm copyWith({
    String? title,
    KhatmaGoalPreset? preset,
    DateTime? startDate,
    DateTime? targetDate,
    bool? submitting,
  }) {
    return CreateKhatmaForm(
      title: title ?? this.title,
      preset: preset ?? this.preset,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      submitting: submitting ?? this.submitting,
    );
  }
}

class CreateKhatmaViewModel extends Notifier<CreateKhatmaForm> {
  @override
  CreateKhatmaForm build() {
    final now = ref.read(clockProvider)();
    final start = DateTime(now.year, now.month, now.day);
    return CreateKhatmaForm(
      title: '',
      preset: KhatmaGoalPreset.month,
      startDate: start,
      targetDate: _targetFor(KhatmaGoalPreset.month, start, start),
    );
  }

  void setTitle(String value) => state = state.copyWith(title: value);

  void setPreset(KhatmaGoalPreset preset) {
    state = state.copyWith(
      preset: preset,
      targetDate: _targetFor(preset, state.startDate, state.targetDate),
    );
  }

  void setTargetDate(DateTime date) => state = state.copyWith(
        preset: KhatmaGoalPreset.custom,
        targetDate: DateTime(date.year, date.month, date.day),
      );

  DateTime _targetFor(
    KhatmaGoalPreset preset,
    DateTime start,
    DateTime current,
  ) {
    switch (preset) {
      case KhatmaGoalPreset.week:
        return start.add(const Duration(days: 6));
      case KhatmaGoalPreset.month:
        return start.add(const Duration(days: 29));
      case KhatmaGoalPreset.custom:
        return current;
    }
  }

  /// Creates the khatma and returns it for navigation, or null if invalid /
  /// already submitting.
  Future<Khatma?> submit() async {
    if (!state.isValid || state.submitting) return null;
    state = state.copyWith(submitting: true);
    try {
      return await ref.read(khatmaCommandsProvider).create(
            title: state.title.trim(),
            startDate: state.startDate,
            targetDate: state.targetDate,
          );
    } finally {
      state = state.copyWith(submitting: false);
    }
  }
}

final createKhatmaViewModelProvider =
    NotifierProvider.autoDispose<CreateKhatmaViewModel, CreateKhatmaForm>(
  CreateKhatmaViewModel.new,
);
