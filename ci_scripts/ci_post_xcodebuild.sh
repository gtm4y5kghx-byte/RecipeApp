#!/bin/sh

# ci_post_xcodebuild.sh
# Runs after xcodebuild completes (build or test).
# Preserves test artifacts for easier debugging.

set -e

echo "=== Post-Xcodebuild Script ==="
echo "Action: $CI_XCODEBUILD_ACTION"
echo "Exit Code: $CI_XCODEBUILD_EXIT_CODE"

# Only process test results
if [ "$CI_XCODEBUILD_ACTION" = "test-without-building" ] || [ "$CI_XCODEBUILD_ACTION" = "test" ]; then
    echo "Processing test results..."

    # Log test environment info
    echo "Test Device: $CI_TEST_DESTINATION_DEVICE_TYPE"
    echo "Test Runtime: $CI_TEST_DESTINATION_RUNTIME"

    # If tests failed, try to extract useful info
    if [ "$CI_XCODEBUILD_EXIT_CODE" != "0" ]; then
        echo "=== Tests Failed - Extracting Debug Info ==="

        # Check if result bundle exists
        if [ -d "$CI_RESULT_BUNDLE_PATH" ]; then
            echo "Result bundle found at: $CI_RESULT_BUNDLE_PATH"

            # List contents for debugging
            echo "Result bundle contents:"
            ls -la "$CI_RESULT_BUNDLE_PATH" || true

            # Try to find crash logs
            DIAGNOSTICS_PATH="$CI_RESULT_BUNDLE_PATH/1_Test/Diagnostics"
            if [ -d "$DIAGNOSTICS_PATH" ]; then
                echo "=== Crash/Diagnostic Logs ==="
                find "$DIAGNOSTICS_PATH" -name "*.crash" -o -name "*.ips" 2>/dev/null | head -10 || true
            fi
        else
            echo "No result bundle found at expected path"
        fi
    else
        echo "Tests passed successfully"
    fi
fi

echo "=== Post-Xcodebuild Complete ==="
