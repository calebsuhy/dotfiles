#!/bin/sh
# Count running Claude Code sessions: `claude` processes from terminals plus the
# one Claude Desktop starts for each Code session. A claude whose parent is
# also claude is a helper of the same session, so it isn't counted again.
ps -eo pid=,ppid=,comm= | awk '$3 == "claude" { parent[$1] = $2 }
    END { n = 0; for (p in parent) if (!(parent[p] in parent)) n++; print n }'
