// lib/data/app_state.dart
// Central state — connects UI to Firebase, AI, and recommendations.
// All existing UI code (dashboard, crop detail, etc.) still works unchanged.

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../services/ai_service.dart';
import '../services/recommendation_service.dart';
import 'catalog_data.dart';
import '../services/local_profile_service.dart';
export 'catalog_data.dart'; // so existing imports of catalogCrops still work

class AppState extends ChangeNotifier {
  // ── Services ───────────────────────────────────────────────────────────
  final FirebaseService _firebase = FirebaseService();
  final AiService _ai = AiService();
  final RecommendationService _recommender = RecommendationService();
  final LocalProfileService _localProfiles = LocalProfileService();

  // ── State ──────────────────────────────────────────────────────────────
  UserProfile? _profile;
  // Mutable buffer used during onboarding flow
  final OnboardingData _pendingOnboarding = OnboardingData();
  List<CropPlan> plans = [];
  List<WeeklyActivityEntry> weeklyActivity = [];
  List<AiInsight> _aiInsights = [];
  bool isLoading = false;
  List<String> _planOrder = []; // ordered plan IDs for dashboard
  bool _initialized = false;
  String? _uid;

  // ── Getters ────────────────────────────────────────────────────────────

  UserProfile? get profile => _profile;
  String? get uid => _uid;
  bool get isSignedIn => _uid != null;
  String get currentSessionId => _profile?.currentSessionId ?? '';

  // onboarding: mutable buffer during onboarding flow; profile data after login
  OnboardingData get onboarding =>
      _profile != null ? _profile!.toOnboardingData() : _pendingOnboarding;

  bool get hasPlans => plans.isNotEmpty;
  List<CropPlan> get activePlans {
    final active = plans.where((p) => !p.isCompleted).toList();
    if (_planOrder.isEmpty) return active;
    active.sort((a, b) {
      final ia = _planOrder.indexOf(a.id);
      final ib = _planOrder.indexOf(b.id);
      final ra = ia == -1 ? 999 : ia;
      final rb = ib == -1 ? 999 : ib;
      return ra.compareTo(rb);
    });
    return active;
  }
  List<CropPlan> get completedPlans => plans.where((p) => p.isCompleted).toList();

  int get streakDays => _profile?.streakDays ?? 0;
  int get weeklyTasksDone => weeklyActivity.fold(0, (s, e) => s + e.tasksCompleted);

  List<Map<String, String>> get todayInsights {
    final list = <Map<String, String>>[];

    for (final plan in activePlans) {
      CropTask? nextTask;
      int weekNum = 1;
      for (final week in plan.weeks) {
        for (final task in week.tasks) {
          if (!task.isCompleted) {
            nextTask = task;
            weekNum = week.weekNumber;
            break;
          }
        }
        if (nextTask != null) break;
      }

      if (nextTask != null) {
        final insightText = _generateInsightText(plan.name, nextTask.title, weekNum);
        String emoji = plan.emoji;
        if (nextTask.title.toLowerCase().contains('water') || nextTask.title.toLowerCase().contains('moist')) {
          emoji = '💧';
        } else if (nextTask.title.toLowerCase().contains('sun') || nextTask.title.toLowerCase().contains('light')) {
          emoji = '☀️';
        } else if (nextTask.title.toLowerCase().contains('pest') || nextTask.title.toLowerCase().contains('bug') || nextTask.title.toLowerCase().contains('health')) {
          emoji = '🐛';
        } else if (nextTask.title.toLowerCase().contains('harvest')) {
          emoji = '🧺';
        }
        list.add({
          'icon': emoji,
          'text': insightText,
        });
      }
    }

    if (list.length < 3) {
      final defaults = [
        {'icon': '💧', 'text': 'Water your plants early in the morning to prevent water loss and fungal diseases.'},
        {'icon': '☀️', 'text': 'Ensure your sun-loving crops get at least 6 hours of direct sunlight daily.'},
        {'icon': '✂', 'text': 'Prune dead leaves regularly to improve air circulation and direct energy to new growth.'},
        {'icon': '📋', 'text': 'Check the soil moisture level with your finger before watering. Top inch dry = water.'},
        {'icon': '🐛', 'text': 'Inspect leaf undersides once a week for early signs of pests like aphids.'},
      ];
      for (final def in defaults) {
        if (list.length >= 3) break;
        if (!list.any((item) => item['text'] == def['text'])) {
          list.add(def);
        }
      }
    }

    return list.take(3).toList();
  }

