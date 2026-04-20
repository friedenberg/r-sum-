build:
    make

# Smoke test: clean build and assert all three outputs exist and look right.
test:
    #!/usr/bin/env bash
    set -euo pipefail
    [ -s NAME ]       || echo 'Test User'           > NAME
    [ -s EMAIL ]      || echo 'test@example.com'    > EMAIL
    [ -s PHONE ]      || echo '000-000-0000'        > PHONE
    [ -s GITHUB_URL ] || echo 'https://example.com' > GITHUB_URL
    name_snake=$(tr '[:upper:] ' '[:lower:]_' < NAME)
    base="build/${name_snake}_resume"
    make clean
    make
    [ -s "$base.html" ]
    [ -s "$base.txt"  ]
    [ -s "$base.pdf"  ]
    file "$base.pdf" | grep -q 'PDF document'
    echo "smoke test passed: $base.{html,txt,pdf}"
