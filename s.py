#!/usr/bin/env python3

import subprocess

subprocess.run(["git", "add", "."], check=True)

message = input("Enter commit message: ")

subprocess.run(["git", "commit", "-m", message], check=True)

subprocess.run(["git", "push"], check=True)