  String _generateInsightText(String crop, String task, int week) {
    final c = crop.toLowerCase();
    final t = task.toLowerCase();

    if (c.contains('spinach')) {
      if (t.contains('prepare container')) return 'Spinach prefers loose, nitrogen-rich soil. Prepare a container at least 8 inches deep.';
      if (t.contains('compost') || t.contains('nutrient')) return 'Mix organic compost into Spinach soil today to support rapid, healthy leafy growth.';
      if (t.contains('drainage')) return 'Ensure excellent drainage for your Spinach container to prevent root rot.';
      if (t.contains('plant seeds') || t.contains('sow')) return 'Sow Spinach seeds 1/2 inch deep. Space them 2-3 inches apart.';
      if (t.contains('water gently')) return 'Water Spinach gently with a fine spray to avoid washing away the seeds.';
      if (t.contains('light')) return 'Place Spinach in cool light or partial shade. It dislikes extreme afternoon heat.';
      if (t.contains('sprouts')) return 'Watch for Spinach sprouts in 5-10 days. Keep the soil surface damp.';
      if (t.contains('moist')) return 'Keep Spinach soil evenly moist. Dry soil makes leaves bitter and causes bolting.';
      if (t.contains('thin')) return 'Thin Spinach seedlings to 4-6 inches apart to let leaves spread out.';
      if (t.contains('fertiliz')) return 'Feed Spinach with nitrogen-rich organic liquid fertilizer to grow larger leaves.';
      if (t.contains('care routine')) return 'Prune outer leaves of Spinach first, leaving center shoots to grow.';
      if (t.contains('health')) return 'Inspect Spinach leaves for miner trails or spots. Trim damaged ones.';
      if (t.contains('harvest')) return 'Harvest Spinach outer leaves when they reach 3-4 inches long.';
      if (t.contains('fruits') || t.contains('enjoy')) return 'Enjoy fresh Spinach leaves in salads, smoothies, or cooked dishes!';
    }

    if (c.contains('coriander')) {
      if (t.contains('prepare container')) return 'Coriander needs well-draining soil. Choose a pot at least 10 inches deep.';
      if (t.contains('compost') || t.contains('nutrient')) return 'Mix compost into Coriander soil today. It loves organic soil but hates waterlogging.';
      if (t.contains('drainage')) return 'Check the drainage holes. Coriander roots rot easily in standing water.';
      if (t.contains('plant seeds') || t.contains('sow')) return 'Sow Coriander seeds 1/4 inch deep. Crushing seeds gently beforehand speeds up sprouting.';
      if (t.contains('water gently')) return 'Mist Coriander seeds gently. Heavy watering can wash away seeds.';
      if (t.contains('light')) return 'Place Coriander in bright morning sun. Give it partial shade in the afternoon.';
      if (t.contains('sprouts')) return 'Sprouts appear in 7-14 days. Keep the medium damp and be patient.';
      if (t.contains('moist')) return 'Coriander bolts easily if dry. Keep the soil consistently moist.';
      if (t.contains('thin')) return 'Thin Coriander sprouts to 3 inches apart to ensure healthy air circulation.';
      if (t.contains('fertiliz')) return 'Feed Coriander with a mild liquid fertilizer every two weeks for dense foliage.';
      if (t.contains('care routine')) return 'Prune Coriander stems from the top to encourage bushier side growth.';
      if (t.contains('health')) return 'Watch out for powdery mildew. Water the soil directly, not the leaves.';
      if (t.contains('harvest')) return 'Cut the top 2-3 inches of Coriander stems for fresh culinary use.';
      if (t.contains('fruits') || t.contains('enjoy')) return 'Add aromatic Coriander to curries, soups, or salsas for fresh flavor!';
    }

    if (c.contains('tomato')) {
      if (t.contains('prepare container')) return 'Tomatoes need large pots (5+ gallons) and loose, nutritious potting mix.';
      if (t.contains('compost') || t.contains('nutrient')) return 'Add calcium-rich organic compost to Tomato soil to prevent blossom end rot.';
      if (t.contains('drainage')) return 'Ensure excellent drainage for Tomatoes. Saturated roots stunt growth.';
      if (t.contains('plant seeds') || t.contains('sow')) return 'Sow Tomato seeds 1/4 inch deep. Keep the starter tray in a warm spot.';
      if (t.contains('water gently')) return 'Mist Tomato seeds gently. High humidity speeds up germination.';
      if (t.contains('light')) return 'Move Tomato seedlings to your sunniest spot (needs 6-8 hours of direct sun).';
      if (t.contains('sprouts')) return 'Watch for Tomato sprouts in 5-10 days. Ensure strong light to avoid leggy stems.';
      if (t.contains('moist')) return 'Keep Tomato soil damp but never soggy. Water when topsoil feels dry.';
      if (t.contains('thin')) return 'Thin to one strong Tomato seedling per pot. Snip extra sprouts at soil level.';
      if (t.contains('fertiliz')) return 'Begin fertilizing Tomatoes with a high-phosphorus organic blend for blooms.';
      if (t.contains('care routine')) return 'Provide stakes or cages for Tomato vines. Tie heavy stems gently.';
      if (t.contains('health')) return 'Prune lower yellow leaves of Tomatoes to prevent soil-borne fungal disease.';
      if (t.contains('harvest')) return 'Pick Tomatoes when they are fully red and release easily from the stem.';
      if (t.contains('fruits') || t.contains('enjoy')) return 'Enjoy fresh, sweet, vine-ripened tomatoes in salads or sauces!';
    }

    if (c.contains('chili') || c.contains('pepper')) {
      if (t.contains('prepare container')) return 'Chili peppers need warmth and rich soil. Choose a medium 10-inch pot.';
      if (t.contains('compost') || t.contains('nutrient')) return 'Mix aged compost and bone meal into pepper soil to promote heavy fruiting.';
      if (t.contains('drainage')) return 'Chili peppers hate wet feet. Ensure the pot drains water quickly.';
      if (t.contains('plant seeds') || t.contains('sow')) return 'Sow pepper seeds 1/4 inch deep. Keep soil warm (above 20°C) to germinate.';
      if (t.contains('water gently')) return 'Keep soil damp. Mist the surface daily until sprouts appear.';
      if (t.contains('light')) return 'Place peppers in full sun. They need warm temperatures and bright light.';
      if (t.contains('sprouts')) return 'Pepper seeds take 10-21 days to sprout. Keep them warm and damp.';
      if (t.contains('moist')) return 'Water peppers deeply once topsoil dries. Avoid frequent light watering.';
      if (t.contains('thin')) return 'Thin to the single strongest pepper seedling per container.';
      if (t.contains('fertiliz')) return 'Apply tomato/pepper fertilizer when flowers appear. Avoid excess nitrogen.';
      if (t.contains('care routine')) return 'Pinch the growing tip of young pepper plants to encourage branching.';
      if (t.contains('health')) return 'Check for aphids or mites. Spray with neem oil or soapy water if found.';
      if (t.contains('harvest')) return 'Harvest peppers when firm. Green peppers are mild; red ones are hot.';
      if (t.contains('fruits') || t.contains('enjoy')) return 'Enjoy your home-grown spicy peppers in cooking, pickling, or sauces!';
    }

    if (c.contains('strawberry')) {
      if (t.contains('prepare container')) return 'Strawberries do great in wide, shallow pots or hanging baskets.';
      if (t.contains('compost') || t.contains('nutrient')) return 'Mix organic fertilizer and compost into strawberry soil. They love rich soil.';
      if (t.contains('drainage')) return 'Strawberry roots rot easily. Use well-draining potting mix and gravel.';
      if (t.contains('plant seeds') || t.contains('sow')) return 'Press strawberry seeds gently into soil surface. Do not bury them deep.';
      if (t.contains('water gently')) return 'Mist strawberry seeds gently. Keep the tray covered to preserve moisture.';
      if (t.contains('light')) return 'Place strawberries where they get at least 6 hours of daily sunlight.';
      if (t.contains('sprouts')) return 'Strawberries germinate slowly (2-3 weeks). Keep soil surface moist.';
      if (t.contains('moist')) return 'Water strawberries consistently at the base. Saturated crowns rot.';
      if (t.contains('thin')) return 'Thin strawberry seedlings to 6 inches apart to allow crowns to develop.';
      if (t.contains('fertiliz')) return 'Feed strawberries with a potassium-rich organic food when blooms start.';
      if (t.contains('care routine')) return 'Pinch off early flowers to let the plant build a strong root system first.';
      if (t.contains('health')) return 'Mulch around strawberry plants with straw to keep berries off wet soil.';
      if (t.contains('harvest')) return 'Harvest strawberries when they are fully red. Pick with the stem attached.';
      if (t.contains('fruits') || t.contains('enjoy')) return 'Enjoy fresh, sweet, hand-picked strawberries in desserts or fresh!';
    }

    if (c.contains('marigold')) {
      if (t.contains('prepare container')) return 'Marigolds are easy-going. Prepare a medium container with general potting soil.';
      if (t.contains('compost') || t.contains('nutrient')) return 'Add a small amount of compost. Too much fertilizer reduces blooms.';
      if (t.contains('drainage')) return 'Ensure basic drainage. Marigolds are highly resilient but hate muddy soil.';
      if (t.contains('plant seeds') || t.contains('sow')) return 'Sow marigold seeds 1/4 inch deep. They sprout very easily.';
      if (t.contains('water gently')) return 'Water gently. Keep soil moist until sprouting starts.';
      if (t.contains('light')) return 'Place marigolds in direct sun. They thrive in warm, sunny locations.';
      if (t.contains('sprouts')) return 'Sprouts appear in 3-5 days. Ensure they get plenty of direct sun.';
      if (t.contains('moist')) return 'Water marigolds weekly. Allow the top soil to dry out between waterings.';
      if (t.contains('thin')) return 'Thin seedlings to 6 inches apart so they grow into bushy plants.';
      if (t.contains('fertiliz')) return 'Use a balanced flower fertilizer monthly to boost large, bright blooms.';
      if (t.contains('care routine')) return 'Pinch off faded flowers (deadheading) to encourage continuous blooming.';
      if (t.contains('health')) return 'Inspect for spider mites in dry weather. Mist foliage to repel them.';
      if (t.contains('harvest')) return 'Harvest marigold flowers for decorations, teas, or natural pest deterrents.';
      if (t.contains('fruits') || t.contains('enjoy')) return 'Enjoy the vibrant colors and pest-repelling benefits of your marigolds!';
    }

    // Generic fallbacks for any other crop (Mint, Rosemary, Basil, Cucumber, Carrot, Lettuce, Radish, Sunflower, etc.)
    if (t.contains('prepare container')) return 'Prepare a container with loose, well-draining soil for $crop. Good soil is key.';
    if (t.contains('compost') || t.contains('nutrient')) return 'Mix organic compost into the soil to give $crop a strong nutrient boost.';
    if (t.contains('drainage')) return 'Check the drainage holes in $crop\'s container. Saturated soil stunts growth.';
    if (t.contains('plant seeds') || t.contains('sow')) return 'Sow $crop seeds at the recommended depth. Pat the soil down lightly.';
    if (t.contains('water gently')) return 'Water $crop seeds gently using a spray bottle so they aren\'t displaced.';
    if (t.contains('light')) return 'Ensure $crop is placed in a spot with appropriate light matching its needs.';
    if (t.contains('sprouts')) return 'Watch for $crop shoots. Move them into direct light as soon as they emerge.';
    if (t.contains('moist')) return 'Keep $crop\'s soil evenly damp but not soggy. Check soil moisture daily.';
    if (t.contains('thin')) return 'Thin $crop sprouts to prevent crowding and ensure sturdy stem development.';
    if (t.contains('fertiliz')) return 'Feed $crop with a balanced organic plant food to support active growth.';
    if (t.contains('care routine')) return 'Maintain a daily care routine. Consistency is the secret to growing $crop.';
    if (t.contains('health')) return 'Check $crop leaves for yellowing or pests. Prune any damaged parts.';
    if (t.contains('harvest')) return 'It\'s almost time! Check if $crop is ready for harvest based on size.';
    if (t.contains('fruits') || t.contains('enjoy')) return 'Enjoy your home-grown, fresh, and healthy $crop harvest!';

    return 'Today\'s priority for $crop is to complete the task: "$task".';
  }

