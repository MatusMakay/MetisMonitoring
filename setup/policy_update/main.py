from lib import update_policy

all_policies = []


policies = [ 
    #  "fleet-server-policy",
    # "sysmon-linux-policy",
    {
        "policy_id_kibana": "windows-policy",
        # "policy_path": "/app/policy_update/policies/Windows_SysmonPolicy.json"
        "policy_path": "./policies/Windows_SysmonPolicy.json"
    }
]
# policies = {
#     "Windows": "/app/policy_update/policies/Windows_SysmonPolicy.json",
#     # "Linux": "./policies/Linux_SysmonPolicy.json"
# }

def main():
    for item in policies:
        update_policy(item, all_policies)

main()
