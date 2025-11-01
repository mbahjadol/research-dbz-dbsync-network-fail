#!/bin/bash

source ./env.sh

if [ "$1" == "insert-bg" ]; then
  docker exec sim-svc sh -c "curl -s http://localhost:8000/sim-insert-bg; echo" | jq
elif [ "$1" == "update-bg" ]; then
  docker exec sim-svc sh -c "curl -s http://localhost:8000/sim-update-bg; echo" | jq
elif [ "$1" == "stop-insert-bg" ]; then
  docker exec sim-svc sh -c "curl -s http://localhost:8000/stop-insert-bg; echo" | jq
elif [ "$1" == "stop-update-bg" ]; then
  docker exec sim-svc sh -c "curl -s http://localhost:8000/stop-update-bg; echo" | jq
elif [ "$1" == "status" ]; then
  docker exec sim-svc sh -c "curl -s http://localhost:8000/status; echo" | jq
else
  echo "Usage: $0 {insert-bg|update-bg|stop-insert-bg|stop-update-bg|status}"
  echo "  insert-bg       - ➕Start background inserts"
  echo "  update-bg       - ✏️Start background updates"
  echo "  stop-insert-bg  - ⛔Stop background inserts"
  echo "  stop-update-bg  - 🚫Stop background updates"
  echo "  status          - 📦Get status of background operations"
fi