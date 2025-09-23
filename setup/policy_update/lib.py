import json
import requests
import os
from typing import Dict, Optional, Tuple
from requests.packages.urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

ELASTIC_PASSWORD = os.environ.get('ELASTIC_PASSWORD') or "changeme"
ELASTIC_USERNAME = os.environ.get('ELASTIC_USERNAME') or "elastic"
KIBANA_HOST = os.environ.get('KIBANA_SERVER_HOST') or "https://localhost:5601/"
KIBANA_POLICY_UPDATE_PATH = "api/fleet/package_policies/"

def get_elastic_credentials() -> Tuple[str, str]:
    return (ELASTIC_USERNAME, ELASTIC_PASSWORD)

def get_policy_id_from_kibana(policy_id_kibana, all_policies):

    if len(all_policies) == 0:
        response = requests.get(f'{KIBANA_HOST}api/fleet/package_policies',  auth=get_elastic_credentials(), verify=False)
        response.raise_for_status()

        all_policies = response.json()['items']

    for item in all_policies:
        id = item['policy_id']
        if policy_id_kibana == id:
            return item['id']

    raise ValueError('INFO: Policy not found')

def update_policy(policy, all_policies):
    policy_json_path = policy['policy_path']
    policy_id_kibana = policy['policy_id_kibana']

    policy_id = get_policy_id_from_kibana(policy_id_kibana, all_policies)
    print("INFO: Loaded policy_id ", policy_id)

    with open(policy_json_path, 'r') as json_body:
        policy_json = json.load(json_body)

    auth = get_elastic_credentials()
    headers = {
        'Content-Type': 'application/json',
        'kbn-xsrf': 'reporting'
    }
    response = requests.put(f'{KIBANA_HOST}{KIBANA_POLICY_UPDATE_PATH}{policy_id}', json=policy_json, headers=headers, auth=auth, verify=False)
    response.raise_for_status()
    print("INFO: Policy updated successfully")
