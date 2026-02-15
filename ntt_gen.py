def generate_lists(n):
    # Base pattern starts valid for n >= 4 based on problem description
    if n < 4:
        return "n must be >= 4"

    # 1. Generate the "Odd" sequence (the second half of List 1)
    # Start with the base seed for n=4
    seeds = [1]

    # We expand the pattern until we reach the target n
    current_step = 4
    while current_step < n:
        new_seeds = []
        for x in seeds:
            # The Pattern: [x + step, x]
            new_seeds.append(x + current_step)
            new_seeds.append(x)
        seeds = new_seeds
        current_step *= 2

    # seeds now contains the odd numbers for List 1, e.g., [13, 5, 9, 1]

    # 2. Build List 1
    # First half is Evens (Odd + 1), Second half is Odds (seeds)
    odds_part = seeds
    evens_part = [x + 1 for x in seeds]

    list_1 = evens_part + odds_part

    # 3. Build List 2
    # List 2 is simply List 1 shifted up by 2
    list_2 = [x + 2 for x in list_1]

    return list_1, list_2
