import time
import sys


count = 0
start_time = time.time()
while (time.time() - start_time) < 60:
    line = sys.stdin.readline().strip()
    if line == "def":
        count += 1
print(f"You typed the word 'def' {count} times in 60 seconds.")
