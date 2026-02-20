#!/usr/bin/env python3
"""Calculate expected monthly Claude Code costs for a developer team.

Usage:
    python3 cost-calculator.py
    python3 cost-calculator.py --developers 100 --model sonnet
"""

import argparse
import json
import sys

# Pricing per million tokens (as of 2026-02)
PRICING = {
    "opus": {
        "input": 5.00,
        "cache_read": 0.50,
        "output": 25.00,
    },
    "sonnet": {
        "input": 3.00,
        "cache_read": 0.30,
        "output": 15.00,
    },
    "haiku": {
        "input": 1.00,
        "cache_read": 0.10,
        "output": 5.00,
    },
}

# Usage pattern assumptions
DEFAULT_PATTERNS = {
    "heavy": {
        "percentage": 0.20,
        "sessions_per_day": 8,
        "turns_per_session": 25,
        "input_tokens_per_turn": 4000,
        "output_tokens_per_turn": 2000,
        "cache_hit_rate": 0.85,
    },
    "moderate": {
        "percentage": 0.50,
        "sessions_per_day": 4,
        "turns_per_session": 15,
        "input_tokens_per_turn": 3000,
        "output_tokens_per_turn": 1500,
        "cache_hit_rate": 0.80,
    },
    "light": {
        "percentage": 0.30,
        "sessions_per_day": 2,
        "turns_per_session": 8,
        "input_tokens_per_turn": 2500,
        "output_tokens_per_turn": 1000,
        "cache_hit_rate": 0.75,
    },
}

WORKING_DAYS_PER_MONTH = 22


def calculate_cost(developers, model, patterns=None):
    if patterns is None:
        patterns = DEFAULT_PATTERNS

    prices = PRICING[model]
    results = {"model": model, "developers": developers, "tiers": {}}
    total_monthly = 0.0
    total_tokens = {"input": 0, "cached": 0, "output": 0}

    for tier_name, tier in patterns.items():
        tier_devs = developers * tier["percentage"]
        daily_turns = tier["sessions_per_day"] * tier["turns_per_session"]
        monthly_turns = daily_turns * WORKING_DAYS_PER_MONTH

        input_tokens = monthly_turns * tier["input_tokens_per_turn"]
        cached_tokens = input_tokens * tier["cache_hit_rate"]
        uncached_tokens = input_tokens - cached_tokens
        output_tokens = monthly_turns * tier["output_tokens_per_turn"]

        input_cost = (uncached_tokens / 1_000_000) * prices["input"]
        cache_cost = (cached_tokens / 1_000_000) * prices["cache_read"]
        output_cost = (output_tokens / 1_000_000) * prices["output"]
        per_dev_monthly = input_cost + cache_cost + output_cost
        tier_monthly = per_dev_monthly * tier_devs

        results["tiers"][tier_name] = {
            "developers": tier_devs,
            "monthly_turns_per_dev": monthly_turns,
            "per_dev_monthly": round(per_dev_monthly, 2),
            "tier_monthly": round(tier_monthly, 2),
        }

        total_monthly += tier_monthly
        total_tokens["input"] += uncached_tokens * tier_devs
        total_tokens["cached"] += cached_tokens * tier_devs
        total_tokens["output"] += output_tokens * tier_devs

    results["total_monthly"] = round(total_monthly, 2)
    results["per_dev_average"] = round(total_monthly / developers, 2)
    results["total_tokens_millions"] = {
        "input": round(total_tokens["input"] / 1_000_000, 1),
        "cached": round(total_tokens["cached"] / 1_000_000, 1),
        "output": round(total_tokens["output"] / 1_000_000, 1),
    }

    return results


def format_report(results):
    lines = []
    lines.append(f"{'=' * 60}")
    lines.append(f"Claude Code Cost Estimate")
    lines.append(f"{'=' * 60}")
    lines.append(f"Model: {results['model'].title()}")
    lines.append(f"Developers: {results['developers']}")
    lines.append(f"Working days/month: {WORKING_DAYS_PER_MONTH}")
    lines.append("")

    lines.append(f"{'Tier':<12} {'Devs':>6} {'Turns/mo':>10} {'$/dev/mo':>10} {'Tier total':>12}")
    lines.append(f"{'-' * 52}")

    for tier_name, tier in results["tiers"].items():
        lines.append(
            f"{tier_name:<12} {tier['developers']:>6.0f} "
            f"{tier['monthly_turns_per_dev']:>10,} "
            f"${tier['per_dev_monthly']:>9,.2f} "
            f"${tier['tier_monthly']:>11,.2f}"
        )

    lines.append(f"{'-' * 52}")
    lines.append(f"{'TOTAL':<12} {results['developers']:>6} {'':>10} "
                 f"${results['per_dev_average']:>9,.2f} "
                 f"${results['total_monthly']:>11,.2f}")
    lines.append("")
    lines.append(f"Token volume (millions/month):")
    tokens = results["total_tokens_millions"]
    lines.append(f"  Input (uncached): {tokens['input']:,.1f}M")
    lines.append(f"  Input (cached):   {tokens['cached']:,.1f}M")
    lines.append(f"  Output:           {tokens['output']:,.1f}M")
    lines.append(f"{'=' * 60}")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Claude Code cost calculator")
    parser.add_argument("--developers", type=int, default=50, help="Number of developers")
    parser.add_argument("--model", choices=PRICING.keys(), default="sonnet", help="Model to use")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    args = parser.parse_args()

    results = calculate_cost(args.developers, args.model)

    if args.json:
        print(json.dumps(results, indent=2))
    else:
        print(format_report(results))


if __name__ == "__main__":
    main()
