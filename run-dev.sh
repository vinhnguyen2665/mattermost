#!/usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}        Mattermost Development Environment          ${NC}"
echo -e "${CYAN}====================================================${NC}"

MODE="${1:-}"

if [ -z "$MODE" ]; then
    echo -e "Chọn chế độ chạy dev:"
    echo -e "  ${GREEN}1)${NC} Web App Dev Server (Hot-reload, cổng 9005 / proxy 8065) [Mặc định]"
    echo -e "  ${GREEN}2)${NC} Web App Watch Mode (npm run run)"
    echo -e "  ${GREEN}3)${NC} Full Stack (Docker DB + Server Go + Web App)"
    echo -e "  ${GREEN}4)${NC} Dừng tất cả (Stop Server & Client)"
    read -rp "Nhập lựa chọn [1-4] (mặc định 1): " CHOICE
    case "$CHOICE" in
        2) MODE="watch" ;;
        3) MODE="full" ;;
        4) MODE="stop" ;;
        *) MODE="webapp" ;;
    esac
fi

case "$MODE" in
    webapp|1)
        echo -e "\n${YELLOW}>>> Khởi chạy Web App Dev Server (Hot-reload)...${NC}"
        cd "${PROJECT_ROOT}/webapp"
        if [ ! -d "node_modules" ]; then
            echo -e "${YELLOW}Chưa có node_modules, đang chạy npm install...${NC}"
            npm install
        fi
        npm run dev-server
        ;;

    watch|2)
        echo -e "\n${YELLOW}>>> Khởi chạy Web App ở chế độ Watch Mode...${NC}"
        cd "${PROJECT_ROOT}/webapp"
        if [ ! -d "node_modules" ]; then
            echo -e "${YELLOW}Chưa có node_modules, đang chạy npm install...${NC}"
            npm install
        fi
        npm run run
        ;;

    full|3)
        echo -e "\n${YELLOW}>>> 1/2 Khởi động Docker containers...${NC}"
        cd "${PROJECT_ROOT}/server"
        make start-docker

        echo -e "\n${YELLOW}>>> 2/2 Khởi động Backend Server & Web App Client...${NC}"
        make run
        ;;

    stop|4)
        echo -e "\n${YELLOW}>>> Đang dừng Mattermost Server và Web App...${NC}"
        cd "${PROJECT_ROOT}/server"
        make stop-server || true
        make stop-client || true
        echo -e "${GREEN}Đã dừng thành công!${NC}"
        ;;

    *)
        echo -e "${RED}Lựa chọn không hợp lệ: $MODE${NC}"
        echo -e "Sử dụng: ./run-dev.sh [webapp|watch|full|stop]"
        exit 1
        ;;
esac
