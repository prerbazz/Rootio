"""
Realistic Mock Farming and Agricultural Data Provider for Rootio QA Suites.
Simulates actual urban farmers, crop varieties, sensor readings, and network conditions.
"""

CROPS = [
    {"name": "Cherry Tomatoes", "category": "Fruit / Vegetable", "difficulty": "Medium", "weeks": 10, "water": "Daily", "sun": "Full Sun", "soil": "Loamy"},
    {"name": "Sweet Basil", "category": "Herb", "difficulty": "Easy", "weeks": 6, "water": "Moderate", "sun": "Partial Sun", "soil": "Well-draining"},
    {"name": "Spinach (Palak)", "category": "Leafy Green", "difficulty": "Easy", "weeks": 5, "water": "High", "sun": "Partial Shade", "soil": "Moist, rich"},
    {"name": "Jalapeno Chilli", "category": "Vegetable", "difficulty": "Medium", "weeks": 12, "water": "Alternate Days", "sun": "Full Sun", "soil": "Sandy Loam"},
    {"name": "Bush Green Beans", "category": "Legume", "difficulty": "Easy", "weeks": 8, "water": "Moderate", "sun": "Full Sun", "soil": "Organic Compost"},
    {"name": "Spearmint", "category": "Herb", "difficulty": "Easy", "weeks": 7, "water": "High", "sun": "Partial Shade", "soil": "Moist"},
    {"name": "Coriander / Cilantro", "category": "Herb", "difficulty": "Medium", "weeks": 4, "water": "Light daily", "sun": "Morning Sun", "soil": "Well-drained"},
    {"name": "Radish", "category": "Root", "difficulty": "Easy", "weeks": 4, "water": "Moderate", "sun": "Full Sun", "soil": "Loose sandy"},
    {"name": "Kale", "category": "Leafy Green", "difficulty": "Medium", "weeks": 8, "water": "Moderate", "sun": "Cool Sun", "soil": "Nutrient rich"},
    {"name": "Fenugreek (Methi)", "category": "Leafy Green", "difficulty": "Easy", "weeks": 3, "water": "Daily light", "sun": "Partial Sun", "soil": "Loam"},
    {"name": "Bell Pepper (Capsicum)", "category": "Vegetable", "difficulty": "Hard", "weeks": 14, "water": "Regular", "sun": "Warm Sun", "soil": "Rich compost"},
    {"name": "Cucumber (Container)", "category": "Vegetable", "difficulty": "Medium", "weeks": 9, "water": "High", "sun": "Full Sun", "soil": "Well-draining"},
    {"name": "Rosemary", "category": "Perennial Herb", "difficulty": "Medium", "weeks": 16, "water": "Low", "sun": "Bright Sun", "soil": "Gritty, dry"},
    {"name": "Microgreens (Mustard/Chia)", "category": "Microgreen", "difficulty": "Easy", "weeks": 2, "water": "Mist spray", "sun": "Indirect light", "soil": "Cocopeat"},
    {"name": "Carrots (Nantes)", "category": "Root", "difficulty": "Hard", "weeks": 11, "water": "Moderate", "sun": "Full Sun", "soil": "Deep sandy loam"}
]

FARMERS = [
    {"name": "Aarav Patel", "city": "Bengaluru", "climate": "Tropical Wet-Dry", "space": "Balcony", "exp": "Beginner"},
    {"name": "Priya Sharma", "city": "Pune", "climate": "Semi-Arid", "space": "Terrace", "exp": "Intermediate"},
    {"name": "Rohan Deshmukh", "city": "Mumbai", "climate": "Coastal Tropical", "space": "Window Sill", "exp": "Beginner"},
    {"name": "Ananya Nair", "city": "Kochi", "climate": "Tropical Monsoon", "space": "Backyard", "exp": "Experienced"},
    {"name": "Vikram Singh", "city": "Jaipur", "climate": "Arid", "space": "Rooftop Raised Bed", "exp": "Intermediate"},
    {"name": "Meera Iyer", "city": "Chennai", "climate": "Tropical Maritime", "space": "Apartment Balcony", "exp": "Beginner"},
    {"name": "Kabir Sen", "city": "Kolkata", "climate": "Subtropical", "space": "Veranda", "exp": "Intermediate"},
    {"name": "Neha Gupta", "city": "Delhi NCR", "climate": "Composite Extreme", "space": "Terrace Polyhouse", "exp": "Experienced"},
    {"name": "Siddharth Rao", "city": "Hyderabad", "climate": "Tropical Wet & Dry", "space": "Courtyard", "exp": "Beginner"},
    {"name": "Divya Menon", "city": "Coimbatore", "climate": "Moderate Plateau", "space": "Greenhouse Kit", "exp": "Experienced"}
]

FARMING_PROMPTS = [
    "Why are my tomato leaves turning yellow at the bottom during Week 3?",
    "How often should I feed fish amino acid or vermicompost to spinach?",
    "Detecting white powdery spots on basil leaves after sudden unseasonal rain.",
    "Recommend companion herbs for bush beans to deter aphids naturally.",
    "Is 4 hours of direct morning sunlight enough for container carrots?",
    "Drip irrigation emitter interval recommendation for rooftop cucumber containers.",
    "Preparing neem oil emulsion spray with mild liquid soap for spider mite infestation.",
    "Recommended potting mix ratio: cocopeat vs perlite vs vermicompost for balcony bell peppers.",
    "Optimal harvest window for coriander to prevent early bolting in warm weather.",
    "How to manage calcium deficiency causing blossom end rot in container cherry tomatoes?"
]

ENDPOINTS = [
    {"name": "Firestore Profile Sync", "path": "/v1/projects/rootio-1067/databases/(default)/documents/users/{uid}", "method": "PATCH"},
    {"name": "Crop Plan Stream", "path": "/v1/projects/rootio-1067/databases/(default)/documents/users/{uid}/plans", "method": "GET"},
    {"name": "Task Checkmark Toggle", "path": "/v1/projects/rootio-1067/databases/(default)/documents/users/{uid}/plans/{planId}", "method": "POST"},
    {"name": "Plant Journal Photo Upload", "path": "/v0/b/rootio-1067.firebasestorage.app/o/users%2F{uid}%2Fplans%2F{planId}", "method": "POST"},
    {"name": "Gemini AI Agricultural Advisory", "path": "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions", "method": "POST"},
    {"name": "Daily Farming Streak Heartbeat", "path": "/v1/projects/rootio-1067/databases/(default)/documents/users/{uid}/activity/{date}", "method": "PUT"},
    {"name": "Anonymous Firebase Auth Handshake", "path": "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={apiKey}", "method": "POST"},
    {"name": "Catalogue Compatibility Query", "path": "local://catalog_data.dart/filterCompatibleCrops", "method": "INVOKE"}
]
