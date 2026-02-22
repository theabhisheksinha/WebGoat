import os
import requests
import json

# Configuration from Environment Variables (Safe for GitHub Actions)
DEVIN_TOKEN = os.getenv("DEVIN_SERVICE_USER_TOKEN")
ORG_ID = os.getenv("DEVIN_ORG_ID")
GITHUB_ISSUE_BODY = os.getenv("ISSUE_BODY")
GITHUB_ISSUE_NUMBER = os.getenv("ISSUE_NUMBER")
BASE_URL = "https://api.devin.ai/v3beta1"

def trigger_remediation():
    # 1. Define the Prompt (Grounded in CAST MCP)
    prompt = f"""
    REMEDIATION TASK: Issue #{GITHUB_ISSUE_NUMBER}
    CONTEXT: {GITHUB_ISSUE_BODY}
    
    INSTRUCTIONS:
    1. Use the cast-imaging-express MCP server to map the dependencies of the files mentioned.
    2. identify the ISO-5055 security flaws.
    3. identify the ISO-5055 performance flaws.
    4. Open a separate PR to the base branch.
    5. Fix the code for the identified security and performance flaws for each PR opened.
    6. Auto Review them.
    7. Merge the PRs to the base branch WebGoat-5.2-Devin.
    """

    # 2. Define Structured Output (The "Dashboard Data")
    schema = {
        "type": "object",
        "properties": {
            "vulnerability_type": {"type": "string"},
            "cast_dependencies_checked": {"type": "integer"},
            "fix_confidence_score": {"type": "number"},
            "pr_url": {"type": "string"}
        },
        "required": ["vulnerability_type", "fix_confidence_score"]
    }

    # 3. Call Devin API v3
    headers = {"Authorization": f"Bearer {DEVIN_TOKEN}", "Content-Type": "application/json"}
    payload = {
        "prompt": prompt,
        "structured_output_schema": schema,
        "idempotent": True # Prevents duplicate sessions for the same issue
    }

    response = requests.post(f"{BASE_URL}/organizations/{ORG_ID}/sessions", json=payload, headers=headers)
    
    if response.status_code == 200:
        session_info = response.json()
        print(f"Devin Session Started: {session_info['url']}")
    else:
        print(f"Error: {response.text}")

if __name__ == "__main__":
    trigger_remediation()