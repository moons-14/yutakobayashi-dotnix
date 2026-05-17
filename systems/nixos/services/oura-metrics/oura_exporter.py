#!/usr/bin/env python3
import argparse
import json
import os
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone
from pathlib import Path


BASE = "https://api.ouraring.com/v2/usercollection"


def http_get(url: str, token: str):
    req = urllib.request.Request(
        url,
        headers={"Authorization": f"Bearer {token}", "Accept": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode("utf-8"))


def fetch_daily(kind: str, start_date: str, end_date: str, token: str):
    q = urllib.parse.urlencode({"start_date": start_date, "end_date": end_date})
    return http_get(f"{BASE}/{kind}?{q}", token).get("data", [])


def pick(entry, *keys):
    cur = entry
    for k in keys:
        if not isinstance(cur, dict) or k not in cur:
            return None
        cur = cur[k]
    return cur


def to_hours(seconds):
    if not isinstance(seconds, (int, float)):
        return None
    return round(seconds / 3600.0, 2)


def write_prometheus_textfile(path: Path, metrics: dict):
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = []
    for name, labels, value, help_text in metrics:
        if help_text:
            lines.append(f"# HELP {name} {help_text}")
        lines.append(f"# TYPE {name} gauge")
        if labels:
            label_str = ",".join(f'{k}="{v}"' for k, v in labels.items())
            lines.append(f"{name}{{{label_str}}} {value}")
        else:
            lines.append(f"{name} {value}")
    path.write_text("\n".join(lines) + "\n")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", default="today", help="today or YYYY-MM-DD")
    ap.add_argument("--tz", default="Asia/Tokyo")
    ap.add_argument(
        "--output",
        default="/var/lib/prometheus/oura.prom",
        help="Prometheus textfile output path",
    )
    args = ap.parse_args()

    token = os.getenv("OURA_PERSONAL_ACCESS_TOKEN")
    if not token:
        print("OURA_PERSONAL_ACCESS_TOKEN is not set", file=sys.stderr)
        sys.exit(1)

    from zoneinfo import ZoneInfo

    tz = ZoneInfo(args.tz)
    if args.date == "today":
        target = datetime.now(tz).date()
    else:
        target = datetime.date.fromisoformat(args.date)

    baseline_days = 7
    start = target - timedelta(days=baseline_days)
    start_s = start.isoformat()
    end_s = target.isoformat()

    try:
        sleeps = fetch_daily("daily_sleep", start_s, end_s, token)
        readiness = fetch_daily("daily_readiness", start_s, end_s, token)
        activity = fetch_daily("daily_activity", start_s, end_s, token)
    except Exception as e:
        print(f"fetch failed: {e}", file=sys.stderr)
        sys.exit(2)

    by_day = {
        "sleep": {d.get("day"): d for d in sleeps if d.get("day")},
        "readiness": {d.get("day"): d for d in readiness if d.get("day")},
        "activity": {d.get("day"): d for d in activity if d.get("day")},
    }

    day = target.isoformat()
    today_sleep = by_day["sleep"].get(day, {})
    today_readiness = by_day["readiness"].get(day, {})
    today_activity = by_day["activity"].get(day, {})

    def safe(v):
        if v is None:
            return "NaN"
        return str(v)

    metrics = [
        (
            "oura_readiness_score",
            {"day": day},
            safe(pick(today_readiness, "score")),
            "Oura readiness score",
        ),
        (
            "oura_sleep_score",
            {"day": day},
            safe(pick(today_sleep, "score")),
            "Oura sleep score",
        ),
        (
            "oura_activity_score",
            {"day": day},
            safe(pick(today_activity, "score")),
            "Oura activity score",
        ),
        (
            "oura_sleep_hours",
            {"day": day},
            safe(
                to_hours(
                    pick(today_sleep, "total_sleep_duration")
                    or pick(today_sleep, "contributors", "total_sleep", "value")
                )
            ),
            "Oura total sleep in hours",
        ),
        (
            "oura_resting_heart_rate",
            {"day": day},
            safe(pick(today_readiness, "contributors", "resting_heart_rate", "value")),
            "Oura resting heart rate",
        ),
        (
            "oura_hrv_balance",
            {"day": day},
            safe(pick(today_readiness, "contributors", "hrv_balance", "value")),
            "Oura HRV balance",
        ),
        (
            "oura_temperature_deviation",
            {"day": day},
            safe(pick(today_sleep, "contributors", "temperature_deviation", "value")),
            "Oura temperature deviation",
        ),
        (
            "oura_temperature_trend_deviation",
            {"day": day},
            safe(
                pick(
                    today_sleep, "contributors", "temperature_trend_deviation", "value"
                )
            ),
            "Oura temperature trend deviation",
        ),
        (
            "oura_activity_steps",
            {"day": day},
            safe(pick(today_activity, "steps")),
            "Oura activity steps",
        ),
        (
            "oura_activity_calories",
            {"day": day},
            safe(pick(today_activity, "calories")),
            "Oura activity active calories",
        ),
    ]

    write_prometheus_textfile(Path(args.output), metrics)


if __name__ == "__main__":
    main()
