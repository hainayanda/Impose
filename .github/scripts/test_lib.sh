#!/bin/bash

set -eo pipefail

xcodebuild -workspace Example/Impose.xcworkspace \
            -scheme Impose-Example \
            -destination platform=iOS\ Simulator,OS=14.3,name=iPhone\ 11 \
            clean test | xcpretty
