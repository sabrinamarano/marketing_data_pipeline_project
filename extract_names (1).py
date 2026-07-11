"""
Extractor for conformant campaign / adset / ad names.
Names follow the convention: fields joined by '_' in a fixed order,
using only approved vocabulary values.

    CAMPAIGN : country_campaign_objective
    ADSET    : country_campaign_audience_placement
    AD       : country_campaign_creative_version

Raises NamingConventionError when a rule is broken (wrong number of
fields, or a value outside the approved vocabulary).
"""

# ---- approved values (from CAMPAIGN_NAMING_CONVENTION.md) ----
COUNTRIES  = {"IT", "DE"}
CAMPAIGNS  = {"AutumnBrandPush", "HolidayGifting", "AlwaysOnSales"}
OBJECTIVES = {"Awareness", "Conversion"}
AUDIENCES  = {"Broad", "GiftShoppers", "Retargeting"}
PLACEMENTS = {"Feed", "Stories", "Reels", "Auto", "Manual"}
CREATIVES  = {"Image", "Video", "Carousel", "Static", "Html5", "Spark"}


class NamingConventionError(ValueError):
    """raised when a name does not follow the naming convention."""


def _check(value, allowed, field):
    if value not in allowed:
        raise NamingConventionError(
            f"'{value}' is not a valid {field} "
            f"(allowed: {', '.join(sorted(allowed))})"
        )
    return value


def _check_version(value):
    if not (len(value) >= 2 and value[0] == "v" and value[1:].isdigit()):
        raise NamingConventionError(
            f"'{value}' is not a valid version (expected v1, v2, v3, …)"
        )
    return value


def _split(name, n_fields, field_order):
    parts = name.split("_")
    if len(parts) != n_fields:
        raise NamingConventionError(
            f"'{name}': expected {n_fields} fields ({field_order}), "
            f"got {len(parts)}"
        )
    return parts


def extract_campaign(name):
    country, campaign, objective = _split(name, 3, "country_campaign_objective")
    return {
        "country":   _check(country,   COUNTRIES,  "country"),
        "campaign":  _check(campaign,  CAMPAIGNS,  "campaign"),
        "objective": _check(objective, OBJECTIVES, "objective"),
    }


def extract_adset(name):
    country, campaign, audience, placement = _split(
        name, 4, "country_campaign_audience_placement")
    return {
        "country":   _check(country,   COUNTRIES,  "country"),
        "campaign":  _check(campaign,  CAMPAIGNS,  "campaign"),
        "audience":  _check(audience,  AUDIENCES,  "audience"),
        "placement": _check(placement, PLACEMENTS, "placement"),
    }


def extract_ad(name):
    country, campaign, creative, version = _split(
        name, 4, "country_campaign_creative_version")
    return {
        "country":  _check(country,  COUNTRIES, "country"),
        "campaign": _check(campaign, CAMPAIGNS, "campaign"),
        "creative": _check(creative, CREATIVES, "creative"),
        "version":  _check_version(version),
    }


if __name__ == "__main__":
    print("=== valid names ===")
    print(extract_campaign("IT_HolidayGifting_Awareness"))
    print(extract_adset("IT_HolidayGifting_GiftShoppers_Stories"))
    print(extract_ad("IT_HolidayGifting_Video_v1"))

    print("\n=== invalid names (raise errors) ===")
    for fn, bad in [
        (extract_campaign, "ita_HolidayGifting_Awareness"),   # bad country
        (extract_campaign, "IT_Xmas_Awareness"),              # bad campaign
        (extract_campaign, "IT_HolidayGifting_Awareness_v2"), # too many fields
        (extract_adset,    "IT_HolidayGifting_Broad"),        # too few fields
        (extract_ad,       "IT_HolidayGifting_Video_final"),  # bad version
    ]:
        try:
            fn(bad)
        except NamingConventionError as e:
            print(f"  REJECTED: {e}")
