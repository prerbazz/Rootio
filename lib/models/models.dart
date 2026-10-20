// ─── Onboarding / User Profile Model ─────────────────────────────────────────

class UserProfile {
  final String uid;
  String name;
  String timeCommitment;
  List<String> growingSpaces;
  String waterAvailability;
  List<String> goals;
  String experienceLevel;
  String climateZone;
  int streakDays;
  String lastActiveDate; // ISO date string yyyy-MM-dd
  List<String> planOrder; // ordered plan IDs for dashboard
  String currentSessionId;

  UserProfile({
    required this.uid,
    this.name = '',
    this.timeCommitment = '',
    List<String>? growingSpaces,
    this.waterAvailability = '',
    List<String>? goals,
    this.experienceLevel = '',
    this.climateZone = 'Not Sure',
    this.streakDays = 0,
    this.lastActiveDate = '',
    List<String>? planOrder,
    this.currentSessionId = '',
  })  : growingSpaces = growingSpaces ?? [],
        goals = goals ?? [],
        planOrder = planOrder ?? [];

  /// Build from Firestore document map
  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      timeCommitment: map['timeCommitment'] ?? '',
      growingSpaces: List<String>.from(map['growingSpaces'] ?? []),
      waterAvailability: map['waterAvailability'] ?? '',
      goals: List<String>.from(map['goals'] ?? []),
      experienceLevel: map['experienceLevel'] ?? '',
      climateZone: map['climateZone'] ?? 'Not Sure',
      streakDays: (map['streakDays'] ?? 0) as int,
      lastActiveDate: map['lastActiveDate'] ?? '',
      planOrder: List<String>.from(map['planOrder'] ?? []),
      currentSessionId: map['currentSessionId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'timeCommitment': timeCommitment,
        'growingSpaces': growingSpaces,
        'waterAvailability': waterAvailability,
        'goals': goals,
        'experienceLevel': experienceLevel,
        'climateZone': climateZone,
        'streakDays': streakDays,
        'lastActiveDate': lastActiveDate,
        'planOrder': planOrder,
        'currentSessionId': currentSessionId,
      };

  // Legacy compat — so existing onboarding code still works
  OnboardingData toOnboardingData() => OnboardingData(
        name: name,
        timeCommitment: timeCommitment,
        growingSpaces: List<String>.from(growingSpaces),
        waterAvailability: waterAvailability,
        goals: List<String>.from(goals),
        experienceLevel: experienceLevel,
        climateZone: climateZone,
      );
}

// Keep original OnboardingData for onboarding flow compatibility
class OnboardingData {
  String timeCommitment;
  List<String> growingSpaces;
  String waterAvailability;
  List<String> goals;
  String name;
  String experienceLevel;
  String climateZone;

  OnboardingData({
    this.timeCommitment = '',
    List<String>? growingSpaces,
    this.waterAvailability = '',
    List<String>? goals,
    this.name = '',
    this.experienceLevel = '',
    this.climateZone = 'Not Sure',
  })  : growingSpaces = growingSpaces ?? [],
        goals = goals ?? [];
}

// ─── Crop Task ────────────────────────────────────────────────────────────────

class CropTask {
  final String id;
  final String title;
  bool isCompleted;
  DateTime? completedAt;

  CropTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  CropTask copyWith({bool? isCompleted, DateTime? completedAt}) => CropTask(
        id: id,
        title: title,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
      );

  factory CropTask.fromMap(Map<String, dynamic> map) => CropTask(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        isCompleted: map['isCompleted'] ?? false,
        completedAt: map['completedAt'] != null
            ? DateTime.tryParse(map['completedAt'])
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };
}

// ─── Crop Week ────────────────────────────────────────────────────────────────

class CropWeek {
  final int weekNumber;
  final String title;
  final List<CropTask> tasks;
  bool isCurrentStage;

  CropWeek({
    required this.weekNumber,
    required this.title,
    required this.tasks,
    this.isCurrentStage = false,
  });

  bool get isCompleted => tasks.isNotEmpty && tasks.every((t) => t.isCompleted);

  double get progress {
    if (tasks.isEmpty) return 0;
    return tasks.where((t) => t.isCompleted).length / tasks.length;
  }

  factory CropWeek.fromMap(Map<String, dynamic> map) => CropWeek(
        weekNumber: map['weekNumber'] ?? 0,
        title: map['title'] ?? '',
        isCurrentStage: map['isCurrentStage'] ?? false,
        tasks: (map['tasks'] as List<dynamic>? ?? [])
            .map((t) => CropTask.fromMap(Map<String, dynamic>.from(t)))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'weekNumber': weekNumber,
        'title': title,
        'isCurrentStage': isCurrentStage,
        'tasks': tasks.map((t) => t.toMap()).toList(),
      };
}

// ─── Crop Note ────────────────────────────────────────────────────────────────

class CropNote {
  final String id;
  final String content;
  final DateTime createdAt;

  CropNote({required this.id, required this.content, required this.createdAt});

  factory CropNote.fromMap(Map<String, dynamic> map) => CropNote(
        id: map['id'] ?? '',
        content: map['content'] ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };
}

// ─── Crop Photo ───────────────────────────────────────────────────────────────

class CropPhoto {
  final String id;
  final String imagePath;   // local path (before upload) or Firebase Storage URL
  final String? storageUrl; // Firebase Storage download URL after upload
  final DateTime takenAt;

  CropPhoto({
    required this.id,
    required this.imagePath,
    this.storageUrl,
    required this.takenAt,
  });

