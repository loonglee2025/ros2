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
# 2.5 Distribution compatibility layer
#    ROS 2 Foxy (LTS, EOL June 2023) lacks some CLI verbs present in
#    Humble/Jazzy/Rolling.  Jazzy adds new verbs not in Foxy/Humble.
#    When ROS2_DISTRO is detected (or the user explicitly exports it),
#    aliases that depend on missing verbs are automatically disabled
#    and safe fallbacks are loaded instead.
# ---------------------------------------------------------------------------
: ${ROS2_DISTRO:=""}

# Auto-detect distro if not set
if [[ -z "$ROS2_DISTRO" ]] && [[ -n "$ROS_DISTRO" ]]; then
  ROS2_DISTRO="$ROS_DISTRO"
fi

# Normalise to lower-case
ROS2_DISTRO="${ROS2_DISTRO:l}"

# Version comparison helper: returns 0 if current distro >= reference
# Usage: _ros2_distro_at_least "humble"  → 0 if ROS2_DISTRO is humble/jazzy/rolling
_ros2_distro_at_least() {
  local ref="${1:l}"
  local current="$ROS2_DISTRO"
  [[ -z "$current" ]] && return 1  # unknown distro → false

  # Ordered list of distros (oldest to newest)
  local -a distros=(foxy galactic humble iron jazzy rolling)
  local ref_idx=-1 current_idx=-1
  local i=1
  for d in "${distros[@]}"; do
    [[ "$d" == "$ref" ]] && ref_idx=$i
    [[ "$d" == "$current" ]] && current_idx=$i
    ((i++))
  done

  # If either not found, treat unknown as "newer"
  [[ $ref_idx -eq -1 ]] && return 0
  [[ $current_idx -eq -1 ]] && return 0

  [[ $current_idx -ge $ref_idx ]]
}

# Foxy feature-guard helper (legacy, kept for compatibility)
_ros2_foxy_guard() {
  local verb="$1"
  if [[ "$ROS2_DISTRO" == "foxy" ]]; then
    return 1
  fi
  return 0
}

# Foxy-safe alias wrapper: skips the alias on Foxy if the verb is missing
_ros2_foxy_alias() {
  local name="$1"
  local cmd="$2"
  local verb="${3:-}"

  if [[ -n "$verb" ]] && [[ "$ROS2_DISTRO" == "foxy" ]]; then
    # Verb explicitly known to be missing on Foxy
    return 0
  fi

  if alias "$name" >/dev/null 2>&1; then
    echo "[ros2] Warning: alias '$name' already defined, skipping" >&2
  else
    alias "$name"="$cmd"
  fi
}

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

# Foxy compatibility aliases (loaded only when ROS2_DISTRO=foxy)
_ros2_source "$_ROS2_DIR/aliases/foxy-compat.zsh"

# Jazzy+ compatibility aliases (loaded only when ROS2_DISTRO >= jazzy)
_ros2_source "$_ROS2_DIR/aliases/jazzy-compat.zsh"

# ---------------------------------------------------------------------------
# 6. Load completions if available
# ---------------------------------------------------------------------------
[[ -d "$_ROS2_DIR/completions" ]] && fpath+=("$_ROS2_DIR/completions")

# ---------------------------------------------------------------------------
# 7. Cleanup
# ---------------------------------------------------------------------------
unset -f _ros2_source _ros2_alias _ros2_foxy_guard _ros2_foxy_alias _ros2_distro_at_least

# vim: set ft=zsh:
