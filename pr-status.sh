 #!/bin/bash

# PR Status Script - Quick overview of all pending PRs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 Pull Request Status Overview${NC}"
echo -e "${BLUE}==============================${NC}"

REPO_URL="https://github.com/sabady/mongo-kafka-api-frontend"

# Get all Dependabot branches
DEPENDABOT_BRANCHES=($(git branch -r | grep "dependabot" | sed 's/remotes\/origin\///' | sort))

echo -e "${YELLOW}Found ${#DEPENDABOT_BRANCHES[@]} Dependabot branches${NC}"
echo ""

# Categorize branches
DOCKER_BRANCHES=()
ACTIONS_BRANCHES=()
NPM_BRANCHES=()

for branch in "${DEPENDABOT_BRANCHES[@]}"; do
    if [[ $branch == *"docker"* ]]; then
        DOCKER_BRANCHES+=("$branch")
    elif [[ $branch == *"github_actions"* ]]; then
        ACTIONS_BRANCHES+=("$branch")
    elif [[ $branch == *"npm_and_yarn"* ]]; then
        NPM_BRANCHES+=("$branch")
    fi
done

# Function to show branch info
show_branch_info() {
    local branch=$1
    local category=$2
    local emoji=$3
    
    # Extract package name from branch
    local package_name=$(echo "$branch" | sed 's/.*dependabot\/[^/]*\///' | sed 's/-[0-9].*//')
    
    echo -e "${emoji} ${CYAN}${category}:${NC} ${package_name}"
    echo -e "   ${YELLOW}Branch:${NC} ${branch}"
    echo -e "   ${BLUE}PR Link:${NC} ${REPO_URL}/compare/main...${branch}"
    echo ""
}

# Show Docker updates
if [ ${#DOCKER_BRANCHES[@]} -gt 0 ]; then
    echo -e "${GREEN}🐳 Docker Updates (${#DOCKER_BRANCHES[@]}):${NC}"
    for branch in "${DOCKER_BRANCHES[@]}"; do
        show_branch_info "$branch" "Docker" "🐳"
    done
fi

# Show GitHub Actions updates
if [ ${#ACTIONS_BRANCHES[@]} -gt 0 ]; then
    echo -e "${GREEN}⚡ GitHub Actions Updates (${#ACTIONS_BRANCHES[@]}):${NC}"
    for branch in "${ACTIONS_BRANCHES[@]}"; do
        show_branch_info "$branch" "GitHub Actions" "⚡"
    done
fi

# Show NPM/Yarn updates
if [ ${#NPM_BRANCHES[@]} -gt 0 ]; then
    echo -e "${GREEN}📦 NPM/Yarn Updates (${#NPM_BRANCHES[@]}):${NC}"
    for branch in "${NPM_BRANCHES[@]}"; do
        show_branch_info "$branch" "NPM/Yarn" "📦"
    done
fi

echo -e "${BLUE}🔗 Quick Links:${NC}"
echo -e "${YELLOW}All PRs:${NC} ${REPO_URL}/pulls"
echo -e "${YELLOW}Dependabot PRs:${NC} ${REPO_URL}/pulls?q=is%3Apr+is%3Aopen+author%3Aapp%2Fdependabot"
echo -e "${YELLOW}Repository Settings:${NC} ${REPO_URL}/settings"
echo ""

echo -e "${PURPLE}💡 Recommendations:${NC}"
echo -e "${GREEN}1.${NC} Use the consolidate-prs.sh script to merge all updates into one PR"
echo -e "${GREEN}2.${NC} Review each update category separately if you prefer"
echo -e "${GREEN}3.${NC} Close individual PRs after merging the consolidated one"
echo -e "${GREEN}4.${NC} Consider setting up auto-merge for Dependabot PRs in the future"
echo ""

echo -e "${BLUE}🚀 Next Steps:${NC}"
echo -e "${YELLOW}Run:${NC} ./consolidate-prs.sh"
echo -e "${YELLOW}Or:${NC} Visit ${REPO_URL}/pulls to manage PRs manually"
