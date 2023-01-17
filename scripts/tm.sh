#!/bin/bash
# Created by: williamt31
# Created on: 20221216
# Version: 1.2

if [[ ! -f ~/.tmux.conf ]]; then
    ln -s "<network share>" ~/.tmux.conf
fi

menu(){
echo -ne "
\t\tTMux Launcher
\t########################################
\t02) 2 Horizontal Panes
\t03) 3 Horizontal Panes
\t04) 4 Horizontal Panes
\t20) 2 Vertical Panes
\t203 2 Vertical Panes 1/3 split
\t30) 3 Vertical Panes
\t40) 4 Vertical Panes
\t22) 2 Vertical & 2 Horizontal Panes
\t23) 2 Vertical & 3 Horizontal Panes
\t24) 2 Vertical & 4 Horizontal Panes
\t32) 3 Vertical & 2 Horizontal Panes
\t33) 3 Vertical & 3 Horizontal Panes
\t34) 3 Vertical & 4 Horizontal Panes
\t43) 4 Vertical & 3 Horizontal Panes
\t44) 4 Vertical & 4 Horizontal Panes
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
        
        20) SESSION="2_Vertical_33"
            tmux new-session -d -s $SESSION
            tmux split-window -v -t $SESSION:0.0 -p 67
            tmux attach-session -t $SESSION
        ;;
        
        30) SESSION="3_Vertical"
            tmux new-session -d -s $SESSION
            tmux split-window -v -t $SESSION:0.0 -p 33
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        30) SESSION="3_Vertical_logs"
            tmux new-session -d -s $SESSION
            tmux send-keys 'echo ONE'
            tmux split-window -v -t $SESSION:0.0 -p 33
            tmux send-keys 'echo THREE'
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux send-keys 'echo TWO'
            tmux attach-session -t $SESSION
        ;;
        
        40) SESSION="4_Vertical"
            tmux new-session -d -s $SESSION
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.1 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        22) SESSION="2Ver_2Hor"
            tmux new-session -d -s $SESSION
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -h -t $SESSION:0.1 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        23) SESSION="2Ver_3Hor"
            tmux new-session -d -s $SESSION
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.0 -p 33
            tmux split-window -v -t $SESSION:0.1 -p 33
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.1 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        24) SESSION="2Ver_4Hor"
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
        
        
        32) SESSION="3Ver_2Hor"
            tmux new-session -d -s $SESSION
            tmux split-window -h -t $SESSION:0.0 -p 33
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.1 -p 50
            tmux split-window -v -t $SESSION:0.2 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        33) SESSION="3Ver_3Hor"
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
        
        34) SESSION="3Ver_4Hor"
            tmux new-session -d -s $SESSION
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -h -t $SESSION:0.1 -p 50
            tmux split-window -v -t $SESSION:0.0 -p 33
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.1 -p 33
            tmux split-window -v -t $SESSION:0.1 -p 50
            tmux split-window -v -t $SESSION:0.2 -p 33
            tmux split-window -v -t $SESSION:0.2 -p 50
            tmux split-window -v -t $SESSION:0.3 -p 33
            tmux split-window -v -t $SESSION:0.3 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        43) SESSION="4Ver_3Hor"
            tmux new-session -d -s $SESSION
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.1 -p 50
            tmux split-window -h -t $SESSION:0.0 -p 33
            tmux split-window -h -t $SESSION:0.1 -p 33
            tmux split-window -h -t $SESSION:0.2 -p 33
            tmux split-window -h -t $SESSION:0.3 -p 33
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -h -t $SESSION:0.1 -p 50
            tmux split-window -h -t $SESSION:0.2 -p 50
            tmux split-window -h -t $SESSION:0.3 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        44) SESSION="4Ver_4Hor"
            tmux new-session -d -s $SESSION
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.0 -p 50
            tmux split-window -v -t $SESSION:0.1 -p 50
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -h -t $SESSION:0.1 -p 50
            tmux split-window -h -t $SESSION:0.2 -p 50
            tmux split-window -h -t $SESSION:0.3 -p 50
            tmux split-window -h -t $SESSION:0.0 -p 50
            tmux split-window -h -t $SESSION:0.1 -p 50
            tmux split-window -h -t $SESSION:0.2 -p 50
            tmux split-window -h -t $SESSION:0.3 -p 50
            tmux split-window -h -t $SESSION:0.4 -p 50
            tmux split-window -h -t $SESSION:0.5 -p 50
            tmux split-window -h -t $SESSION:0.6 -p 50
            tmux split-window -h -t $SESSION:0.7 -p 50
            tmux attach-session -t $SESSION
        ;;
        
        q) exit ;;
esac
}
menu
