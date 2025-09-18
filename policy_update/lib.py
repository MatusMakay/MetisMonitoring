import json
import requests
import os
from typing import Dict, Optional, Tuple

WINDOWS_POLICY_ID = os.environ.get('WINDOWS_POLICY_ID') or "e856ef07-3665-4d7b-9a6e-d4551b205904"
LINUX_SYSMON_POLICY_ID = os.environ.get('LINUX_SYSMON_POLICY_ID')
ELASTIC_PASSWORD = os.environ.get('ELASTIC_PASSWORD')
ELASTIC_USERNAME = os.environ.get('ELASTIC_USERNAME')
KIBANA_HOST = os.environ.get('KIBANA_HOST') or "https://localhost:5601/"
KIBANA_POLICY_UPDATE_PATH = "api/fleet/package_policies/"

def get_elastic_credentials() -> Tuple[str, str]:
    return ("elastic", "changeme")

def update_policy(policy: str, policy_json_path: str):
    with open(policy_json_path, 'r') as json_body:
        policy_json = json.load(json_body)

    if policy.lower() == 'windows':
        policy_id = WINDOWS_POLICY_ID
    elif policy.lower() == 'linux':
        policy_id = LINUX_SYSMON_POLICY_ID
    else:
        raise ValueError(f"Invalid policy: {policy}")

    auth = get_elastic_credentials()
    headers = {
        'Content-Type': 'application/json',
        'kbn-xsrf': 'reporting'
    }
    response = requests.put(f'{KIBANA_HOST}{KIBANA_POLICY_UPDATE_PATH}{policy_id}', json=policy_json, headers=headers, auth=auth, verify=False)
    response.raise_for_status()
    print("INFO Policy updated successfully")
