#!/bin/bash
wget https://raw.githubusercontent.com/KSonny4/linux-utils/master/.pre-commit-config.yaml
#alias mkenv="python3.7 -m venv venv; activate; pip install --upgrade pip setuptools 1>/dev/null;"
mkenv
pip install pre-commit
pre-commit install