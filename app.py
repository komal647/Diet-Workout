import json
from antigravity import AntiGravity, Response, render_template

# Initialize AntiGravity Application
app = AntiGravity()

# Granular database of basic food ingredients with macro content per standard serving unit
INGREDIENTS = {
    "egg": {"name": "Whole Egg", "calories": 70, "protein": 6, "unit": "qty"},
    "paneer": {"name": "Paneer", "calories": 300, "protein": 18, "unit": "100g"},
    "roti": {"name": "Whole Wheat Roti", "calories": 120, "protein": 4, "unit": "qty"},
    "milk": {"name": "Toned Milk", "calories": 50, "protein": 3, "unit": "100ml"},
    "whey": {"name": "Whey Protein", "calories": 130, "protein": 24, "unit": "scoop"},
    "oats": {"name": "Oats", "calories": 150, "protein": 6, "unit": "40g"},
    "rice": {"name": "Brown Rice (Cooked)", "calories": 110, "protein": 3, "unit": "100g"},
    "chicken": {"name": "Grilled Chicken", "calories": 165, "protein": 31, "unit": "100g"},
    "sprouts": {"name": "Boiled Sprouts", "calories": 100, "protein": 7, "unit": "100g"},
    "soya": {"name": "Boiled Soya Chunks", "calories": 150, "protein": 26, "unit": "100g"},
    "toast": {"name": "Wheat Toast", "calories": 70, "protein": 3, "unit": "qty"},
    "curd": {"name": "Low-Fat Curd", "calories": 60, "protein": 4, "unit": "100g"},
    "dal": {"name": "Cooked Dal", "calories": 120, "protein": 8, "unit": "cup"},
    "banana": {"name": "Banana", "calories": 90, "protein": 1, "unit": "qty"},
    "almonds": {"name": "Almonds", "calories": 70, "protein": 2, "unit": "10 almonds"},
    
    # 1. Soya Chunks & Plant Protein
    "soya_bhurji": {"name": "Soya Bhurji / Keema (50g dry)", "calories": 170, "protein": 26, "unit": "serving"},
    "soya_salad": {"name": "Soya Chunks Salad (50g dry)", "calories": 175, "protein": 26, "unit": "serving"},
    
    # 2. Dairy & Traditional Staples
    "low_fat_paneer": {"name": "Low-Fat Paneer (120g)", "calories": 220, "protein": 24, "unit": "serving"},
    "high_protein_lassi": {"name": "High-Protein Lassi/Buttermilk (200ml)", "calories": 120, "protein": 15, "unit": "pack"},
    "sattu_shake": {"name": "Sattu Shake (40g / 4 tbsp)", "calories": 160, "protein": 9, "unit": "serving"},
    
    # 3. Lentils, Legumes & Fibers
    "kala_chana": {"name": "Boiled Kala Chana (1 Cup)", "calories": 270, "protein": 15, "unit": "serving"},
    "moong_sprouts": {"name": "Green Moong Sprouts (1.5 Cups/150g)", "calories": 150, "protein": 11, "unit": "serving"},
    "rajma_lobia": {"name": "Rajma / Lobia Curry (1 Cup)", "calories": 240, "protein": 13, "unit": "serving"},
    
    # 4. Premium Non-Vegetarian Staples
    "grilled_chicken_breast": {"name": "Grilled Chicken Breast (200g)", "calories": 330, "protein": 62, "unit": "serving"},
    "chicken_curry": {"name": "Chicken Curry (150g cooked)", "calories": 280, "protein": 35, "unit": "serving"},
    "grilled_fish": {"name": "Grilled Fish Fillet (150g)", "calories": 180, "protein": 30, "unit": "serving"},
    "egg_whites": {"name": "4 Egg Whites", "calories": 70, "protein": 16, "unit": "serving"},
    "boiled_eggs": {"name": "2 Boiled Eggs", "calories": 150, "protein": 12, "unit": "serving"},
    "white_rice": {"name": "White Rice (Cooked)", "calories": 130, "protein": 2.5, "unit": "100g"}
}

