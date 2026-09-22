#!/usr/bin/env bash

set -e

CONFIG="_config.yml,_config_dev.yml"
URL="http://127.0.0.1:4000/Gallery/dev/Organiser"

echo "Starting Jekyll local preview..."

cleanup() {
    echo
    echo "Shutting down services..."

    if [[ -n "${PYTHON_PID:-}" ]] && kill -0 "$PYTHON_PID" 2>/dev/null; then
        kill "$PYTHON_PID" 2>/dev/null || true
        echo "Save server stopped."
    fi

    if [[ -n "${JEKYLL_PID:-}" ]] && kill -0 "$JEKYLL_PID" 2>/dev/null; then
        kill "$JEKYLL_PID" 2>/dev/null || true
        echo "Jekyll server stopped."
    fi

    echo "Environment closed."
}

trap cleanup EXIT INT TERM

echo "Running initial Jekyll build..."
bundle exec jekyll build --config "$CONFIG"

echo "Starting save server..."
python3 save_server.py &
PYTHON_PID=$!

echo "Save server PID: $PYTHON_PID"

echo "Starting Jekyll server..."
bundle exec jekyll serve \
    --config "$CONFIG" \
    --livereload &
JEKYLL_PID=$!

echo "Jekyll server PID: $JEKYLL_PID"

sleep 2

echo "Opening Firefox..."
firefox -P "Dev" -no-remote "$URL" &

echo
echo "Development environment running."
echo "Gallery:    $URL"
echo "Save API:   http://127.0.0.1:8765"
echo
echo "Press CTRL+C to stop."

# Keep launcher alive while both services run.
while kill -0 "$PYTHON_PID" 2>/dev/null &&
      kill -0 "$JEKYLL_PID" 2>/dev/null; do
    sleep 1
done

echo
echo "A development service has stopped."