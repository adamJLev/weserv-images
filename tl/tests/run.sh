#!/bin/sh
# Checks every case in url-cases.txt against url-allowlist.conf.
# ALLOW expects HTTP 200, DENY expects HTTP 400 (same as imagesweserv.conf).
# Run from the repo root (uses docker):
#   make -C tl test

nginx -c /repo/tl/tests/nginx.conf

fail=0
while read -r want query; do
    case "$want" in
        ''|'#'*) continue ;;
        ALLOW) want_status=200 ;;
        DENY)  want_status=400 ;;
        *) echo "BAD CASE: unknown verdict '$want': ?$query"; fail=1; continue ;;
    esac
    got_status=$(curl -s -g --path-as-is -o /dev/null -w '%{http_code}' "http://localhost/?$query")
    if [ "$got_status" != "$want_status" ]; then
        echo "FAIL: $want expected HTTP $want_status, got HTTP $got_status: ?$query"
        fail=1
    fi
done < /repo/tl/tests/url-cases.txt

[ $fail = 0 ] && echo "All passed"
exit $fail
