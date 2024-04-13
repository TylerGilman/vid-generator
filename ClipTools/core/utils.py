# utils.py
def format_time(seconds):
    hours = int(seconds / 3600)
    minutes = int((seconds % 3600) / 60)
    seconds = seconds % 60
    return "{:01d}:{:02d}:{:06.3f}".format(hours, minutes, seconds)
