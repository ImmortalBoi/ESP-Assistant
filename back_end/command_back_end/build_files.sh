# build_files.sh
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
# pip install --no-deps -r requirements.txt
# pip uninstall -y -r uninstall.txt
# sed -i '106,118d;' .venv/lib/python3.9/site-packages/poe_api_wrapper/api.py
# sed -i '106i\        self.client = Client(timeout=180)' .venv/lib/python3.9/site-packages/poe_api_wrapper/api.py
# sed -i '8d;' .venv/lib/python3.9/site-packages/poe_api_wrapper/api.py
# rm .venv/lib/python3.9/site-packages/poe_api_wrapper/proxies.py