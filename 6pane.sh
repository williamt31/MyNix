#!/bin/bash
# Creates 6 tmux panels in a 2 across by 3 down grid.
SESSION="6pane"
tmux new-session -d -s $SESSION
tmux split-window -h -t $SESSION:0.0
tmux split-window -v -t $SESSION:0.0 -p 33
tmux split-window -v -t $SESSION:0.1 -p 33
tmux split-window -v -t $SESSION:0.0 -p 50
tmux split-window -v -t $SESSION:0.1 -p 50
tmux attach-session -t $SESSION
