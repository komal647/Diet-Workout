import sys
import json
from app import app, USER_STATE, INGREDIENTS, calculate_day_totals, calculate_weekly_summary

# A helper to simulate WSGI start_response
def mock_start_response(status, headers):
    mock_start_response.status = status
    mock_start_response.headers = headers

def run_test_suite():
    print("=" * 60)
    print("STARTING EXTENDED FITNESS & DIET TRACKER TEST SUITE")
    print("=" * 60)

    # -------------------------------------------------------------
    # 1. Test WSGI Compatibility (Vercel Serverless Function Check)
    # -------------------------------------------------------------
    print("Test 1: Verifying WSGI compliance for Vercel deployment...")
    environ = {
        "REQUEST_METHOD": "GET",
        "PATH_INFO": "/",
        "QUERY_STRING": "",
        "wsgi.input": sys.stdin,
        "CONTENT_LENGTH": "0"
    }
    
    mock_start_response.status = None
    mock_start_response.headers = None
    
    # Execute as a standard WSGI app
    response_body = app(environ, mock_start_response)
    
    print(f"  WSGI Status: {mock_start_response.status}")
    assert mock_start_response.status == "200 OK", "WSGI application failed to respond with 200 OK."
    assert len(response_body) > 0, "WSGI application returned empty body."
    
    html_content = response_body[0].decode("utf-8")
    assert "AntiGravity | Elite Home Fitness Tracker" in html_content, "Dashboard title missing from rendered template."
    print("[OK] WSGI compliance and Vercel compatibility verified!")

    # -------------------------------------------------------------
    # 2. Reset and Assert Daily Defaults
    # -------------------------------------------------------------
    print("\nTest 2: Asserting default day totals (Monday baseline)...")
    USER_STATE["active_day"] = "monday"
    for day in USER_STATE["weekly_data"]:
        USER_STATE["weekly_data"][day]["meals"] = {
            "breakfast": {"egg": 3, "toast": 2, "milk": 2.5},
            "mid_workout": {"banana": 1, "almonds": 2},
            "lunch": {"paneer": 1.0, "dal": 1.0, "roti": 2},
            "snack": {"whey": 1.0, "curd": 2.0},
            "dinner": {"paneer": 1.5, "rice": 2.0}
        }
        USER_STATE["weekly_data"][day]["completed_exercises"] = []

    # Calculate Monday Totals
    # Breakfast: 3*70(210) + 2*70(140) + 2.5*50(125) = 475 kcal
    # Mid-Workout: 1*90(90) + 2*70(140) = 230 kcal
    # Lunch: 1*300(300) + 1*120(120) + 2*120(240) = 660 kcal
    # Snack: 1*130(130) + 2*60(120) = 250 kcal
    # Dinner: 1.5*300(450) + 2*110(220) = 670 kcal
    # Total consumed calories: 475 + 230 + 660 + 250 + 670 = 2285 kcal
    # Protein:
    # Breakfast: 3*6(18) + 2*3(6) + 2.5*3(7.5) = 31.5g
    # Mid-Workout: 1*1(1) + 2*2(4) = 5g
    # Lunch: 1*18(18) + 1*8(8) + 2*4(8) = 34g
    # Snack: 1*24(24) + 2*4(8) = 32g
    # Dinner: 1.5*18(27) + 2*3(6) = 33g
    # Total consumed protein: 31.5 + 5 + 34 + 32 + 33 = 135.5g -> Int = 135g
    
    totals = calculate_day_totals("monday")
    print(f"  Consumed Calories: {totals['consumed_calories']} kcal (Expected: 2285)")
    print(f"  Consumed Protein: {totals['consumed_protein']}g (Expected: 135g)")
    print(f"  Caloric Burn: {totals['burned_calories']} kcal (Expected: 0)")
    print(f"  Remaining Calories: {totals['remaining_calories']} kcal (Expected: 15)")
    
    assert totals["consumed_calories"] == 2285, "Consumed calories mismatch."
    assert totals["consumed_protein"] == 135, "Consumed protein mismatch."
    assert totals["burned_calories"] == 0, "Caloric burn mismatch."
    assert totals["remaining_calories"] == 15, "Remaining calories mismatch."
    print("[OK] Baseline day totals verified!")

    # -------------------------------------------------------------
    # 3. Test Custom Ingredient Calorie Modifiers
    # -------------------------------------------------------------
    print("\nTest 3: Testing custom ingredient adjustments...")
    # Add 2 more eggs (qty increases from 3 to 5)
    # Calories increases by 2 * 70 = 140 kcal. New: 2285 + 140 = 2425 kcal
    # Protein increases by 2 * 6 = 12g. New: 135 + 12 = 147g
    USER_STATE["weekly_data"]["monday"]["meals"]["breakfast"]["egg"] = 5
    
    totals = calculate_day_totals("monday")
    print(f"  Updated Calories: {totals['consumed_calories']} kcal (Expected: 2425)")
    print(f"  Updated Protein: {totals['consumed_protein']}g (Expected: 147g)")
    print(f"  Updated Remaining Pool: {totals['remaining_calories']} kcal (Expected: -125)")
    
    assert totals["consumed_calories"] == 2425, "Adjusted calories mismatch."
    assert totals["consumed_protein"] == 147, "Adjusted protein mismatch."
    assert totals["remaining_calories"] == -125, "Adjusted remaining pool mismatch."
    print("[OK] Customizable food calculations verified!")

    # -------------------------------------------------------------
    # 4. Test Home Training splits (10kg dumbbell work)
    # -------------------------------------------------------------
    print("\nTest 4: Verifying 10kg dumbbell exercise logging...")
    # Log Goblet Squats (+120 kcal) and Bodyweight Pushups (+80 kcal) on Monday
    # Total burn: 120 + 80 = 200 kcal.
    # Remaining: Goal (2300) - Consumed (2425) + Burned (200) = 75 kcal
    USER_STATE["weekly_data"]["monday"]["completed_exercises"].append("db_goblet_squats")
    USER_STATE["weekly_data"]["monday"]["completed_exercises"].append("pushups")
    
    totals = calculate_day_totals("monday")
    print(f"  Burned Calories: {totals['burned_calories']} kcal (Expected: 200)")
    print(f"  New Remaining Pool: {totals['remaining_calories']} kcal (Expected: 75)")
    
    assert totals["burned_calories"] == 200, "Workout burned calories mismatch."
    assert totals["remaining_calories"] == 75, "Remaining pool caloric recalculation mismatch."
    print("[OK] Dumbbell home exercise calculations verified!")

    # -------------------------------------------------------------
    # 5. Test Weekly Accumulation summaries
    # -------------------------------------------------------------
    print("\nTest 5: Verifying weekly performance summaries...")
    weekly = calculate_weekly_summary()
    # Monday has workout (1 active day)
    # Let's add a workout to Wednesday to verify active consistency counts
    USER_STATE["weekly_data"]["wednesday"]["completed_exercises"].append("db_bicep_curls")
    
    weekly = calculate_weekly_summary()
    print(f"  Active Training Days: {weekly['active_training_days']} (Expected: 2)")
    print(f"  Weekly Calories Consumed: {weekly['total_consumed']} kcal")
    print(f"  Weekly Calories Burned: {weekly['total_burned']} kcal")
    
    assert weekly["active_training_days"] == 2, "Weekly active consistency mismatch."
    assert weekly["total_burned"] == 255, "Weekly burned sum mismatch." # 200 on Mon + 55 on Wed = 255
    print("[OK] Weekly performance aggregation verified!")

    print("\n" + "=" * 60)
    print("ALL EXTENDED SUITE CASES PASSED SUCCESSFULLY!")
    print("=" * 60)
    return True

if __name__ == "__main__":
    try:
        success = run_test_suite()
        sys.exit(0 if success else 1)
    except AssertionError as err:
        print(f"\n[FAIL] Assertion failed: {str(err)}")
        sys.exit(1)
    except Exception as e:
        print(f"\n[ERROR] Unexpected error: {str(e)}")
        sys.exit(1)