  List<double> get weeklyActivityValues {
    if (weeklyActivity.isEmpty) return List.filled(7, 0.0);
    final maxTasks = weeklyActivity.map((e) => e.tasksCompleted).reduce((a, b) => a > b ? a : b);
    if (maxTasks == 0) return List.filled(7, 0.0);
    return weeklyActivity.map((e) => e.tasksCompleted / maxTasks).toList();
  }

  // ── Initialization ─────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _firebase.authStateChanges.listen((user) async {
      if (user != null) {
        _uid = user.uid;
        await _loadUserData();
        if (_profile != null) {
          await _localProfiles.saveProfile(LocalProfile(
            uid: _uid!,
            name: _profile!.name,
            emoji: '🌱',
          ));
        }
      } else {
        _uid = null;
        _profile = null;
        plans = [];
        weeklyActivity = [];
      }
      notifyListeners();
    });
  }

  /// Resume an existing local profile by UID (used from splash screen auto-login)
  Future<bool> resumeProfile(String uid) async {
    isLoading = true;
    notifyListeners();
    try {
      // 1. Try to load local cache first so it starts instantly without network
      final localProfile = await _localProfiles.loadUserProfileLocal(uid);
      if (localProfile != null) {
        if (localProfile.currentSessionId.isEmpty) {
          localProfile.currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
          await _localProfiles.saveUserProfileLocal(localProfile);
        }
        _uid = uid;
        _profile = localProfile;
        _planOrder = localProfile.planOrder;
        plans = await _localProfiles.loadPlansLocal(uid);
        isLoading = false;
        notifyListeners();
        
        // Sync with Firestore in the background
        _syncFirestoreInBackground();
        return true;
      }

      // 2. If cache not available, fetch from Firestore
      var user = _firebase.currentUser;
      if (user == null || user.uid != uid) {
        user = (await _firebase.signInAnonymously()).user;
      }
      if (user != null) {
        _uid = user.uid;
        await _loadUserData();
        if (_profile != null) {
          await _localProfiles.saveUserProfileLocal(_profile!);
          await _localProfiles.savePlansLocal(_uid!, plans);
          await _localProfiles.setLastUid(_uid!);
          isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('resumeProfile error: $e');
    }
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> _syncFirestoreInBackground() async {
    if (_uid == null) return;
    try {
      var user = _firebase.currentUser;
      if (user != null) {
        _uid = user.uid;
        final remoteProfile = await _firebase.loadUserProfile(_uid!);
        if (remoteProfile != null) {
          _profile = remoteProfile;
          _planOrder = remoteProfile.planOrder;
          await _localProfiles.saveUserProfileLocal(remoteProfile);
        }
        final remotePlans = await _firebase.loadPlans(_uid!, currentSessionId);
        if (remotePlans.isNotEmpty) {
          plans = remotePlans;
          await _localProfiles.savePlansLocal(_uid!, remotePlans);
        }
        weeklyActivity = await _firebase.loadWeeklyActivity(_uid!, currentSessionId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Background sync failed: $e');
    }
  }

  Future<List<LocalProfile>> getLocalProfiles() => _localProfiles.getProfiles();

  /// Sign in anonymously (first launch) or check for existing session.
  Future<void> signInAndLoad() async {
    isLoading = true;
    notifyListeners();
    try {
      var user = _firebase.currentUser;
      if (user == null) {
        // Now using actual auth flow, no longer anonymous
        isLoading = false;
        notifyListeners();
        return;
      }
      _uid = user.uid;
      await _loadUserData();
    } catch (e) {
      debugPrint('Auth error: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    if (_uid == null) return;
    try {
      // Load local cache first for instant display
      final localProfile = await _localProfiles.loadUserProfileLocal(_uid!);
      if (localProfile != null) {
        _profile = localProfile;
        _planOrder = localProfile.planOrder;
        notifyListeners();
      }
      final localPlans = await _localProfiles.loadPlansLocal(_uid!);
      if (localPlans.isNotEmpty) {
        plans = localPlans;
        notifyListeners();
      }
    } catch (_) {}

    try {
      _profile = await _firebase.loadUserProfile(_uid!);
      if (_profile != null) {
        if (_profile!.currentSessionId.isEmpty) {
          _profile!.currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
          await _firebase.saveUserProfile(_profile!);
        }
        _planOrder = _profile!.planOrder;
        await _localProfiles.saveUserProfileLocal(_profile!);
        await _localProfiles.setLastUid(_uid!);
      }
      final remotePlans = await _firebase.loadPlans(_uid!, currentSessionId);
      if (remotePlans.isNotEmpty) {
        plans = remotePlans;
        await _localProfiles.savePlansLocal(_uid!, remotePlans);
      }
      weeklyActivity = await _firebase.loadWeeklyActivity(_uid!, currentSessionId);
    } catch (e) {
      debugPrint('Firestore fetch failed: $e');
    }
  }

  // ── Onboarding completion ──────────────────────────────────────────────

  /// Called from loading_screen after onboarding is complete.
  /// Saves profile to Firestore and generates first set of plans.
  Future<void> completeOnboarding(OnboardingData data) async {
    await signInAndLoad(); // ensure we have a UID
    if (_uid == null) return;

    _profile = UserProfile(
      uid: _uid!,
      name: data.name,
      timeCommitment: data.timeCommitment,
      growingSpaces: data.growingSpaces,
      waterAvailability: data.waterAvailability,
      goals: data.goals,
      experienceLevel: data.experienceLevel,
      climateZone: data.climateZone,
      currentSessionId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    // Save to Firestore
    await _firebase.saveUserProfile(_profile!);

    // Cache locally in both UserProfile format and legacy LocalProfile format
    await _localProfiles.saveUserProfileLocal(_profile!);
    await _localProfiles.setLastUid(_uid!);
    await _localProfiles.saveProfile(LocalProfile(
      uid: _uid!,
      name: data.name,
      emoji: '🌱',
    ));

    notifyListeners();
  }

  // Legacy method — loading_screen.dart calls initSamplePlans()
  void initSamplePlans() {
    // No-op: plans are now loaded from Firestore in completeOnboarding()
    // or _loadUserData(). Kept for API compatibility.
  }

  // ── Profile update ─────────────────────────────────────────────────────

  Future<void> updateProfile({
    String? name,
    String? timeCommitment,
    List<String>? growingSpaces,
    String? waterAvailability,
    List<String>? goals,
    String? experienceLevel,
    String? climateZone,
  }) async {
    if (_profile == null || _uid == null) return;

    if (name != null) _profile!.name = name;
    if (timeCommitment != null) _profile!.timeCommitment = timeCommitment;
    if (growingSpaces != null) _profile!.growingSpaces = growingSpaces;
    if (waterAvailability != null) _profile!.waterAvailability = waterAvailability;
    if (goals != null) _profile!.goals = goals;
    if (experienceLevel != null) _profile!.experienceLevel = experienceLevel;
    if (climateZone != null) _profile!.climateZone = climateZone;

    await _firebase.saveUserProfile(_profile!);
    await _localProfiles.saveUserProfileLocal(_profile!);
    notifyListeners();
  }

  // ── Plan CRUD ──────────────────────────────────────────────────────────

  void addPlan(CropPlan plan) {
    plans.add(plan);
    if (_uid != null) {
      try {
        _firebase.savePlan(_uid!, currentSessionId, plan);
        _localProfiles.savePlansLocal(_uid!, plans);
      } catch (e) {
        debugPrint('Failed to save plan: $e');
      }
    }
    notifyListeners();
  }

  Future<void> toggleTask(String planId, int weekIdx, int taskIdx) async {
    final plan = plans.firstWhere((p) => p.id == planId);
    final task = plan.weeks[weekIdx].tasks[taskIdx];
    final wasCompleted = task.isCompleted;
    
    // OPTIMISTIC UI UPDATE
    plan.weeks[weekIdx].tasks[taskIdx] = task.copyWith(
      isCompleted: !wasCompleted,
      completedAt: !wasCompleted ? DateTime.now() : null,
    );

    // Recalculate current stage and progress
    for (int i = 0; i < plan.weeks.length; i++) {
      plan.weeks[i].isCurrentStage = false;
    }
    for (int i = 0; i < plan.weeks.length; i++) {
      if (!plan.weeks[i].isCompleted) {
        plan.weeks[i].isCurrentStage = true;
        break;
      }
    }
    if (plan.overallProgress >= 1.0) plan.isCompleted = true;

    // Immediately notify listeners so the checkbox, progress bar, and weekly activity reflect the change instantly.
    notifyListeners();

    // Persist to Firestore and local cache in background
    if (_uid != null) {
      try {
        await _firebase.updatePlan(_uid!, currentSessionId, plan.id, {
          'weeks': plan.weeks.map((w) => w.toMap()).toList(),
          'isCompleted': plan.isCompleted,
        });
        await _localProfiles.savePlansLocal(_uid!, plans);

        if (!wasCompleted) {
          await _firebase.recordActivity(_uid!, currentSessionId, 1);
          await _firebase.updateStreak(_uid!);
          weeklyActivity = await _firebase.loadWeeklyActivity(_uid!, currentSessionId);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Failed to sync task toggle: $e');
        // Revert local state if network fails
        plan.weeks[weekIdx].tasks[taskIdx] = task;
        notifyListeners();
      }
    }
  }

  // ignore: unused_element
  String _yesterdayKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  Future<void> addNote(String planId, String content) async {
    final plan = plans.firstWhere((p) => p.id == planId);
    final note = CropNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      createdAt: DateTime.now(),
    );
    plan.notes.add(note);
    if (_uid != null) {
      await _firebase.updatePlan(_uid!, currentSessionId, planId, {
        'notes': plan.notes.map((n) => n.toMap()).toList(),
      });
      await _localProfiles.savePlansLocal(_uid!, plans);
    }
    notifyListeners();
  }

  Future<void> addPhoto(String planId, String imagePath) async {
    final plan = plans.firstWhere((p) => p.id == planId);
    String finalPath = imagePath;
    String? storageUrl;

    // Upload to Firebase Storage if signed in
    if (_uid != null) {
      try {
        storageUrl = await _firebase.uploadPhoto(_uid!, currentSessionId, planId, imagePath);
        finalPath = storageUrl;
      } catch (e) {
        debugPrint('Photo upload failed, using local path: $e');
      }
    }

    final photo = CropPhoto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: finalPath,
      storageUrl: storageUrl,
      takenAt: DateTime.now(),
    );
    plan.photos.add(photo);
    if (_uid != null) {
      await _firebase.updatePlan(_uid!, currentSessionId, planId, {
        'photos': plan.photos.map((p) => p.toMap()).toList(),
      });
      await _localProfiles.savePlansLocal(_uid!, plans);
    }
    notifyListeners();
  }

  Future<void> removeNote(String planId, String noteId) async {
    final plan = plans.firstWhere((p) => p.id == planId);
    plan.notes.removeWhere((n) => n.id == noteId);
    if (_uid != null) {
      await _firebase.updatePlan(_uid!, currentSessionId, planId, {
        'notes': plan.notes.map((n) => n.toMap()).toList(),
      });
      await _localProfiles.savePlansLocal(_uid!, plans);
    }
    notifyListeners();
  }

  Future<void> removePhoto(String planId, String photoId) async {
    final plan = plans.firstWhere((p) => p.id == planId);
    final photo = plan.photos.firstWhere((p) => p.id == photoId);
    plan.photos.removeWhere((p) => p.id == photoId);
    
    if (_uid != null) {
      if (photo.storageUrl != null) {
        await _firebase.deletePhoto(photo.storageUrl!);
      }
      await _firebase.updatePlan(_uid!, currentSessionId, planId, {
        'photos': plan.photos.map((p) => p.toMap()).toList(),
      });
      await _localProfiles.savePlansLocal(_uid!, plans);
    }
    notifyListeners();
  }

  CropPlan addCropFromCatalog(CatalogCrop crop) {
    final location = _profile?.growingSpaces.isNotEmpty == true
        ? _profile!.growingSpaces.first
        : 'Balcony';
    final plan = _buildPlanFromCatalog(crop, location);
    addPlan(plan);
    return plan;
  }

  Future<void> reorderPlans(int oldIndex, int newIndex) async {
    final active = activePlans;
    if (oldIndex < 0 || oldIndex >= active.length) return;
    if (newIndex < 0 || newIndex >= active.length) return;
    final item = active.removeAt(oldIndex);
    active.insert(newIndex, item);
    _planOrder = active.map((p) => p.id).toList();
    // Persist order to Firestore user profile and local cache
    if (_uid != null) {
      await _firebase.updateProfileField(_uid!, {'planOrder': _planOrder});
      if (_profile != null) {
        _profile!.planOrder = _planOrder;
        await _localProfiles.saveUserProfileLocal(_profile!);
      }
    }
    notifyListeners();
  }

  Future<void> removeCrop(String planId, String reason, String? customReason) async {
    final finalReason = customReason?.isNotEmpty == true ? '$reason: $customReason' : reason;
    plans.removeWhere((p) => p.id == planId);
    
    if (_uid != null) {
      await _firebase.removeCrop(_uid!, currentSessionId, planId, finalReason);
      await _localProfiles.savePlansLocal(_uid!, plans);
    }
    notifyListeners();
  }

  Future<void> deletePlan(String planId) async {
    plans.removeWhere((p) => p.id == planId);
    if (_uid != null) {
      await _firebase.deletePlan(_uid!, currentSessionId, planId);
      await _localProfiles.savePlansLocal(_uid!, plans);
    }
    notifyListeners();
  }

  Future<void> deleteAllPlans() async {
    plans.clear();
    if (_uid != null) {
      await _firebase.deleteAllPlans(_uid!, currentSessionId);
      await _localProfiles.deletePlansLocal(_uid!);
    }
    notifyListeners();
  }

  // ── Recommendations ────────────────────────────────────────────────────

  List<CatalogCrop> getRecommendedCatalog() {
    if (_profile == null) return allCatalogCrops;
    final alreadyGrowing = plans.map((p) => p.name).toList();
    return _recommender.getFilteredCatalog(
      growingSpaces: _profile!.growingSpaces,
      waterAvailability: _profile!.waterAvailability,
      climateZone: _profile!.climateZone,
      experienceLevel: _profile!.experienceLevel,
      timeCommitment: _profile!.timeCommitment,
      alreadyGrowing: alreadyGrowing,
    );
  }

  // ── Insights (Deterministic fallback) ──────────────────────────────────

  Future<void> refreshInsights() async {
    // Insights are computed deterministically in the getter.
    // This method is kept for backward compatibility and is a fast UI update.
    notifyListeners();
  }

  /// Reset App: Archives current session, clears local state, starts new session.
  Future<void> resetApp() async {
    isLoading = true;
    notifyListeners();

    try {
      if (_uid != null && _profile != null) {
        // Create new session ID, archiving the old one in Firestore (implicitly)
        _profile!.currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
        _profile!.planOrder = [];
        await _firebase.saveUserProfile(_profile!);
        await _localProfiles.saveUserProfileLocal(_profile!);
      }
      
      // Clear local plans
      plans = [];
      weeklyActivity = [];
      _planOrder = [];
      if (_uid != null) {
        await _localProfiles.savePlansLocal(_uid!, plans);
      }
      
    } catch (e) {
      debugPrint('Reset app failed: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    isLoading = true;
    notifyListeners();
    try {
      await _firebase.signOut();
      await _localProfiles.clearAll();
      _uid = null;
      _profile = null;
      plans = [];
      weeklyActivity = [];
      _planOrder = [];
    } catch (e) {
      debugPrint('Sign out failed: $e');
    }
    isLoading = false;
    notifyListeners();
  }
}

// ─── Plan template builder ────────────────────────────────────────────────────

CropPlan _buildPlanFromCatalog(CatalogCrop crop, String location) {
  return CropPlan(
    id: '${crop.name.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}',
    name: crop.name,
    emoji: crop.emoji,
    difficulty: crop.difficulty,
    location: location,
    totalWeeks: 8,
    startedAt: DateTime.now(),
    quickTips: [
      'Water regularly and check soil moisture',
      'Ensure adequate sunlight for best growth',
      'Monitor for pests weekly',
    ],
    weeks: [
      CropWeek(weekNumber: 1, title: 'Soil Preparation', isCurrentStage: true, tasks: [
        CropTask(id: '${crop.name}-1-1', title: 'Prepare container and soil'),
        CropTask(id: '${crop.name}-1-2', title: 'Add nutrients/compost'),
        CropTask(id: '${crop.name}-1-3', title: 'Ensure drainage'),
      ]),
      CropWeek(weekNumber: 2, title: 'Sowing', tasks: [
        CropTask(id: '${crop.name}-2-1', title: 'Plant seeds at correct depth'),
        CropTask(id: '${crop.name}-2-2', title: 'Water gently'),
        CropTask(id: '${crop.name}-2-3', title: 'Place in suitable light'),
      ]),
      CropWeek(weekNumber: 3, title: 'Germination', tasks: [
        CropTask(id: '${crop.name}-3-1', title: 'Watch for sprouts'),
        CropTask(id: '${crop.name}-3-2', title: 'Keep soil moist'),
      ]),
      CropWeek(weekNumber: 4, title: 'Early Growth', tasks: [
        CropTask(id: '${crop.name}-4-1', title: 'Thin seedlings'),
        CropTask(id: '${crop.name}-4-2', title: 'Begin fertilizing'),
      ]),
      CropWeek(weekNumber: 5, title: 'Active Growth', tasks: [
        CropTask(id: '${crop.name}-5-1', title: 'Continue care routine'),
        CropTask(id: '${crop.name}-5-2', title: 'Monitor plant health'),
      ]),
      CropWeek(weekNumber: 6, title: 'Maturing', tasks: [
        CropTask(id: '${crop.name}-6-1', title: 'Adjust watering as needed'),
        CropTask(id: '${crop.name}-6-2', title: 'Watch for harvest signs'),
      ]),
      CropWeek(weekNumber: 7, title: 'Pre-Harvest', tasks: [
        CropTask(id: '${crop.name}-7-1', title: 'Check ripeness/readiness'),
        CropTask(id: '${crop.name}-7-2', title: 'Prepare for harvest'),
      ]),
      CropWeek(weekNumber: 8, title: 'Harvest', tasks: [
        CropTask(id: '${crop.name}-8-1', title: 'Harvest your crop!'),
        CropTask(id: '${crop.name}-8-2', title: 'Enjoy the fruits of your labor'),
      ]),
    ],
  );
}
