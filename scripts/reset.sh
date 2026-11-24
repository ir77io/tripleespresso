#!/bin/bash
#
# Resets Triple Espresso to a fresh-install state (preferences and sandbox container).
#

BUNDLE_ID="io.ir77.tripleespresso"

pkill -x TripleEspresso 2>/dev/null
defaults delete "$BUNDLE_ID" 2>/dev/null
rm -rf "$HOME/Library/Containers/$BUNDLE_ID"
echo "Reset $BUNDLE_ID"
