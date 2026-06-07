#!/usr/bin/env zsh
# vim: set ft=zsh:
# =============================================================================
# ros2 — Oh My Zsh plugin for ROS 2 CLI
# https://github.com/loonglee2025/ros2
# =============================================================================
# A fast, safe, modular alias/function system for daily ROS 2 development.
#
# Design principles:
#   - Short but readable: 2-4 character prefixes
#   - Modular loading: enable/disable per subsystem via env vars
#   - Safe defaults: no destructive aliases enabled by default
#   - Function-over-alias: anything with logic/args uses a function
# =============================================================================

# ---------------------------------------------------------------------------
# 0. Guard: skip if not running under Oh My Zsh (optional safety)
# ---------------------------------------------------------------------------
[[ -z "$ZSH" ]] && return 0

# ---------------------------------------------------------------------------
# 1. Resolve plugin root (works for OMZ custom/plugins and manual install)
# ---------------------------------------------------------------------------
local _ROS2_DIR="${0:A:h}"

# ---------------------------------------------------------------------------
# 2. Default feature flags (override before sourcing if desired)
#    Example in ~/.zshrc BEFORE plugins=(... ros2 ...):
#      export ROS2_ENABLE_BAG=0
# ---------------------------------------------------------------------------
: ${ROS2_ENABLE_CORE:=1}      # topic, service, node, param, action
: ${ROS2_ENABLE_PKG:=1}       # pkg, interface
: ${ROS2_ENABLE_RUN:=1}       # run, launch
: ${ROS2_ENABLE_BAG:=1}       # bag record/play
: ${ROS2_ENABLE_LIFECYCLE:=0} # lifecycle (less common; off by default)
: ${ROS2_ENABLE_DAEMON:=0}    # daemon (off by default)
: ${ROS2_ENABLE_COLCON:=1}    # colcon helpers
: ${ROS2_ENABLE_ENV:=1}       # workspace source helpers (functions)
: ${ROS2_ENABLE_UTILS:=1}     # misc helpers (doctor, etc.)

# ---------------------------------------------------------------------------
# 3. Helper: safe source wrapper with conflict detection
# ---------------------------------------------------------------------------
_ros2_source() {
  local f="$1"
  [[ -f "$f" ]] && source "$f"
}

# ---------------------------------------------------------------------------
# 3.5 Helper: safe alias wrapper with conflict detection
#   Usage in alias files: _ros2_alias <name> <command>
#   Skips if alias already exists and warns
# ---------------------------------------------------------------------------
_ros2_alias() {
  local name="$1"
  shift
  if alias "$name" >/dev/null 2>&1; then
    echo "[ros2] Warning: alias '$name' already defined, skipping" >&2
  else
    alias "$name"="$*"
  fi
}

# ---------------------------------------------------------------------------
# 4. Load functions first (aliases may depend on them)
# ---------------------------------------------------------------------------
[[ "$ROS2_ENABLE_ENV"    == "1" ]] && _ros2_source "$_ROS2_DIR/functions/workspace.zsh"
[[ "$ROS2_ENABLE_UTILS"  == "1" ]] && _ros2_source "$_ROS2_DIR/functions/helpers.zsh"

# ---------------------------------------------------------------------------
# 5. Load alias modules
# ---------------------------------------------------------------------------
[[ "$ROS2_ENABLE_CORE"      == "1" ]] && {
  _ros2_source "$_ROS2_DIR/aliases/topic.zsh"
  _ros2_source "$_ROS2_DIR/aliases/service.zsh"
  _ros2_source "$_ROS2_DIR/aliases/node.zsh"
  _ros2_source "$_ROS2_DIR/aliases/param.zsh"
  _ros2_source "$_ROS2_DIR/aliases/action.zsh"
}

[[ "$ROS2_ENABLE_PKG"       == "1" ]] && {
  _ros2_source "$_ROS2_DIR/aliases/pkg.zsh"
  _ros2_source "$_ROS2_DIR/aliases/interface.zsh"
}

[[ "$ROS2_ENABLE_RUN"       == "1" ]] && {
  _ros2_source "$_ROS2_DIR/aliases/run.zsh"
  _ros2_source "$_ROS2_DIR/aliases/launch.zsh"
}

[[ "$ROS2_ENABLE_BAG"       == "1" ]] && _ros2_source "$_ROS2_DIR/aliases/bag.zsh"
[[ "$ROS2_ENABLE_LIFECYCLE" == "1" ]] && _ros2_source "$_ROS2_DIR/aliases/lifecycle.zsh"
[[ "$ROS2_ENABLE_DAEMON"    == "1" ]] && _ros2_source "$_ROS2_DIR/aliases/daemon.zsh"
[[ "$ROS2_ENABLE_COLCON"    == "1" ]] && _ros2_source "$_ROS2_DIR/aliases/colcon.zsh"
[[ "$ROS2_ENABLE_UTILS"     == "1" ]] && _ros2_source "$_ROS2_DIR/aliases/utils.zsh"

# ---------------------------------------------------------------------------
# 6. Load completions if available
# ---------------------------------------------------------------------------
[[ -d "$_ROS2_DIR/completions" ]] && fpath+=("$_ROS2_DIR/completions")

# ---------------------------------------------------------------------------
# 7. Cleanup
# ---------------------------------------------------------------------------
unset -f _ros2_source _ros2_alias

# vim: set ft=zsh:
