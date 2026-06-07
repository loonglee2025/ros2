#!/usr/bin/env zsh
# vim: set ft=zsh:
# =============================================================================
# tests/test_aliases.zsh — Verify alias expansion
# Run: zsh tests/test_aliases.zsh
# =============================================================================

set -e
local plugin_dir="${0:A:h:h}"
local fail=0

# Source plugin in a controlled way
ZSH="/tmp/fake-omz"
source "$plugin_dir/ros2-shortcuts.plugin.zsh"

echo "=== ros2-shortcuts alias expansion test ==="

# Helper
_check_alias() {
  local name="$1"
  local expected="$2"
  local actual
  actual=$(alias "$name" 2>/dev/null | sed "s/^${name}=//; s/'//g")
  if [[ "$actual" == "$expected" ]]; then
    echo "  PASS: $name -> $actual"
  else
    echo "  FAIL: $name expected '$expected', got '$actual'"
    ((fail++))
  fi
}

# Core aliases
echo "[GROUP] Topic aliases"
_check_alias "rtl" "ros2 topic list"
_check_alias "rtlt" "ros2 topic list -t"
_check_alias "rte" "ros2 topic echo"

echo "[GROUP] Service aliases"
_check_alias "rsl" "ros2 service list"
_check_alias "rsc" "ros2 service call"

echo "[GROUP] Node aliases"
_check_alias "rnl" "ros2 node list"

echo "[GROUP] Param aliases"
_check_alias "rpl" "ros2 param list"
_check_alias "rpg" "ros2 param get"

echo "[GROUP] Colcon aliases"
_check_alias "cb" "colcon build"
_check_alias "cbs" "colcon build --symlink-install"

# Summary
echo "================================"
if [[ $fail -eq 0 ]]; then
  echo "All alias tests PASSED"
  exit 0
else
  echo "$fail alias test(s) FAILED"
  exit 1
fi