# Mapping of meal categories to valid components for targeted custom selections
MEAL_INGREDIENTS = {
    "breakfast": ["egg", "toast", "milk", "paneer", "roti", "whey", "oats", "boiled_eggs", "egg_whites", "high_protein_lassi", "sattu_shake"],
    "mid_workout": ["banana", "almonds", "whey", "milk", "high_protein_lassi"],
    "lunch": ["paneer", "dal", "roti", "chicken", "rice", "white_rice", "curd", "soya_bhurji", "low_fat_paneer", "kala_chana", "rajma_lobia", "grilled_chicken_breast", "chicken_curry", "grilled_fish"],
    "snack": ["whey", "curd", "soya", "sprouts", "almonds", "soya_salad", "high_protein_lassi", "sattu_shake", "moong_sprouts", "egg_whites", "boiled_eggs"],
    "dinner": ["chicken", "rice", "white_rice", "paneer", "roti", "dal", "curd", "soya_bhurji", "low_fat_paneer", "kala_chana", "rajma_lobia", "grilled_chicken_breast", "chicken_curry", "grilled_fish"]
}

# 10kg Dumbbell and Bodyweight Hypertrophy routines split into targeted days
EXERCISE_DATABASE = {
    "push": {
        "name": "Push Day (Home & 10kg Dumbbells)",
        "exercises": [
            {"id": "db_floor_press", "name": "Dumbbell Floor Press (10kg)", "calories_burned": 100, "muscle_group": "Chest", "sets_reps": "4 sets x 12-15 reps"},
            {"id": "pushups", "name": "Classic Bodyweight Push-ups", "calories_burned": 80, "muscle_group": "Chest/Triceps", "sets_reps": "4 sets x Max reps"},
            {"id": "db_overhead_press", "name": "Dumbbell Overhead Press (10kg)", "calories_burned": 90, "muscle_group": "Shoulders", "sets_reps": "4 sets x 10-12 reps"},
            {"id": "db_lateral_raises", "name": "Dumbbell Lateral Raises (10kg)", "calories_burned": 50, "muscle_group": "Side Delts", "sets_reps": "4 sets x 15-20 reps"},
            {"id": "db_tricep_extensions", "name": "Dumbbell Overhead Tricep Extension", "calories_burned": 60, "muscle_group": "Triceps", "sets_reps": "3 sets x 12-15 reps"}
        ]
    },
    "pull": {
        "name": "Pull Day (Home & 10kg Dumbbells)",
        "exercises": [
            {"id": "db_bent_over_rows", "name": "Dumbbell Bent-Over Rows (10kg)", "calories_burned": 95, "muscle_group": "Back & Lats", "sets_reps": "4 sets x 12-15 reps"},
            {"id": "db_single_arm_rows", "name": "Dumbbell Single-Arm Rows (10kg)", "calories_burned": 85, "muscle_group": "Mid Back", "sets_reps": "3 sets x 12 reps"},
            {"id": "db_bicep_curls", "name": "Dumbbell Bicep Curls (10kg)", "calories_burned": 55, "muscle_group": "Biceps", "sets_reps": "3 sets x 12-15 reps"},
            {"id": "db_hammer_curls", "name": "Dumbbell Hammer Curls (10kg)", "calories_burned": 50, "muscle_group": "Biceps", "sets_reps": "3 sets x 12 reps"},
            {"id": "db_rear_delt_flyes", "name": "Dumbbell Rear Delt Flyes (10kg)", "calories_burned": 45, "muscle_group": "Rear Delts", "sets_reps": "3 sets x 15 reps"}
        ]
    },
    "legs": {
        "name": "Legs Day (Home & 10kg Dumbbells)",
        "exercises": [
            {"id": "db_goblet_squats", "name": "Dumbbell Goblet Squats (10kg)", "calories_burned": 120, "muscle_group": "Quads & Glutes", "sets_reps": "4 sets x 15 reps"},
            {"id": "db_romanian_deadlifts", "name": "Dumbbell Romanian Deadlifts", "calories_burned": 110, "muscle_group": "Hamstrings", "sets_reps": "4 sets x 12 reps"},
            {"id": "db_lunges", "name": "Dumbbell Walking Lunges (10kg)", "calories_burned": 100, "muscle_group": "Quads/Hamstrings", "sets_reps": "3 sets x 10 reps/leg"},
            {"id": "bodyweight_glute_bridges", "name": "Bodyweight Glute Bridges", "calories_burned": 60, "muscle_group": "Glutes", "sets_reps": "3 sets x 20 reps"},
            {"id": "standing_calf_raises", "name": "Dumbbell Calf Raises (10kg)", "calories_burned": 40, "muscle_group": "Calves", "sets_reps": "4 sets x 20 reps"}
        ]
    }
}

