from lib import update_policy

policies = {
    "Windows": "./policies/Windows_SysmonPolicy.json",
    # "Linux": "./policies/Linux_SysmonPolicy.json"
}

def main():
    for key, value in policies.items():
        print(f"Key: {key}, Value: {value}")
        update_policy(key, value)

main()
