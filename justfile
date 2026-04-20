build:
    make

# Smoke test: clean build and assert all three outputs exist and look right.
test:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -s .env ]; then
        cat > .env <<'EOF'
    NAME="Test User"
    EMAIL="test@example.com"
    PHONE="000-000-0000"
    GITHUB_URL="https://example.com"
    EOF
    fi
    # shellcheck disable=SC1091
    . ./.env
    name_snake=$(echo "$NAME" | tr '[:upper:] ' '[:lower:]_')
    base="build/${name_snake}_resume"
    make clean
    make
    [ -s "$base.html" ]
    [ -s "$base.txt"  ]
    [ -s "$base.pdf"  ]
    file "$base.pdf" | grep -q 'PDF document'
    echo "smoke test passed: $base.{html,txt,pdf}"
