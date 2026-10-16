#!/usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}        Mattermost Production Build / Packaging     ${NC}"
echo -e "${CYAN}====================================================${NC}"

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
    echo -e "Chọn phương thức đóng gói:"
    echo -e "  ${GREEN}1)${NC} Chỉ đóng gói Web App (tạo dist tĩnh để deploy lên server) [Mặc định]"
    echo -e "  ${GREEN}2)${NC} Đóng gói toàn bộ Server + Web App (.tar.gz hoàn chỉnh)"
    read -rp "Nhập lựa chọn [1-2] (mặc định 1): " CHOICE
    case "$CHOICE" in
        2) TARGET="full" ;;
        *) TARGET="webapp" ;;
    esac
fi

case "$TARGET" in
    webapp|1)
        echo -e "\n${YELLOW}>>> [1/2] Kiểm tra dependencies của Web App...${NC}"
        cd "${PROJECT_ROOT}/webapp"
        if [ ! -d "node_modules" ]; then
            echo -e "${YELLOW}Chưa có node_modules, đang chạy npm install...${NC}"
            npm install
        fi

        echo -e "\n${YELLOW}>>> [2/2] Đang build Web App cho Production...${NC}"
        npm run build

        DIST_DIR="${PROJECT_ROOT}/webapp/channels/dist"
        if [ -d "$DIST_DIR" ]; then
            echo -e "\n${GREEN}====================================================${NC}"
            echo -e "${GREEN} Build Web App Production thành công!${NC}"
            echo -e "${GREEN} Thư mục output: ${DIST_DIR}${NC}"
            echo -e "${GREEN}====================================================${NC}"
            echo -e "Để deploy lên Mattermost Server:"
            echo -e "Copy toàn bộ thư mục trên vào thư mục 'client/' của server Mattermost."
            echo -e "Ví dụ:"
            echo -e "  rsync -avz --delete ${DIST_DIR}/ user@your-server:/opt/mattermost/client/\n"
        fi
        ;;

    full|2)
        echo -e "\n${YELLOW}>>> Đang đóng gói toàn bộ Mattermost (Server + Web App)...${NC}"
        cd "${PROJECT_ROOT}/server"
        make package

        echo -e "\n${GREEN}====================================================${NC}"
        echo -e "${GREEN} Đóng gói toàn bộ hệ thống hoàn tất!${NC}"
        echo -e "${GREEN} File nén đã được tạo trong thư mục server/dist/${NC}"
        echo -e "${GREEN}====================================================${NC}\n"
        ;;

    *)
        echo -e "${RED}Lựa chọn không hợp lệ: $TARGET${NC}"
        echo -e "Sử dụng: ./build-prod.sh [webapp|full]"
        exit 1
        ;;
esac
