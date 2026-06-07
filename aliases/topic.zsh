#!/usr/bin/env zsh
# vim: set ft=zsh:
# =============================================================================
# aliases/topic.zsh — ros2 topic shortcuts
# Prefix: rt (ros2 topic)
# =============================================================================

alias rtl='ros2 topic list'                    # List all topics
alias rtlt='ros2 topic list -t'                # List topics with types
alias rte='ros2 topic echo'                    # Echo topic (needs arg)
alias rth='ros2 topic hz'                      # Publish rate (needs arg)
alias rtbw='ros2 topic bw'                     # Bandwidth (needs arg)
alias rti='ros2 topic info'                    # Topic info (needs arg)
alias rtt='ros2 topic type'                    # Topic type (needs arg)
alias rtfind='ros2 topic find'                 # Find topics by type (needs arg)
alias rtd='ros2 topic delay'                   # Check msg delay (needs arg)
alias rtp='ros2 topic pub'                     # Publish to topic (needs arg)

# Safe guards: none of these are destructive by default
