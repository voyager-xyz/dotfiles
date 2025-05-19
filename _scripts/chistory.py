import os
import shutil
import sqlite3
from datetime import datetime, timedelta
from urllib.parse import urlparse
import sys

def get_tld(url):
    return urlparse(url).netloc


# Chrome stores time as microseconds since Jan 1, 1601
def chrome_time_to_datetime(chrome_time):
    if chrome_time == 0:
        return ""
    return datetime(1601, 1, 1) + timedelta(microseconds=chrome_time)

def read_db(file_path):
    # Connect to the copied database
    conn = sqlite3.connect(file_path)
    cursor = conn.cursor()

    # Query for URLs, titles, and visit counts
    cursor.execute("""
        SELECT url, title, visit_count, last_visit_time
        FROM urls
        ORDER BY visit_count DESC
    """)

    links = []
    for url, title, visit_count, last_visit_time in cursor.fetchall():
        links.append(
            {
                "domain": get_tld(url),
                "url": url,
                "title": title,
                "visit_count": visit_count,
                "last_visit_time": chrome_time_to_datetime(last_visit_time),
            }
        )

    conn.close()
    return links

def main(sort_key, filter_by, attrs):
    history_path = os.path.expanduser(
        "~/Library/Application Support/Google/Chrome/Default/History"
    )
    tmp_history = "/tmp/History"
    shutil.copy2(history_path, tmp_history)
    links = read_db(tmp_history)

    links = [
        e
        for e in sorted(links, key=lambda x: x[sort_key])
        if e[filter_by["key"]] == filter_by["value"]
    ]
    for link in links:
        print(
            ",".join([str(link[a]) for a in attrs])
        )
    os.remove(tmp_history)
if __name__ == "__main__":

    # sort_key = "visit_count"
    # filter_by = {"key": "domain", "value": "github.com"}
    # attrs = ["url", "visit_count"]

    sort_key = sys.argv[1]
    filter_by = {
        "key": sys.argv[2],
        "value": sys.argv[3]
    }
    attrs = sys.argv[4].split(",")

    main(sort_key, filter_by, attrs)
