import os
import requests
import json

# Configuration from Environment Variables (GitHub Context)
DEVIN_TOKEN = os.getenv("DEVIN_SERVICE_USER_TOKEN")
ORG_ID = os.getenv("DEVIN_ORG_ID")
PR_NUMBER = os.getenv("PR_NUMBER")
PR_BODY = os.getenv("PR_BODY")
PR_TITLE = os.getenv("PR_TITLE")
BASE_URL = "https://api.devin.ai/v3beta1"

def trigger_remediation():
    # 1. Define the Prompt (ISO-5055 + CAST MCP Instructions)
    prompt = f"""
    PR REMEDIATION & MERGE TASK: PR #{PR_NUMBER} - {PR_TITLE}
    
    GOAL: Perform autonomous ISO-5055 remediation on the 'WebGoat_5.2_Devin' branch.
    
    INSTRUCTIONS:
    1. Connect to the 'cast-imaging-express' MCP server to identify specific structural issues.
    2. Identify all ISO-5055 Security flaws (e.g., SQL Injection, XSS) and ISO-5055 Performance flaws.
    3. Identify all  cloud detection pattern, Green Detection pattern, structural-flaws
    4. Create a new branch for the fix. 
    5. Implement the remediations for the identified security and performance flaws.
    6. Open a new Pull Request targeting the base branch 'WebGoat_5.2_Devin'.
    7. Use the 'Devin Review' tool to perform an auto-review of your own changes, checking for regressions and ensuring high fix-confidence.
    8. Once the auto-review is successful and the test suite passes, merge the fixes into the 'WebGoat_5.2_Devin' base branch.
    """

    # 2. Define Structured Output (For your VP Dashboard visibility)
    schema = {
        "type": "object",
        "properties": {
            "vulnerability_type": {"type": "string", "description": "ISO-5055 Category found (Security/Performance)"},
            "cast_dependencies_checked": {"type": "integer"},
            "remediation_status": {"enum": ["analyzing", "reproducing", "fixing", "merged", "failed"]},
            "pr_url": {"type": "string"}
        },
        "required": ["vulnerability_type", "remediation_status"]
    }

    # 3. Call Devin API v3
    headers = {
        "Authorization": f"Bearer {DEVIN_TOKEN}", 
        "Content-Type": "application/json"
    }
    
    payload = {
        "prompt": prompt,
        "structured_output_schema": schema,
        "idempotent": True # Ensures we don't start duplicate sessions if you rename the PR multiple times
    }

    response = requests.post(
        f"{BASE_URL}/organizations/{ORG_ID}/sessions", 
        json=payload, 
        headers=headers
    )
    
    if response.status_code == 200:
        session_info = response.json()
        print(f"Devin Session Started: {session_info['url']}")
    else:
        print(f"Error {response.status_code}: {response.text}")

if __name__ == "__main__":
    trigger_remediation()
