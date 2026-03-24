#!/bin/bash

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
WHITE="\033[1;37m"
NC="\033[0m"

# Draw box line
draw_line() {
    printf "%*s\n" "$(tput cols)" '' | tr ' ' '-'
}

# Center text
center_text() {
    termwidth=$(tput cols)
    padding=$(( (termwidth - ${#1}) / 2 ))
    printf "%*s%s\n" "$padding" "" "$1"
}

while true
do
    clear

    draw_line
    center_text "🚀 SERVER HEALTH DASHBOARD 🚀"
    draw_line

    echo -e "${WHITE}Updated: $(date)${NC}"
    echo ""

    # CPU
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    [[ $(echo "$CPU > 80" | bc -l) -eq 1 ]] && CPU_COLOR=$RED || CPU_COLOR=$GREEN

    # Memory
    MEM=$(free | awk '/Mem/ {printf("%.2f"), $3/$2 * 100}')
    [[ $(echo "$MEM > 80" | bc -l) -eq 1 ]] && MEM_COLOR=$RED || MEM_COLOR=$GREEN

    # Disk
    DISK=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    [[ $DISK -gt 80 ]] && DISK_COLOR=$RED || DISK_COLOR=$GREEN

    # 📊 SYSTEM BOX
    echo -e "${YELLOW}📊 SYSTEM STATS${NC}"
    draw_line
    printf " CPU Usage    : ${CPU_COLOR}%s%%${NC}\n" "$CPU"
    printf " Memory Usage : ${MEM_COLOR}%s%%${NC}\n" "$MEM"
    printf " Disk Usage   : ${DISK_COLOR}%s%%${NC}\n" "$DISK"
    draw_line

    echo ""

    # ⚙️ PROCESSES BOX
    echo -e "${YELLOW}⚙️ TOP PROCESSES${NC}"
    draw_line
    ps -eo pid,cmd,%cpu --sort=-%cpu | head -n 6
    draw_line

    echo ""

    # 🌐 NETWORK BOX
    echo -e "${YELLOW}🌐 NETWORK INFO${NC}"
    draw_line
    ip a | grep inet | grep -v 127.0.0.1
    draw_line

    echo ""

    # Logging
    echo "$(date) CPU:$CPU MEM:$MEM DISK:$DISK" >> system.log

    echo -e "${CYAN}Press 'q' to exit | Auto-refreshing...${NC}"

    # 🔥 INTERACTIVE INPUT (press q to quit)
    read -t 3 -n 1 key
    if [[ $key == "q" ]]; then
        clear
        echo "Exiting Dashboard..."
        break
    fi
done
