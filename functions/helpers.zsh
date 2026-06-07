#!/usr/bin/env zsh
# vim: set ft=zsh:
# =============================================================================
# functions/helpers.zsh — helper functions for common ROS2 operations
# =============================================================================

# ---------------------------------------------------------------------------
# rte — Smart ros2 topic echo with optional type
# Usage: rte <topic_name> [type]
#   If type not provided, auto-detects via ros2 topic type
# ---------------------------------------------------------------------------
rte() {
  local topic="${1:-}"
  if [[ -z "$topic" ]]; then
    echo "Usage: rte <topic_name> [type]" >&2
    return 1
  fi

  local msg_type="${2:-}"
  if [[ -z "$msg_type" ]]; then
    msg_type=$(ros2 topic type "$topic" 2>/dev/null)
    if [[ -z "$msg_type" ]]; then
      echo "[ros2] Could not determine type for topic: $topic" >&2
      return 1
    fi
  fi

  echo "[ros2] ros2 topic echo $topic $msg_type"
  ros2 topic echo "$topic" "$msg_type"
}

# ---------------------------------------------------------------------------
# rthz — ros2 topic hz with sensible defaults
# Usage: rthz <topic_name> [window_size]
# ---------------------------------------------------------------------------
rthz() {
  local topic="${1:-}"
  local window="${2:-}"
  if [[ -z "$topic" ]]; then
    echo "Usage: rthz <topic_name> [window_size]" >&2
    return 1
  fi

  if [[ -n "$window" ]]; then
    ros2 topic hz --window "$window" "$topic"
  else
    ros2 topic hz "$topic"
  fi
}

# ---------------------------------------------------------------------------
# rrun — ros2 run with --ros-args auto-detection
# Usage: rrun <pkg> <exe> [param1:=val1 param2:=val2 ...]
#   Automatically appends --ros-args -p for key:=value pairs
# ---------------------------------------------------------------------------
rrun() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: rrun <package> <executable> [param1:=value1 ...]" >&2
    return 1
  fi

  local pkg="$1"
  local exe="$2"
  shift 2

  local ros_args=()
  local other_args=()

  for arg in "$@"; do
    if [[ "$arg" == *:=* ]]; then
      ros_args+=(-p "$arg")
    else
      other_args+=("$arg")
    fi
  done

  if [[ ${#ros_args} -gt 0 ]]; then
    echo "[ros2] ros2 run $pkg $exe --ros-args ${ros_args[*]} ${other_args[*]}"
    ros2 run "$pkg" "$exe" --ros-args "${ros_args[@]}" "${other_args[@]}"
  else
    echo "[ros2] ros2 run $pkg $exe ${other_args[*]}"
    ros2 run "$pkg" "$exe" "${other_args[@]}"
  fi
}

# ---------------------------------------------------------------------------
# rbag — Safe bag record wrapper
# Usage: rbag [-o output] <topic1> [topic2 ...]
#   Defaults to ~/ros2_bags/bag_$(date +%Y%m%d_%H%M%S)
# ---------------------------------------------------------------------------
rbag() {
  local out=""
  local topics=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -o|--output)
        out="$2"
        shift 2
        ;;
      -*)
        echo "Unknown option: $1" >&2
        return 1
        ;;
      *)
        topics+=("$1")
        shift
        ;;
    esac
  done

  if [[ ${#topics} -eq 0 ]]; then
    echo "Usage: rbag [-o output] <topic1> [topic2 ...]" >&2
    return 1
  fi

  if [[ -z "$out" ]]; then
    local bag_dir="$HOME/ros2_bags"
    [[ -d "$bag_dir" ]] || mkdir -p "$bag_dir"
    out="$bag_dir/bag_$(date +%Y%m%d_%H%M%S)"
  fi

  echo "[ros2] Recording to: $out"
  echo "[ros2] Topics: ${topics[*]}"
  ros2 bag record -o "$out" "${topics[@]}"
}

# ---------------------------------------------------------------------------
# rbagplay — Bag play with optional rate and loop
# Usage: rbagplay <bag_path> [rate] [--loop]
# ---------------------------------------------------------------------------
rbagplay() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: rbagplay <bag_path> [rate] [--loop]" >&2
    return 1
  fi

  local bag="$1"
  shift

  local rate=""
  local loop=""

  for arg in "$@"; do
    if [[ "$arg" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      rate="--rate $arg"
    elif [[ "$arg" == "--loop" ]] || [[ "$arg" == "-l" ]]; then
      loop="--loop"
    fi
  done

  echo "[ros2] ros2 bag play $rate $loop $bag"
  ros2 bag play $rate $loop "$bag"
}

# ---------------------------------------------------------------------------
# rkill — Kill ROS2 nodes by name pattern (safe: asks for confirmation)
# Usage: rkill <pattern>
# ---------------------------------------------------------------------------
rkill() {
  local pattern="${1:-}"
  if [[ -z "$pattern" ]]; then
    echo "Usage: rkill <node_name_pattern>" >&2
    return 1
  fi

  local nodes
  nodes=$(ros2 node list 2>/dev/null | grep "$pattern")
  if [[ -z "$nodes" ]]; then
    echo "[ros2] No nodes matched pattern: $pattern" >&2
    return 1
  fi

  echo "[ros2] Matched nodes:"
  echo "$nodes"
  echo -n "Kill these nodes? [y/N] "
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "$nodes" | while IFS= read -r node; do
      local pid
      pid=$(pgrep -f "$node" | head -n1)
      if [[ -n "$pid" ]]; then
        echo "[ros2] Killing $node (PID $pid)"
        kill "$pid"
      fi
    done
  else
    echo "[ros2] Cancelled."
  fi
}