# Centralized weekly state structure mapping Monday through Sunday separately
USER_STATE = {
    "weight_kg": 62,
    "calorie_goal": 2300,
    "protein_goal": 120,
    "active_day": "monday",
    "weekly_data": {
        "monday": {
            "meals": {
                "breakfast": {"egg": 3, "toast": 2, "milk": 2.5},
                "mid_workout": {"banana": 1, "almonds": 2},
                "lunch": {"paneer": 1.0, "dal": 1.0, "roti": 2},
                "snack": {"whey": 1.0, "curd": 2.0},
                "dinner": {"paneer": 1.5, "rice": 2.0}
            },
            "completed_exercises": []
        },
        "tuesday": {
            "meals": {
                "breakfast": {"egg": 3, "toast": 2, "milk": 2.5},
                "mid_workout": {"banana": 1, "almonds": 2},
                "lunch": {"paneer": 1.0, "dal": 1.0, "roti": 2},
                "snack": {"whey": 1.0, "curd": 2.0},
                "dinner": {"paneer": 1.5, "rice": 2.0}
            },
            "completed_exercises": []
        },
        "wednesday": {
            "meals": {
                "breakfast": {"egg": 3, "toast": 2, "milk": 2.5},
                "mid_workout": {"banana": 1, "almonds": 2},
                "lunch": {"paneer": 1.0, "dal": 1.0, "roti": 2},
                "snack": {"whey": 1.0, "curd": 2.0},
                "dinner": {"paneer": 1.5, "rice": 2.0}
            },
            "completed_exercises": []
        },
        "thursday": {
            "meals": {
                "breakfast": {"egg": 3, "toast": 2, "milk": 2.5},
                "mid_workout": {"banana": 1, "almonds": 2},
                "lunch": {"paneer": 1.0, "dal": 1.0, "roti": 2},
                "snack": {"whey": 1.0, "curd": 2.0},
                "dinner": {"paneer": 1.5, "rice": 2.0}
            },
            "completed_exercises": []
        },
        "friday": {
            "meals": {
                "breakfast": {"egg": 3, "toast": 2, "milk": 2.5},
                "mid_workout": {"banana": 1, "almonds": 2},
                "lunch": {"paneer": 1.0, "dal": 1.0, "roti": 2},
                "snack": {"whey": 1.0, "curd": 2.0},
                "dinner": {"paneer": 1.5, "rice": 2.0}
            },
            "completed_exercises": []
        },
        "saturday": {
            "meals": {
                "breakfast": {"egg": 3, "toast": 2, "milk": 2.5},
                "mid_workout": {"banana": 1, "almonds": 2},
                "lunch": {"paneer": 1.0, "dal": 1.0, "roti": 2},
                "snack": {"whey": 1.0, "curd": 2.0},
                "dinner": {"paneer": 1.5, "rice": 2.0}
            },
            "completed_exercises": []
        },
        "sunday": {
            "meals": {
                "breakfast": {"egg": 3, "toast": 2, "milk": 2.5},
                "mid_workout": {"banana": 1, "almonds": 2},
                "lunch": {"paneer": 1.0, "dal": 1.0, "roti": 2},
                "snack": {"whey": 1.0, "curd": 2.0},
                "dinner": {"paneer": 1.5, "rice": 2.0}
            },
            "completed_exercises": []
        }
    }
}


def calculate_day_totals(day_key):
    """Computes caloric and protein consumption alongside training burn for a specific day."""
    day_state = USER_STATE["weekly_data"].get(day_key)
    if not day_state:
        return {}
        
    consumed_calories = 0
    consumed_protein = 0
    
    # Tally up custom food ingredient selections
    for category, ingredients_dict in day_state["meals"].items():
        for ing_id, qty in ingredients_dict.items():
            ing_info = INGREDIENTS.get(ing_id)
            if ing_info:
                consumed_calories += ing_info["calories"] * qty
                consumed_protein += ing_info["protein"] * qty
                
    # Tally up exercise burned values
    burned_calories = 0
    completed_set = set(day_state["completed_exercises"])
    for day_type, data in EXERCISE_DATABASE.items():
        for ex in data["exercises"]:
            if ex["id"] in completed_set:
                burned_calories += ex["calories_burned"]
                
    remaining_calories = USER_STATE["calorie_goal"] - consumed_calories + burned_calories
    
    return {
        "calorie_goal": USER_STATE["calorie_goal"],
        "protein_goal": USER_STATE["protein_goal"],
        "consumed_calories": int(consumed_calories),
        "consumed_protein": int(consumed_protein),
        "burned_calories": int(burned_calories),
        "remaining_calories": int(remaining_calories),
        "calorie_progress_pct": min(100, int((consumed_calories / USER_STATE["calorie_goal"]) * 100)) if USER_STATE["calorie_goal"] > 0 else 0,
        "protein_progress_pct": min(100, int((consumed_protein / USER_STATE["protein_goal"]) * 100)) if USER_STATE["protein_goal"] > 0 else 0
    }


def calculate_weekly_summary():
    """Aggregates active targets and completions across all 7 calendar days."""
    total_consumed = 0
    total_burned = 0
    total_protein = 0
    total_days_active = 0
    
    daily_status = {}
    
    for day_key in USER_STATE["weekly_data"]:
        day_totals = calculate_day_totals(day_key)
        total_consumed += day_totals["consumed_calories"]
        total_burned += day_totals["burned_calories"]
        total_protein += day_totals["consumed_protein"]
        
        # Mark day active if user logged a workout
        day_state = USER_STATE["weekly_data"][day_key]
        if len(day_state["completed_exercises"]) > 0:
            total_days_active += 1
            
        daily_status[day_key] = {
            "consumed": day_totals["consumed_calories"],
            "burned": day_totals["burned_calories"],
            "remaining": day_totals["remaining_calories"],
            "has_workout": len(day_state["completed_exercises"]) > 0
        }
        
    avg_protein = int(total_protein / 7)
    
    return {
        "total_consumed": total_consumed,
        "total_burned": total_burned,
        "avg_daily_protein": avg_protein,
        "active_training_days": total_days_active,
        "daily_status": daily_status
    }


@app.route("/", methods=["GET"])
def index(request):
    """Serves the primary Single-Page dashboard containing the full application databases and default states."""
    # Build complete state object to serialize to the page script tag
    initial_payload = {
        "ingredients": INGREDIENTS,
        "meal_ingredients": MEAL_INGREDIENTS,
        "exercises": EXERCISE_DATABASE,
        "state": USER_STATE
    }
    
    rendered_html = render_template("index.html", INITIAL_DATA=json.dumps(initial_payload))
    return Response(rendered_html, 200, "text/html")


@app.route("/api/update_state", methods=["POST"])
def update_state(request):
    """
    Handles asynchronous modification requests from the frontend SPA.
    Toggles completed exercises, adapts custom ingredient counts, modifies active days, and returns recalculated totals.
    """
    payload = request.json
    request_type = payload.get("type")
    
    # 1. Day Switching controller
    if request_type == "change_day":
        day = payload.get("day")
        if day in USER_STATE["weekly_data"]:
            USER_STATE["active_day"] = day
            
    # 2. Food ingredient increment/decrement controller
    elif request_type == "food_qty":
        day = USER_STATE["active_day"]
        category = payload.get("category")
        ingredient_id = payload.get("ingredient_id")
        action = payload.get("action")  # "inc" or "dec"
        
        day_meals = USER_STATE["weekly_data"][day]["meals"]
        if category in day_meals:
            # Initialize ingredient count if not present
            if ingredient_id not in day_meals[category]:
                day_meals[category][ingredient_id] = 0.0
                
            qty = day_meals[category][ingredient_id]
            
            # Standard adjustments depending on the ingredient type
            step = 0.5 if ingredient_id in ["milk", "paneer", "rice", "chicken", "curd", "soya", "sprouts"] else 1.0
            
            if action == "inc":
                day_meals[category][ingredient_id] += step
            elif action == "dec":
                day_meals[category][ingredient_id] = max(0.0, qty - step)
                # Cleanup if count returns to 0 to keep payload slim
                if day_meals[category][ingredient_id] == 0.0:
                    day_meals[category].pop(ingredient_id, None)
                    
    # 3. Exercise completion checkbox controller
    elif request_type == "exercise_completion":
        day = USER_STATE["active_day"]
        exercise_id = payload.get("exercise_id")
        completed = payload.get("completed", False)
        
        day_state = USER_STATE["weekly_data"][day]
        
        # Verify the exercise belongs in our database
        exercise_exists = False
        for day_type, data in EXERCISE_DATABASE.items():
            if any(ex["id"] == exercise_id for ex in data["exercises"]):
                exercise_exists = True
                break
                
        if exercise_exists:
            if completed:
                if exercise_id not in day_state["completed_exercises"]:
                    day_state["completed_exercises"].append(exercise_id)
            else:
                if exercise_id in day_state["completed_exercises"]:
                    day_state["completed_exercises"].remove(exercise_id)
                    
    # Compile response totals
    active_day = USER_STATE["active_day"]
    totals = calculate_day_totals(active_day)
    weekly = calculate_weekly_summary()
    
    response_data = {
        "status": "success",
        "state": USER_STATE,
        "totals": totals,
        "weekly": weekly
    }
    
    return Response(json.dumps(response_data), 200, "application/json")


@app.route("/manifest.json", methods=["GET"])
def manifest(request):
    """Serves the PWA manifest metadata file."""
    try:
        with open("manifest.json", "r", encoding="utf-8") as f:
            return Response(f.read(), 200, "application/json")
    except Exception as e:
        return Response(f"Error: {str(e)}", 500, "text/plain")


@app.route("/service-worker.js", methods=["GET"])
def service_worker(request):
    """Serves the service worker caching script."""
    try:
        with open("service-worker.js", "r", encoding="utf-8") as f:
            return Response(f.read(), 200, "application/javascript")
    except Exception as e:
        return Response(f"Error: {str(e)}", 500, "text/plain")


@app.route("/icons/icon-192.png", methods=["GET"])
def icon_192(request):
    """Serves the 192x192 app launcher icon."""
    try:
        with open("icons/icon-192.png", "rb") as f:
            return Response(f.read(), 200, "image/png")
    except Exception as e:
        return Response(f"Error: {str(e)}", 500, "text/plain")


@app.route("/icons/icon-512.png", methods=["GET"])
def icon_512(request):
    """Serves the 512x512 app launcher icon."""
    try:
        with open("icons/icon-512.png", "rb") as f:
            return Response(f.read(), 200, "image/png")
    except Exception as e:
        return Response(f"Error: {str(e)}", 500, "text/plain")


if __name__ == "__main__":
    # Start server locally
    app.run(host="127.0.0.1", port=8000)
