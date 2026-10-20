"""
Precise Rootio Domain Data Provider.
100% aligned with Rootio's actual Dart code, enums, catalog definitions, and UI boundaries.
All values match models.dart, catalog_data.dart, onboarding steps 1-4, and onboarding_final.dart.
"""

# The exact 14 crops defined in lib/data/catalog_data.dart
CROPS = [
    {"name": "Spinach", "emoji": "🥬", "category": "Vegetables", "difficulty": "Easy", "weeks": 8, "water": "Tap Water"},
    {"name": "Coriander", "emoji": "🌿", "category": "Herbs", "difficulty": "Easy", "weeks": 4, "water": "Tap Water"},
    {"name": "Strawberry", "emoji": "🍓", "category": "Fruits", "difficulty": "Medium", "weeks": 16, "water": "Tap Water"},
    {"name": "Chili Peppers", "emoji": "🌶️", "category": "Vegetables", "difficulty": "Medium", "weeks": 12, "water": "Tap Water"},
    {"name": "Marigold", "emoji": "🌼", "category": "Flowers", "difficulty": "Easy", "weeks": 10, "water": "Tap Water"},
    {"name": "Cucumber", "emoji": "🥒", "category": "Vegetables", "difficulty": "Medium", "weeks": 10, "water": "Tap Water"},
    {"name": "Rosemary", "emoji": "🌱", "category": "Herbs", "difficulty": "Easy", "weeks": 12, "water": "Limited Access"},
    {"name": "Carrot", "emoji": "🥕", "category": "Vegetables", "difficulty": "Medium", "weeks": 12, "water": "Rainwater"},
    {"name": "Lettuce", "emoji": "🥗", "category": "Vegetables", "difficulty": "Easy", "weeks": 7, "water": "Tap Water"},
    {"name": "Mint", "emoji": "🌿", "category": "Herbs", "difficulty": "Easy", "weeks": 6, "water": "Tap Water"},
    {"name": "Cherry Tomatoes", "emoji": "🍅", "category": "Vegetables", "difficulty": "Easy", "weeks": 10, "water": "Tap Water"},
    {"name": "Bell Peppers", "emoji": "🫑", "category": "Vegetables", "difficulty": "Medium", "weeks": 14, "water": "Tap Water"},
    {"name": "Basil", "emoji": "🌿", "category": "Herbs", "difficulty": "Easy", "weeks": 6, "water": "Tap Water"},
    {"name": "Radish", "emoji": "🌰", "category": "Vegetables", "difficulty": "Easy", "weeks": 4, "water": "Stored Water"},
    {"name": "Sunflower", "emoji": "🌻", "category": "Flowers", "difficulty": "Easy", "weeks": 12, "water": "Rainwater"}
]

# The EXACT 5 growing spaces from lib/screens/onboarding/onboarding_step2.dart
SPACES = [
    "Balcony",
    "Terrace/Rooftop",
    "Indoor Space",
    "Backyard",
    "Community Garden"
]

# The EXACT 6 climate zones from lib/screens/onboarding/onboarding_final.dart
CLIMATES = [
    "Tropical",
    "Subtropical",
    "Temperate",
    "Arid",
    "Mediterranean",
    "Not Sure"
]

# The EXACT 3 experience levels from lib/screens/onboarding/onboarding_final.dart
EXPERIENCES = [
    "Complete Beginner",
    "Some Experience",
    "Experienced"
]

# The EXACT 5 time commitments from lib/screens/onboarding/onboarding_step1.dart
TIMES = [
    "15 min/day",
    "30 min/day",
    "1 hour/day",
    "2+ hours/day",
    "Weekends only"
]

# The EXACT 4 water access options from lib/screens/onboarding/onboarding_step3.dart
WATERS = [
    "Tap Water",
    "Stored Water",
    "Rainwater",
    "Limited Access"
]

# The EXACT 4 farming goals from lib/screens/onboarding/onboarding_step4.dart
GOALS = [
    "Hobby & Learning",
    "Fresh Food",
    "Extra Income",
    "Wellness & Therapy"
]

# Realistic Indian and global urban farmers using 100% valid app options
FARMERS = [
    {"name": "Aarav Patel", "city": "Bengaluru", "climate": "Tropical", "space": "Balcony", "exp": "Complete Beginner", "time": "15 min/day", "water": "Tap Water", "goal": "Hobby & Learning"},
    {"name": "Priya Sharma", "city": "Pune", "climate": "Subtropical", "space": "Terrace/Rooftop", "exp": "Some Experience", "time": "30 min/day", "water": "Stored Water", "goal": "Fresh Food"},
    {"name": "Rohan Deshmukh", "city": "Mumbai", "climate": "Tropical", "space": "Indoor Space", "exp": "Complete Beginner", "time": "15 min/day", "water": "Tap Water", "goal": "Wellness & Therapy"},
    {"name": "Ananya Nair", "city": "Kochi", "climate": "Tropical", "space": "Backyard", "exp": "Experienced", "time": "1 hour/day", "water": "Rainwater", "goal": "Fresh Food"},
    {"name": "Vikram Singh", "city": "Jaipur", "climate": "Arid", "space": "Terrace/Rooftop", "exp": "Some Experience", "time": "30 min/day", "water": "Limited Access", "goal": "Extra Income"},
    {"name": "Meera Iyer", "city": "Chennai", "climate": "Tropical", "space": "Balcony", "exp": "Complete Beginner", "time": "15 min/day", "water": "Tap Water", "goal": "Hobby & Learning"},
    {"name": "Kabir Sen", "city": "Kolkata", "climate": "Subtropical", "space": "Balcony", "exp": "Some Experience", "time": "30 min/day", "water": "Tap Water", "goal": "Fresh Food"},
    {"name": "Neha Gupta", "city": "Delhi NCR", "climate": "Temperate", "space": "Terrace/Rooftop", "exp": "Experienced", "time": "2+ hours/day", "water": "Stored Water", "goal": "Fresh Food"},
    {"name": "Siddharth Rao", "city": "Hyderabad", "climate": "Tropical", "space": "Backyard", "exp": "Complete Beginner", "time": "Weekends only", "water": "Tap Water", "goal": "Wellness & Therapy"},
    {"name": "Divya Menon", "city": "Coimbatore", "climate": "Mediterranean", "space": "Community Garden", "exp": "Experienced", "time": "1 hour/day", "water": "Rainwater", "goal": "Hobby & Learning"}
]

# Context-accurate farming prompts matched directly to Rootio crops
FARMING_PROMPTS = [
    "Why are my Spinach leaves turning yellow at the bottom during Week 3?",
    "How often should I feed fish amino acid or vermicompost to Coriander?",
    "Detecting white powdery spots on Mint leaves after sudden unseasonal rain.",
    "Recommend companion herbs for Strawberry to deter aphids naturally in a Balcony.",
    "Is 4 hours of direct morning sunlight enough for container Carrot?",
    "Watering schedule recommendation for rooftop Cucumber containers during summer.",
    "Preparing neem oil emulsion spray with mild liquid soap for spider mite infestation on Chili Peppers.",
    "Recommended potting mix ratio: cocopeat vs perlite vs vermicompost for balcony Bell Peppers.",
    "Optimal harvest window for Basil to prevent early flowering in warm weather.",
    "How to manage calcium deficiency causing blossom end rot in container Cherry Tomatoes?"
]
