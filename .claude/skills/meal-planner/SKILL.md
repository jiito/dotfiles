---
name: meal-planner
description: Automated weekly low-carb vegetarian meal planning workflow with calendar integration, recipe research, grocery list generation, and Things integration. Use when the user requests meal planning, asks to "run my weekly meal plan", wants a grocery list for the week, or needs help planning low-carb vegetarian meals.
---

# Weekly Low-Carb Vegetarian Meal Planner

Autonomous workflow for creating weekly meal plans with calendar integration, recipe research, and grocery list generation.

## User Profile

**Dietary Information:**
- Diet: Flexitarian (plant-based + eggs, dairy, fish)
- Approach: Mindful low-carb (not strict keto)
- Exercise: High volume cardio (moderate carb adjustments on workout days)
- Current meals handled separately: Greek yogurt or eggs (breakfast), tuna salad (lunch)

**Preferences:**
- Prioritizes time savings over elaborate cooking
- Quick meals and easy cleanup
- Meal prep strategies welcomed
- Budget-friendly options
- Cooking for one person

**Goals:**
- Low-carb vegetarian (moderate, not strict)
- Quick prep and minimal cleanup
- Healthy, filling meals
- Variety in snacks

## Workflow Execution

Execute all steps autonomously without follow-up questions. Make reasonable assumptions based on the user profile.

### Step 1: Calendar Analysis

**Required calls:**
1. `things-dev:get_todos` with `include_items: true`
2. Find calendars using appropriate calendar tool
3. Get events for current week (Monday 00:00 to Sunday 23:59 Pacific timezone)

**Actions:**
- Identify existing meal times (cooking blocks, meal names, dinner plans)
- Note workout schedule (but do NOT over-optimize for workout days)
- Identify busy vs. flexible days
- Map days/meals needing planning

**Do NOT ask about the schedule.**

### Step 2: Research Low-Carb Vegetarian Meals

**Required searches:**
1. `web_search`: "low carb vegetarian meals quick easy"
2. `web_search`: "low carb vegetarian tofu eggs cheese recipes"
3. `web_search`: "healthy low carb vegetarian snacks"

**Research 15-20 meal options focusing on:**
- Proteins: eggs, tofu, cheese, vegetables, healthy fats
- Priorities: quick prep (<30 min), minimal cleanup, simple ingredients
- Avoid: elaborate recipes, uncommon ingredients, long cook times

**Scoring criteria:**

Ease Score (1-10):
- 10 = No cooking (salads, wraps)
- 8-9 = One pan, <15 minutes
- 7 = Simple cooking, <30 minutes
- <7 = Longer or more complex

Health Score (1-10):
- 9-10 = High protein, lots of vegetables, healthy fats, <15g carbs
- 8 = Good protein, vegetables, moderate carbs (15-25g)
- 7 = Adequate nutrition, higher carbs (25-40g)

### Step 3: Create Weekly Meal Plan

**Format:**

```markdown
# Weekly Low-Carb Vegetarian Meal Plan
**Week of [Date Range]**

## Meals Overview

### [DAY OF WEEK, DATE]
**Lunch:** [Meal Name]
- [Brief ingredient list]
- [Key prep notes]
- **Ease: X/10 | Health: X/10**

**Dinner:** [Meal Name]
- [Brief ingredient list]
- [Key prep notes]
- **Ease: X/10 | Health: X/10**

[Repeat for each day]

---

## Healthy Snacks (Keep on Hand)
- **[Snack item]** ([portion guidance])
[List 8-12 options]

---

## Meal Prep Tips
1. **[Tip 1]**
2. **[Tip 2]**
[5-8 actionable tips]
```

**Requirements:**
- Only plan meals for days/times NOT covered in calendar
- Mix: 50% super quick, 30% medium effort, 20% batch-cook friendly
- Variety in protein sources
- 10-12 snack options
- 5-8 time-saving prep tips
- No confirmation requests or preference questions

### Step 4: Generate Grocery List

**Format:**

```markdown
# Grocery List - Low-Carb Vegetarian Meal Plan
**Week of [Date Range]**

## PRODUCE
### Vegetables
- [ ] [Item] ([quantity/size])

### Fruits
- [ ] [Item] ([quantity/size])

---

## PROTEIN
### Eggs & Dairy
- [ ] [Item] ([quantity/size])

### Plant-Based Protein
- [ ] [Item] ([quantity/size])

---

## PANTRY STAPLES
### Oils & Vinegars
- [ ] [Item]

### Nuts & Seeds
- [ ] [Item] ([quantity/size])

### Condiments & Sauces
- [ ] [Item] ([quantity/size])

### Spices & Seasonings
- [ ] [Item]

---

## FROZEN (Optional convenience items)
- [ ] [Item] ([quantity/size])

---

## SHOPPING TIPS
[5-6 practical tips]
```

**Requirements:**
- All items with checkboxes `- [ ]`
- Specific quantities (e.g., "2 heads", "1 lb", "16 oz")
- Organized by department
- Include cost estimate ranges
- Note items that may already be owned
- Suggest budget-friendly alternatives

### Step 5: Save and Present Files

**Actions:**
1. Create `meal_plan.md` in `/home/claude/`
2. Create `grocery_list.md` in `/home/claude/`
3. Copy both to `/mnt/user-data/outputs/`
4. Present both files

### Step 6: Add to Things

**Attempt (max 2 tries):**

Option A - Add individual items:
```
things-dev:add_todo for each major grocery category
{
  "title": "Buy [category items]",
  "tags": ["groceries", "meal-prep"]
}
```

Option B - Single todo:
```
things-dev:add_todo
{
  "title": "Buy groceries for low-carb meal plan - see documents",
  "notes": "[Summary of key items]\n\nFull list in meal plan documents",
  "tags": ["groceries", "meal-prep"]
}
```

**If connector fails:** Acknowledge gracefully, note user can add manually.

## Output Format

**Final message:**

```
I've created your meal plan for [date range].

**What's Included:**
- [X] meals planned (filling gaps in calendar)
- [X] healthy snack options
- Complete grocery list organized by department
- Estimated cost: $XX-XX

**Meal Highlights:**
- [1-2 sentence summary of variety]
- Average ease score: X/10
- All meals under 30 minutes prep

[Present files]

[If Things failed: "Note: I encountered an issue with the Things connector. You can copy items from the grocery list document into Things manually."]
```

## Error Handling

**Calendar access issues:**
- Plan 7 lunches + 7 dinners
- Assume weekdays busier than weekends

**Things connector issues:**
- Expected behavior: may fail
- Solution: acknowledge, suggest manual entry
- Do not troubleshoot extensively

**Research issues:**
- Use built-in knowledge of low-carb vegetarian meals
- Ensure variety: salads, egg dishes, tofu, vegetable-based

## Communication Guidelines

**Tone:**
- Concise and direct
- No excessive explanations
- Present completed work, not process descriptions
- Skip pleasantries and filler

**Do NOT:**
- Ask follow-up questions about preferences
- Ask for confirmation of meal choices
- Explain research process
- Over-describe meals
- Apologize for limitations
- Ask about missing information

**DO:**
- Execute workflow completely and autonomously
- Make smart assumptions based on profile
- Prioritize time-saving and simplicity
- Provide actionable, complete deliverables
- Focus on practical, budget-friendly options
- Keep communication brief and results-focused
