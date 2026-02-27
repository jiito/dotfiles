---
name: traderjoes-price-tracker
description: Real-time Trader Joe's price tracking and product search. Provides ingredient cost calculation for meal planning, product search by name, SKU lookup, and budget analysis. Integrates seamlessly with meal planning workflows to add cost awareness to food planning. Use when the user needs Trader Joe's prices, wants to calculate meal costs, compare recipe prices, or find budget alternatives for ingredients.
---

# Trader Joe's Price Tracker

Real-time product search and price tracking for Trader Joe's. Automatically handles session management and provides cost calculations perfect for meal planning integration.

## Core Functions

Execute commands in the traderjoes directory:

```bash
cd /Users/bjar/git/traderjoes
python3 traderjoes.py [command] [options]
```

### Search Products
```bash
python3 traderjoes.py search "chicken breast"
python3 traderjoes.py search "organic quinoa" --store 226
```
**Use for:** Finding ingredients for meal plans, discovering product options

### Calculate Meal Costs
Use the Python skill module for cost calculations:
```python
cd /Users/bjar/git/traderjoes
python3 -c "
from traderjoes import TraderJoesAPI
api = TraderJoesAPI()

# Search and calculate costs for ingredients
ingredients = ['chicken breast', 'quinoa', 'broccoli']
total_cost = 0
breakdown = []

for ingredient in ingredients:
    products = api.search_products('226', ingredient)
    if products:
        # Get cheapest option
        cheapest = min(products.get('data', {}).get('products', {}).get('items', []),
                      key=lambda x: float(x.get('retail_price', 999)), default={})
        if cheapest:
            price = float(cheapest.get('retail_price', 0))
            total_cost += price
            breakdown.append({'ingredient': ingredient, 'product': cheapest.get('item_title', ''), 'price': price})

print(f'Total cost: ${total_cost:.2f}')
for item in breakdown:
    print(f'  {item[\"ingredient\"]}: {item[\"product\"]} - ${item[\"price\"]}')
"
```

### Lookup Specific Products
```bash
python3 traderjoes.py lookup 073814 077316 060411
```
**Use for:** Getting specific product details by SKU

### Fetch Store Data (for local database)
```bash
python3 traderjoes.py fetch --stores 226
```
**Use for:** Building local price database for offline queries

## Integration Examples

### Meal Plan Cost Analysis
```bash
cd /Users/bjar/git/traderjoes
python3 -c "
# Calculate costs for weekly meal plan
meal_plans = [
    ['chicken breast', 'quinoa', 'broccoli'],
    ['salmon', 'sweet potato', 'spinach'],
    ['eggs', 'avocado', 'bell peppers']
]

weekly_total = 0
for day, ingredients in enumerate(meal_plans, 1):
    # Search for each ingredient and get cheapest option
    day_cost = 0
    print(f'Day {day}:')
    for ingredient in ingredients:
        import subprocess
        result = subprocess.run(['python3', 'traderjoes.py', 'search', ingredient],
                              capture_output=True, text=True)
        if 'Found' in result.stdout and '- $' in result.stdout:
            # Extract price from first result
            lines = result.stdout.strip().split('\n')
            for line in lines:
                if '- $' in line:
                    price_str = line.split('- $')[1].strip()
                    try:
                        price = float(price_str)
                        day_cost += price
                        print(f'  {ingredient}: ${price}')
                        break
                    except:
                        pass

    weekly_total += day_cost
    print(f'Day {day} total: ${day_cost:.2f}\n')

print(f'Weekly meal plan total: ${weekly_total:.2f}')
"
```

### Budget Recipe Comparison
```bash
cd /Users/bjar/git/traderjoes
python3 -c "
recipes = {
    'Pasta Dinner': ['ground beef', 'pasta', 'tomato sauce'],
    'Healthy Bowl': ['quinoa', 'black beans', 'avocado'],
    'Quick Stir-fry': ['tofu', 'brown rice', 'mixed vegetables']
}

print('Recipe Cost Comparison:')
for recipe_name, ingredients in recipes.items():
    total = 0
    for ingredient in ingredients:
        import subprocess
        result = subprocess.run(['python3', 'traderjoes.py', 'search', ingredient],
                              capture_output=True, text=True)
        if 'Found' in result.stdout and '- $' in result.stdout:
            lines = result.stdout.strip().split('\n')
            for line in lines:
                if '- $' in line:
                    price_str = line.split('- $')[1].strip()
                    try:
                        price = float(price_str)
                        total += price
                        break
                    except:
                        pass
    print(f'{recipe_name}: ${total:.2f}')
"
```

### Shopping List with Prices
```bash
cd /Users/bjar/git/traderjoes
python3 -c "
shopping_list = ['chicken breast', 'quinoa', 'broccoli', 'avocado', 'eggs']
total_budget = 0

print('Shopping List with Trader Joe\'s Prices:')
for item in shopping_list:
    import subprocess
    result = subprocess.run(['python3', 'traderjoes.py', 'search', item],
                          capture_output=True, text=True)

    if 'Found' in result.stdout and '- $' in result.stdout:
        lines = result.stdout.strip().split('\n')
        for line in lines:
            if '- $' in line:
                price_str = line.split('- $')[1].strip()
                product_name = line.split(' - $')[0].strip().split(': ', 1)[1] if ': ' in line else item
                try:
                    price = float(price_str)
                    total_budget += price
                    print(f'- {product_name}: ${price}')
                    break
                except:
                    print(f'- {item}: Price unavailable')
                    break
    else:
        print(f'- {item}: Not found')

print(f'\nTotal estimated budget: ${total_budget:.2f}')
"
```

## Store Codes

- **226**: Default store (works reliably across regions)
- **701**: Chicago South Loop
- **31**: Los Angeles
- **546**: NYC East Village
- **452**: Austin Seaholm

## Features

- **Smart Cookie Management**: Automatically handles session cookies with Selenium fallback
- **Real-time Prices**: Live data from Trader Joe's GraphQL API
- **Local Database**: SQLite storage for price history and offline queries
- **Error Resilience**: Graceful handling of API failures and network issues
- **Multi-store Support**: Query different store locations

## Integration with Other Skills

**Perfect for composing with:**
- **meal-planner**: Add real-time cost analysis to meal plans
- **shopping-list**: Generate price-aware shopping lists
- **budget-tracker**: Track food expenses with actual prices
- **recipe-manager**: Calculate cost-per-serving for recipes

## Dependencies

The tool automatically installs dependencies, but you can manually install:
```bash
cd /Users/bjar/git/traderjoes
pip3 install requests selenium webdriver-manager
```

## Environment Variables

Optional configuration:
```bash
export TJ_AFFINITY_COOKIE="custom_cookie_value"  # Override default session cookie
```

## Error Handling

The skill provides robust error handling:
- Automatic cookie refresh on 403 errors
- Fallback to cached prices when API unavailable
- Graceful degradation for missing products
- Retry logic for network failures

All functions return structured data that's easy to parse and integrate into other workflows.