#!/usr/bin/env zsh
# vim: set ft=zsh:
# =============================================================================
# ros2-shortcuts — Oh My Zsh plugin for ROS 2 CLI
# https://github.com/loonglee2025/ros2-shortcuts
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
local _ROS2SC_DIR="${0:A:h}"

# ---------------------------------------------------------------------------
# 2. Default feature flags (override before sourcing if desired)
#    Example in ~/.zshrc BEFORE plugins=(... ros2-shortcuts ...):
#      export ROS2SC_ENABLE_BAG=0
# ---------------------------------------------------------------------------
: ${ROS2SC_ENABLE_CORE:=1}      # topic, service, node, param, action
: ${ROS2SC_ENABLE_PKG:=1}       # pkg, interface
: ${ROS2SC_ENABLE_RUN:=1}       # run, launch
: ${ROS2SC_ENABLE_BAG:=1}       # bag record/play
: ${ROS2SC_ENABLE_LIFECYCLE:=0} # lifecycle (less common; off by default)
: ${ROS2SC_ENABLE_DAEMON:=0}    # daemon (off by default)
: ${ROS2SC_ENABLE_COLCON:=1}    # colcon helpers
: ${ROS2SC_ENABLE_ENV:=1}       # workspace source helpers (functions)
: ${ROS2SC_ENABLE_UTILS:=1}     # misc helpers (doctor, etc.)

# ---------------------------------------------------------------------------
# 3. Helper: safe source wrapper
# ---------------------------------------------------------------------------
_ros2sc_source() {
  local f="$1"
  [[ -f "$f" ]] && source "$f"
}

# ---------------------------------------------------------------------------
# 4. Load functions first (aliases may depend on them)
# ---------------------------------------------------------------------------
[[ "$ROS2SC_ENABLE_ENV"    == "1" ]] && _ros2sc_source "$_ROS2SC_DIR/functions/workspace.zsh"
[[ "$ROS2SC_ENABLE_UTILS"  == "1" ]] && _ros2sc_source "$_ROS2SC_DIR/functions/helpers.zsh"

# ---------------------------------------------------------------------------
# 5. Load alias modules
# ---------------------------------------------------------------------------
[[ "$ROS2SC_ENABLE_CORE"      == "1" ]] && {
  _ros2sc_source "$_ROS2SC_DIR/aliases/topic.zsh"
  _ros2sc_source "$_ROS2SC_DIR/aliases/service.zsh"
  _ros2sc_source "$_ROS2SC_DIR/aliases/node.zsh"
  _ros2sc_source "$_ROS2SC_DIR/aliases/param.zsh"
  _ros2sc_source "$_ROS2SC_DIR/aliases/action.zsh"
}

[[ "$ROS2SC_ENABLE_PKG"       == "1" ]] && {
  _ros2sc_source "$_ROS2SC_DIR/aliases/pkg.zsh"
  _ros2sc_source "$_ROS2SC_DIR/aliases/interface.zsh"
}

[[ "$ROS2SC_ENABLE_RUN"       == "1" ]] && {
  _ros2sc_source "$_ROS2SC_DIR/aliases/run.zsh"
  _ros2sc_source "$_ROS2SC_DIR/aliases/launch.zsh"
}

[[ "$ROS2SC_ENABLE_BAG"       == "1" ]] && _ros2sc_source "$_ROS2SC_DIR/aliases/bag.zsh"
[[ "$ROS2SC_ENABLE_LIFECYCLE" == "1" ]] && _ros2sc_source "$_ROS2SC_DIR/aliases/lifecycle.zsh"
[[ "$ROS2SC_ENABLE_DAEMON"    == "1" ]] && _ros2sc_source "$_ROS2SC_DIR/aliases/daemon.zsh"
[[ "$ROS2SC_ENABLE_COLCON"    == "1" ]] && _ros2sc_source "$_ROS2SC_DIR/aliases/colcon.zsh"
[[ "$ROS2SC_ENABLE_UTILS"     == "1" ]] && _ros2sc_source "$_ROS2SC_DIR/aliases/utils.zsh"

# ---------------------------------------------------------------------------
# 6. Load completions if available
# ---------------------------------------------------------------------------
[[ -d "$_ROS2SC_DIR/completions" ]] && fpath+=("$_ROS2SC_DIR/completions")

# ---------------------------------------------------------------------------
# 7. Cleanup
# ---------------------------------------------------------------------------
unset -f _ros2sc_source

# vim: set ft=zsh:
