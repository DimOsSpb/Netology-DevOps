import os
import subprocess
import json
from datetime import datetime

LOG_FILE_DIR = "/var/log/"
LOG_FILE = "awesome-monitoring.log"

metrics = {}
# - load average -> /proc/loadavg
# - memory -> /proc/meminfo
# - disk -> /proc/diskstats
disks = ["/dev/nvme0n1p5","/dev/nvme0n1p1"]

def get_metrics():
    # TIMESTAMP
    ts_int = int(datetime.now().timestamp())
    metrics["timestamp"] = str(ts_int)
    # LA
    with open("/proc/loadavg") as f:
        parts = f.read().strip().split()
        metrics["load1"] = float(parts[0])
        metrics["load5"] = float(parts[1])
        metrics["load15"] = float(parts[2])
    # MEM    
    with open("/proc/meminfo") as f:
        for i, line in enumerate(f, start=1):
            parts = line.strip().split()
            if i == 1:
                metrics["MemTotal"] = int(parts[1])
            elif i == 3:
                metrics["MemAvailable"] = int(parts[1])
                break 
    # DISK
    result = subprocess.run(["df", "-h"], capture_output=True, text=True)
    lines = result.stdout.strip().split("\n")
    for line in lines[1:]:
        parts = line.split()
        if len(parts) >= 6:
            if parts[0] in disks:
                metrics[parts[0]] = int(parts[4].strip("%") )

def main():
    log_file = LOG_FILE_DIR + datetime.now().strftime("%y-%m-%d-") + LOG_FILE
    with open(log_file, "a", encoding="utf-8") as log:
        get_metrics()
        log.write(json.dumps(metrics, ensure_ascii=False) + "\n")

if __name__ == "__main__":
    main()