  factory CropPhoto.fromMap(Map<String, dynamic> map) => CropPhoto(
        id: map['id'] ?? '',
        imagePath: map['imagePath'] ?? '',
        storageUrl: map['storageUrl'],
        takenAt: DateTime.tryParse(map['takenAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'imagePath': imagePath,
        'storageUrl': storageUrl,
        'takenAt': takenAt.toIso8601String(),
      };
}

// ─── Crop Plan ────────────────────────────────────────────────────────────────

class CropPlan {
  final String id;
  final String name;
  final String emoji;
  final String difficulty;
  String location;
  final int totalWeeks;
  List<CropWeek> weeks;
  List<CropNote> notes;
  List<CropPhoto> photos;
  bool isCompleted;
  final List<String> quickTips;
  final DateTime startedAt;
  String sessionId;
  bool isActive;
  String? removalReason;

  CropPlan({
    required this.id,
    required this.name,
    required this.emoji,
    required this.difficulty,
    required this.location,
    required this.totalWeeks,
    required this.weeks,
    List<CropNote>? notes,
    List<CropPhoto>? photos,
    this.isCompleted = false,
    List<String>? quickTips,
    DateTime? startedAt,
    this.sessionId = '',
    this.isActive = true,
    this.removalReason,
  })  : notes = notes ?? [],
        photos = photos ?? [],
        quickTips = quickTips ?? [],
        startedAt = startedAt ?? DateTime.now();

  int get completedTasks =>
      weeks.expand((w) => w.tasks).where((t) => t.isCompleted).length;
  int get totalTasks => weeks.expand((w) => w.tasks).length;

  double get overallProgress {
    if (totalTasks == 0) return 0;
    return completedTasks / totalTasks;
  }

  int get currentWeek {
    for (int i = 0; i < weeks.length; i++) {
      if (!weeks[i].isCompleted) return i + 1;
    }
    return weeks.length;
  }

  String get currentWeekTitle {
    final idx = currentWeek - 1;
    if (idx < weeks.length) return weeks[idx].title;
    return 'Complete';
  }

  factory CropPlan.fromMap(String id, Map<String, dynamic> map) => CropPlan(
        id: id,
        name: map['name'] ?? '',
        emoji: map['emoji'] ?? '🌱',
        difficulty: map['difficulty'] ?? 'Easy',
        location: map['location'] ?? 'Balcony',
        totalWeeks: map['totalWeeks'] ?? 8,
        isCompleted: map['isCompleted'] ?? false,
        quickTips: List<String>.from(map['quickTips'] ?? []),
        startedAt: DateTime.tryParse(map['startedAt'] ?? '') ?? DateTime.now(),
        sessionId: map['sessionId'] ?? '',
        isActive: map['isActive'] ?? true,
        removalReason: map['removalReason'],
        weeks: (map['weeks'] as List<dynamic>? ?? [])
            .map((w) => CropWeek.fromMap(Map<String, dynamic>.from(w)))
            .toList(),
        notes: (map['notes'] as List<dynamic>? ?? [])
            .map((n) => CropNote.fromMap(Map<String, dynamic>.from(n)))
            .toList(),
        photos: (map['photos'] as List<dynamic>? ?? [])
            .map((p) => CropPhoto.fromMap(Map<String, dynamic>.from(p)))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'emoji': emoji,
        'difficulty': difficulty,
        'location': location,
        'totalWeeks': totalWeeks,
        'isCompleted': isCompleted,
        'quickTips': quickTips,
        'startedAt': startedAt.toIso8601String(),
        'sessionId': sessionId,
        'isActive': isActive,
        'removalReason': removalReason,
        'weeks': weeks.map((w) => w.toMap()).toList(),
        'notes': notes.map((n) => n.toMap()).toList(),
        'photos': photos.map((p) => p.toMap()).toList(),
      };
}

// ─── Catalog Crop (extended with recommendation metadata) ────────────────────

class CatalogCrop {
  final String name;
  final String emoji;
  final String category;
  final List<String> tags;
  final String difficulty;
  final String duration;
  final String yield;
  // Recommendation filtering fields
  final List<String> compatibleLocations; // e.g. ['Balcony','Indoor','Terrace']
  final List<String> waterNeeds;          // e.g. ['Tap Water','Stored Water']
  final List<String> compatibleClimates;  // e.g. ['Tropical','Subtropical']
  final List<String> suitableExperience;  // e.g. ['Complete Beginner','Some Experience']
  final int minMinutesPerDay;             // minimum time needed

  const CatalogCrop({
    required this.name,
    required this.emoji,
    required this.category,
    required this.tags,
    required this.difficulty,
    required this.duration,
    required this.yield,
    this.compatibleLocations = const [],
    this.waterNeeds = const [],
    this.compatibleClimates = const [],
    this.suitableExperience = const [],
    this.minMinutesPerDay = 15,
  });
}

// ─── Weekly Activity Entry ────────────────────────────────────────────────────

class WeeklyActivityEntry {
  final String date;    // ISO date string
  final int tasksCompleted;

  WeeklyActivityEntry({required this.date, required this.tasksCompleted});

  factory WeeklyActivityEntry.fromMap(Map<String, dynamic> map) =>
      WeeklyActivityEntry(
        date: map['date'] ?? '',
        tasksCompleted: map['tasksCompleted'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'date': date,
        'tasksCompleted': tasksCompleted,
      };
}

// ─── AI Insight ──────────────────────────────────────────────────────────────

class AiInsight {
  final String icon;
  final String text;
  final String type; // 'tip' | 'warning' | 'motivation'

  AiInsight({required this.icon, required this.text, required this.type});

  factory AiInsight.fromMap(Map<String, dynamic> map) => AiInsight(
        icon: map['icon'] ?? '💡',
        text: map['text'] ?? '',
        type: map['type'] ?? 'tip',
      );

  Map<String, dynamic> toMap() => {
        'icon': icon,
        'text': text,
        'type': type,
      };
}
