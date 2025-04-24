clean:
	rm -rf dist/ build/

build:
	uv sync
	uv pip install pyinstaller
	@. .venv/bin/activate \
    && pyinstaller --onefile click_example.py --name click-example --collect-all trogon --collect-all textual
