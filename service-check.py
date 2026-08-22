import subprocess
services=["Eventvwr","Spooler","WinDefend"]
for service in services:
    result = subprocess.run(["powershell","-command", f"(Get-service -Name '{service}').status"], capture_output=True, text=True)
    status=result.stdout.strip()
    if status=="Running":
        print(f"{service} is running")
    else:
        print(f"{service} not running")


import subprocess

services = ["Spooler", "W32Time", "BITS", "WinDefend", "EventLog"]

for service in services:
    result = subprocess.run(
        ["powershell", "-Command",
         f"(Get-Service -Name '{service}').Status"],
        capture_output=True,
        text=True
    )

    status = result.stdout.strip()

    if status == "Running":
        print(f"{service} is running")
    else:
        print(f"{service} is not running")