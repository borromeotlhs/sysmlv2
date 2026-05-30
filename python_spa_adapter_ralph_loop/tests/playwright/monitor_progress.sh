#!/bin/bash

# Monitor Playwright test progress with textual progress bar

LOG_FILE="/tmp/test_headed_progress.log"
LAST_LINE=""
TOTAL_TESTS=79

echo "==================================="
echo "  Playwright Test Progress Monitor"
echo "==================================="
echo ""

while true; do
  if [ ! -f "$LOG_FILE" ]; then
    sleep 1
    continue
  fi

  # Count passed and failed tests
  PASSED=$(grep -c "✓.*›" "$LOG_FILE" 2>/dev/null || echo "0")
  FAILED=$(grep -c "✘.*›" "$LOG_FILE" 2>/dev/null || echo "0")

  # Ensure numeric values
  PASSED=${PASSED:-0}
  FAILED=${FAILED:-0}

  COMPLETED=$((PASSED + FAILED))

  # Calculate percentage
  if [ $TOTAL_TESTS -gt 0 ]; then
    PERCENT=$((COMPLETED * 100 / TOTAL_TESTS))
  else
    PERCENT=0
  fi

  # Create progress bar (50 chars wide)
  BAR_WIDTH=50
  FILLED=$((PERCENT * BAR_WIDTH / 100))
  EMPTY=$((BAR_WIDTH - FILLED))

  BAR="["
  for i in $(seq 1 $FILLED); do BAR="${BAR}="; done
  for i in $(seq 1 $EMPTY); do BAR="${BAR} "; done
  BAR="${BAR}]"

  # Get current test name (last line with test marker)
  CURRENT=$(grep "›" "$LOG_FILE" 2>/dev/null | tail -1 | sed 's/.*› //')

  # Clear screen and display
  clear
  echo "==================================="
  echo "  Playwright Test Progress"
  echo "==================================="
  echo ""
  echo "Progress: $COMPLETED / $TOTAL_TESTS tests"
  echo "$BAR $PERCENT%"
  echo ""
  echo "✓ Passed: $PASSED"
  echo "✘ Failed: $FAILED"
  echo ""
  echo "Current test:"
  echo "  $CURRENT"
  echo ""
  echo "Recent tests:"
  grep "›" "$LOG_FILE" 2>/dev/null | tail -5 | sed 's/^/  /'

  # Check if tests completed
  if grep -q "passed\|failed" "$LOG_FILE" 2>/dev/null | tail -1 | grep -qE "[0-9]+ (passed|failed)"; then
    echo ""
    echo "==================================="
    echo "  Tests Completed!"
    echo "==================================="
    echo ""
    tail -10 "$LOG_FILE" | grep -E "passed|failed" | sed 's/^/  /'
    break
  fi

  sleep 2
done
