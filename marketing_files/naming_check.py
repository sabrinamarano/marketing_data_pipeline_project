"""
Simple naming-convention data-quality check.
Checks campaign_name, adset_name, ad_name against the rules.
If any don't follow the convention -> send an alert.
"""
from extract_names import (
    extract_campaign, extract_adset, extract_ad, NamingConventionError,
)


def check_names(campaign_name, adset_name, ad_name):
    """Check all three names. Return list of problems (empty = all good)."""
    problems = []
    for label, fn, name in [
        ("campaign_name", extract_campaign, campaign_name),
        ("adset_name",    extract_adset,    adset_name),
        ("ad_name",       extract_ad,       ad_name),
    ]:
        try:
            fn(name)
        except NamingConventionError as e:
            problems.append(f"{label}: {e}")
    return problems


def send_alert(problems):
    print("🚨 NAMING CONVENTION ALERT:")
    for p in problems:
        print(f"   - {p}")


if __name__ == "__main__":
    # good set -> no alert
    problems = check_names(
        "IT_HolidayGifting_Awareness",
        "IT_HolidayGifting_GiftShoppers_Feed",
        "IT_HolidayGifting_Video_v1",
    )
    print("Good set:", "OK" if not problems else "issues")

    # bad set -> alert
    problems = check_names(
        "ita_HolidayGifting_Awareness",       # bad country
        "IT_HolidayGifting_Broad",            # missing placement
        "IT_HolidayGifting_Video_final",      # bad version
    )
    if problems:
        send_alert(problems)
