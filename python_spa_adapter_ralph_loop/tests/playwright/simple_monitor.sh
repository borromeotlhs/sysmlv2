#!/bin/bash

LOG_FILE="/tmp/test_headed_progress.log"
TOTAL=79

while true; do
  if [ -f "$LOG_FILE" ]; then
    PASSED=$(grep "✓" "$LOG_FILE" 2>/dev/null | wc -l)
    FAILED=$(grep "✘" "$LOG_FILE" 2>/dev/null | wc -l)
    DONE=$((PASSED + FAILED))
    PCT=$((DONE * 100 / TOTAL))

    clear
    echo "========================================"
    echo "   Playwright Tests Progress"
    echo "========================================"
    echo ""
    echo "Completed: $DONE / $TOTAL ($PCT%)"
    echo "✓ Passed:  $PASSED"
    echo "✘ Failed:  $FAILED"
    echo ""
    echo "Recent tests:"
    grep "›" "$LOG_FILE" 2>/dev/null | tail -5
    echo ""

    # Check if done
    if grep -q "passed\|failed" "$LOG_FILE" 2>/dev/null; then
      if tail -1 "$LOG_FILE" | grep -qE "[0-9]+ (passed|failed)"; then
        echo "========================================"
        echo "   Tests Complete!"
        echo "========================================"
        tail -5 "$LOG_FILE"
        break
      fi
    fi
  fi

  sleep 3
done
