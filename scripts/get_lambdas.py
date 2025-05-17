import json
import os

directory = "/Users/jarrod.folino/Code"

other_repos = [
    {
        "name": "template-serverless-api",
        "path": "../template-serverless-api",
    },
    {"name": "python-db-item-handler", "path": "../python-db-item-handler"},
    {"name": "python-lambda-utils", "path": "../python-lambda-utils"},
    {"name": "msk-cluster-uat", "path": "../msk-cluster-uat"},
    {
        "name": "flexipay-rewards-and-pricing-db-migrator",
        "path": "../flexipay-rewards-and-pricing-db-migrator",
    },
    {"name": "python-vault-utils", "path": "../python-vault-utils"},
    {"name": "python-kafka-utils", "path": "../python-kafka-utils"},
    {"name": "python-poetry-docker-image", "path": "../python-poetry-docker-image"},
    {
        "name": "python-lambda-builder-docker-image",
        "path": "../python-lambda-builder-docker-image",
    },
    {"name": "drone-terraform-docker-image", "path": "../drone-terraform-docker-image"},
    {
        "name": "flexipay-billing-cashback-end-to-end",
        "path": "../flexipay-billing-cashback-end-to-end",
    },
]

lambda_repos = [
    {"name": "uk-borrower-platform-rewards", "path": "../uk-borrower-platform-rewards"},
    {
        "name": "uk-borrower-platform-transactions",
        "path": "../uk-borrower-platform-transactions",
    },
    {"name": "flexipay-pricing-end-to-end", "path": "../flexipay-pricing-end-to-end"},
    {
        "name": "stc-transactions-api",
        "path": "../stc-transactions-api",
        "lambda_prefix": "stc_transactions_api_",
    },
    {
        "name": "flexipay-rewards-api",
        "path": "../flexipay-rewards-api",
        "lambda_prefix": "fp_rewards_api_",
    },
    {
        "name": "flexipay-pricing-api",
        "path": "../flexipay-pricing-api",
        "lambda_prefix": "fp_pricing_api_",
    },
    {
        "name": "flexipay-rewards-and-pricing-shared",
        "path": "../flexipay-rewards-and-pricing-shared",
        "lambda_prefix": "fp_rap_shared_",
    },
]


def get_folders_in_directory(directory_path):
    skip_folders = [
        "src",
        "tests",
        ".venv",
        "shared",
        "build",
        "build_package",
        "lambda",
    ]

    makefile_paths = []
    for root, dirs, files in os.walk(directory_path):
        dirs[:] = [directory for directory in dirs if directory not in skip_folders]
        if "Makefile" in files:
            makefile_paths.append(os.path.join(root, "Makefile"))

    dir_names = [
        os.path.relpath(os.path.dirname(path), start=directory_path)
        for path in makefile_paths
    ]
    replaced_dir_names = [
        dir_name.replace("/", "_")
        for dir_name in dir_names
        if len(dir_name.split("/")) < 3
    ]
    return set(replaced_dir_names)


def generate_cwlog_url(repo):
    lambda_cwlogs_url = "https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Flambda$252F"
    lambda_url = "https://eu-west-1.console.aws.amazon.com/lambda/home?region=eu-west-1#/functions/"
    results = []
    repo_name = repo["name"]
    lambda_prefix = repo.get("lambda_prefix")
    if lambda_prefix:
        handlers_directory = f"{directory}/{repo_name}/handlers"
        lambdas = get_folders_in_directory(handlers_directory)
        for lambda_name in lambdas:
            results.append(
                {
                    "name": f"{lambda_prefix}{lambda_name}",
                    "link": f"{lambda_cwlogs_url}{lambda_prefix}{lambda_name}",
                    "lambda_link": f"{lambda_url}{lambda_prefix}{lambda_name}",
                }
            )

    return results


def get_prs(repo):
    cmd = f"gh pr list --repo FundingCircle/{repo} --state open --json number,title,author,url"
    prs = os.popen(cmd).read()
    return [
        {"name": f"{pr['title']} {pr['author']['login']}", "link": pr["url"]}
        for pr in json.loads(prs)
    ]


def generate_lambda_url(repo):
    lambda_url = "https://eu-west-1.console.aws.amazon.com/lambda/home?region=eu-west-1#/functions/"
    results = []
    repo_name = repo["name"]
    lambda_prefix = repo.get("lambda_prefix")
    if lambda_prefix:
        handlers_directory = f"{directory}/{repo_name}/handlers"
        lambdas = get_folders_in_directory(handlers_directory)
        for lambda_name in lambdas:
            results.append(
                {
                    "name": f"{lambda_prefix}{lambda_name}",
                    "link": f"{lambda_url}{lambda_prefix}{lambda_name}",
                }
            )

    return results


def get_unique_items(input_list):
    seen = set()
    unique_dicts = []
    for d in input_list:
        # Convert dictionary to a frozenset of its items to make it hashable
        dict_tuple = frozenset(d.items())
        if dict_tuple not in seen:
            seen.add(dict_tuple)
            unique_dicts.append(d)
    return unique_dicts


def make_file(repos, file_name):
    results = []

    for repo in repos:
        results.append(
            {
                "name": repo["name"],
                "cwlogs": get_unique_items(generate_cwlog_url(repo)),
                "lambdas": get_unique_items(generate_lambda_url(repo)),
                "prs": get_prs(repo["name"]),
                "links": [
                    {
                        "name": "Github",
                        "link": f"https://github.com/FundingCircle/{repo['name']}",
                    },
                    {
                        "name": "MyPrs",
                        "link": f"https://github.com/FundingCircle/{repo['name']}/pulls?q=is%3Apr+is%3Amerged+author%3AJarrodFolinoFC+",
                    },
                    {
                        "name": "Pulls",
                        "link": f"https://github.com/FundingCircle/{repo['name']}/pulls",
                    },
                    {
                        "name": "CI",
                        "link": f"https://drone.fc-ops.com/FundingCircle/{repo['name']}",
                    },
                ],
            }
        )

    # Write the results to a JSON file
    with open(file_name, "w") as file:
        json.dump(results, file)


if __name__ == "__main__":
    # print("Generating files...")
    # print(list(get_folders_in_directory("/Users/jarrod.folino/Dev/sharks/rap/flexipay-rewards-api")))
    make_file(
        lambda_repos, "/Users/jarrod.folino/Code/cuiwork/public/data.json"
    )
    make_file(
        other_repos, "/Users/jarrod.folino/Code/cuiwork/public/other.json"
    )
