from datetime import datetime

def time_to_minutes(time_str: str) -> int:
    t = datetime.strptime(time_str, "%H:%M")  # 24-hour format
    return t.hour * 60 + t.minute