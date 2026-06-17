#!/usr/bin/env python3
"""
Fetch all GitHub PRs authored by and reviewed by a given user in cultureamp/murmur.
Outputs a JSON file suitable for pasting into Claude as reviewer context.

Usage:
  python3 fetch_github_activity.py <github-username> [output-file]

Requires: gh CLI authenticated with repo access
"""

import json
import subprocess
import sys
import os

REPO = "cultureamp/murmur"


def gh_api(path):
    result = subprocess.run(
        ["gh", "api", f"repos/{REPO}/{path}"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"gh api {path} failed: {result.stderr.strip()}")
    return json.loads(result.stdout)


def fetch_authored_prs(username):
    result = subprocess.run(
        [
            "gh", "pr", "list",
            "--repo", REPO,
            "--author", username,
            "--state", "all",
            "--limit", "200",
            "--json", "number,title,state,url,body,author,createdAt,mergedAt,reviews,comments,baseRefName,headRefName",
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"gh pr list failed: {result.stderr.strip()}")
    return json.loads(result.stdout)


def fetch_reviewed_prs(username):
    page = 1
    all_items = []
    while True:
        result = subprocess.run(
            ["gh", "api", f"search/issues?q=repo:{REPO}+type:pr+reviewed-by:{username}&per_page=100&page={page}"],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            print(f"  Warning: search page {page} failed: {result.stderr.strip()}", file=sys.stderr)
            break
        data = json.loads(result.stdout)
        items = data.get("items", [])
        if not items:
            break
        all_items.extend(items)
        print(f"  Search page {page}: {len(items)} PRs (total {len(all_items)})", file=sys.stderr)
        if len(items) < 100:
            break
        page += 1
    return all_items


def fetch_pr_review_activity(pr_number, username):
    try:
        all_reviews = gh_api(f"pulls/{pr_number}/reviews?per_page=100")
        reviews = [r for r in all_reviews if r.get("user", {}).get("login") == username]
    except RuntimeError as e:
        print(f"  Warning: reviews for #{pr_number}: {e}", file=sys.stderr)
        reviews = []

    try:
        all_comments = gh_api(f"pulls/{pr_number}/comments?per_page=100")
        inline_comments = [c for c in all_comments if c.get("user", {}).get("login") == username]
    except RuntimeError as e:
        print(f"  Warning: comments for #{pr_number}: {e}", file=sys.stderr)
        inline_comments = []

    return reviews, inline_comments


def slim_authored(pr):
    def slim_review(r):
        author = r.get("author", {})
        return {
            "author": author.get("login") if isinstance(author, dict) else author,
            "state": r.get("state"),
            "body": r.get("body"),
            "submitted_at": r.get("submittedAt"),
        }

    def slim_comment(c):
        author = c.get("author", {})
        return {
            "author": author.get("login") if isinstance(author, dict) else author,
            "body": c.get("body"),
            "created_at": c.get("createdAt"),
        }

    return {
        "number": pr.get("number"),
        "title": pr.get("title"),
        "state": pr.get("state"),
        "url": pr.get("url"),
        "body": pr.get("body"),
        "created_at": pr.get("createdAt"),
        "merged_at": pr.get("mergedAt"),
        "base_branch": pr.get("baseRefName"),
        "head_branch": pr.get("headRefName"),
        "reviews_received": [slim_review(r) for r in (pr.get("reviews") or [])],
        "comments_received": [slim_comment(c) for c in (pr.get("comments") or [])],
    }


def slim_reviewed(item, reviews, inline_comments):
    def slim_review(r):
        return {
            "state": r.get("state"),
            "body": r.get("body"),
            "submitted_at": r.get("submitted_at"),
        }

    def slim_comment(c):
        return {
            "path": c.get("path"),
            "body": c.get("body"),
            "created_at": c.get("created_at"),
            "diff_hunk": c.get("diff_hunk"),
        }

    return {
        "pr_number": item["number"],
        "pr_title": item.get("title"),
        "pr_url": item.get("html_url"),
        "pr_author": item.get("user", {}).get("login"),
        "pr_created_at": item.get("created_at"),
        "pr_state": item.get("state"),
        "reviews": [slim_review(r) for r in reviews],
        "inline_comments": [slim_comment(c) for c in inline_comments],
    }


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    username = sys.argv[1]
    default_output = f"{username.lower()}-github-activity.json"
    output_path = sys.argv[2] if len(sys.argv) > 2 else default_output

    print(f"Fetching GitHub activity for {username} in {REPO}...", file=sys.stderr)

    print("\n[1/3] Fetching authored PRs...", file=sys.stderr)
    authored_raw = fetch_authored_prs(username)
    print(f"  Found {len(authored_raw)} authored PRs", file=sys.stderr)

    print("\n[2/3] Searching for reviewed PRs...", file=sys.stderr)
    reviewed_search = fetch_reviewed_prs(username)
    print(f"  Found {len(reviewed_search)} reviewed PRs", file=sys.stderr)

    print("\n[3/3] Fetching review comments for each reviewed PR...", file=sys.stderr)
    reviewed_prs = []
    for item in reviewed_search:
        pr_number = item["number"]
        reviews, inline_comments = fetch_pr_review_activity(pr_number, username)
        if reviews or inline_comments:
            reviewed_prs.append(slim_reviewed(item, reviews, inline_comments))
            print(f"  #{pr_number}: {len(reviews)} reviews, {len(inline_comments)} inline comments", file=sys.stderr)

    output = {
        "meta": {
            "github_user": username,
            "repository": REPO,
            "description": (
                f"PRs authored by {username} and PRs they reviewed, with their review comments. "
                "Intended to help understand their coding style and review preferences."
            ),
            "authored_pr_count": len(authored_raw),
            "reviewed_pr_count": len(reviewed_prs),
        },
        "authored_prs": [slim_authored(pr) for pr in authored_raw],
        "reviewed_prs": reviewed_prs,
    }

    with open(output_path, "w") as f:
        json.dump(output, f, indent=2)

    size_kb = os.path.getsize(output_path) / 1024
    print(f"\nDone. Written to {output_path} ({size_kb:.1f} KB)", file=sys.stderr)
    print(f"  {len(authored_raw)} authored PRs", file=sys.stderr)
    print(f"  {len(reviewed_prs)} reviewed PRs with {username}'s comments", file=sys.stderr)


if __name__ == "__main__":
    main()
