from lib import update_policy

all_policies_from_kibana = []

policies = [
    # "fleet-server-policy",
    # "sysmon-linux-policy",
    {
        "policy_id_kibana": "windows-policy",
        "policy_path": "./policies/Windows_SysmonPolicy.json"
    }
]

def main():
    for item in policies:
        update_policy(item, all_policies_from_kibana)

main()
