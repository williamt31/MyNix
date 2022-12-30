#!/bin/bash
# Created by: williamt31
# Created on: 20221216
# Version: 1.0

menu(){
echo -ne "
\t\tTMux Launcher
\t########################################
\t02) 2 Horizontal Panes
\t03) 3 Horizontal Panes
\t04) 4 Horizontal Panes
\t20) 2 Vertical Panes
\t30) 3 Vertical Panes
\t40) 4 Vertical Panes
\t22) 2 Vertical & 2 Horizontal Panes
\t23) 2 Vertical & 3 Horizontal Panes
\t24) 2 Vertical & 4 Horizontal Panes
\t33) 3 Vertical & 3 Horizontal Panes
\t q) Quit
\t########################################
\tEnter Option: "
        read a

case "$a" in
        02) SESSION="2_Horizontal"
            tmux new-session -d -s $SESSION
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        03) SESSION="3_Horizontal"
            tmux new-session -d -s $SESSION
            tmux split-window -h -t $SESSION:0.0 -p 33
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        04) SESSION="4_Horizontal"
            tmux new-session -d -s $SESSION
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -h -t $SESSION:0.1 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        20) SESSION="2_Vertical"
            tmux new-session -d -s $SESSION
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        30) SESSION="3_Vertical"
            tmux new-session -d -s $SESSION
            tmux split-window -v -t $SESSION:0.0 -p 33
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        40) SESSION="4_Vertical"
            tmux new-session -d -s $SESSION
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.1 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        22) SESSION="2Hor_2Ver"
            tmux new-session -d -s $SESSION
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -h -t $SESSION:0.1 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        23) SESSION="3Hor_2Ver"
            tmux new-session -d -s $SESSION
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.0 -p 33
            tmux split-window -v -t $SESSION:0.1 -p 33
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.1 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        24) SESSION="4Hor_2Ver"
            tmux new-session -d -s $SESSION
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.1 -p 50
            tmux split-window -v -t $SESSION:0.1 -p 50
            tmux split-window -v -t $SESSION:0.2 -p 50
            tmux split-window -v -t $SESSION:0.4 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        33) SESSION="3Hor_3Ver"
            tmux new-session -d -s $SESSION
            tmux split-window -h -t $SESSION:0.0 -p 33
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.0 -p 33
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.1 -p 33
            tmux split-window -v -t $SESSION:0.1 -p 50
            tmux split-window -v -t $SESSION:0.2 -p 33
            tmux split-window -v -t $SESSION:0.2 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        q) exit ;;
esac
}
menu
