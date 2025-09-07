#!/bin/bash

# Consolidate Pending PRs Script
# This script helps consolidate all pending pull requests

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Consolidating Pending Pull Requests${NC}"
echo -e "${BLUE}=====================================${NC}"

# Repository information
REPO_URL="https://github.com/sabady/mongo-kafka-api-frontend"
REPO_OWNER="sabady"
REPO_NAME="mongo-kafka-api-frontend"

echo -e "${YELLOW}Repository: ${REPO_URL}${NC}"
echo ""

# Function to categorize branches
categorize_branches() {
    echo -e "${BLUE}📋 Categorizing branches...${NC}"
    
    # Docker updates
    DOCKER_BRANCHES=($(git branch -r | grep "dependabot/docker" | sed 's/remotes\/origin\///' | grep -v "github_actions"))
    
    # GitHub Actions updates
    ACTIONS_BRANCHES=($(git branch -r | grep "dependabot/github_actions" | sed 's/remotes\/origin\///'))
    
    # NPM/Yarn updates
    NPM_BRANCHES=($(git branch -r | grep "dependabot/npm_and_yarn" | sed 's/remotes\/origin\///'))
    
    echo -e "${GREEN}Found ${#DOCKER_BRANCHES[@]} Docker update branches${NC}"
    echo -e "${GREEN}Found ${#ACTIONS_BRANCHES[@]} GitHub Actions update branches${NC}"
    echo -e "${GREEN}Found ${#NPM_BRANCHES[@]} NPM/Yarn update branches${NC}"
    echo ""
}

# Function to show branch details
show_branch_details() {
    local branch=$1
    local category=$2
    
    echo -e "${PURPLE}📦 ${category}: ${branch}${NC}"
    
    # Get the commit message from the branch
    local commit_msg=$(git log origin/main..origin/$branch --oneline | head -1 2>/dev/null || echo "No commits found")
    echo -e "   ${YELLOW}Commit: ${commit_msg}${NC}"
    
    # Check if there are conflicts
    git fetch origin $branch >/dev/null 2>&1
    if git merge-base --is-ancestor origin/main origin/$branch 2>/dev/null; then
        echo -e "   ${GREEN}✅ No conflicts detected${NC}"
    else
        echo -e "   ${RED}⚠️  Potential conflicts detected${NC}"
    fi
    echo ""
}

# Function to create consolidated PR
create_consolidated_pr() {
    echo -e "${BLUE}🔧 Creating consolidated update branch...${NC}"
    
    # Create a new branch for consolidated updates
    CONSOLIDATED_BRANCH="consolidated-dependency-updates-$(date +%Y%m%d-%H%M%S)"
    git checkout -b "$CONSOLIDATED_BRANCH"
    
    echo -e "${YELLOW}Created branch: ${CONSOLIDATED_BRANCH}${NC}"
    
    # Merge all non-conflicting branches
    local merged_count=0
    local conflict_count=0
    
    # Process Docker updates
    for branch in "${DOCKER_BRANCHES[@]}"; do
        echo -e "${BLUE}Processing Docker update: ${branch}${NC}"
        if git merge origin/$branch --no-edit 2>/dev/null; then
            echo -e "${GREEN}✅ Merged ${branch}${NC}"
            ((merged_count++))
        else
            echo -e "${RED}❌ Conflict in ${branch} - skipping${NC}"
            git merge --abort 2>/dev/null || true
            ((conflict_count++))
        fi
    done
    
    # Process GitHub Actions updates
    for branch in "${ACTIONS_BRANCHES[@]}"; do
        echo -e "${BLUE}Processing GitHub Actions update: ${branch}${NC}"
        if git merge origin/$branch --no-edit 2>/dev/null; then
            echo -e "${GREEN}✅ Merged ${branch}${NC}"
            ((merged_count++))
        else
            echo -e "${RED}❌ Conflict in ${branch} - skipping${NC}"
            git merge --abort 2>/dev/null || true
            ((conflict_count++))
        fi
    done
    
    # Process NPM/Yarn updates
    for branch in "${NPM_BRANCHES[@]}"; do
        echo -e "${BLUE}Processing NPM/Yarn update: ${branch}${NC}"
        if git merge origin/$branch --no-edit 2>/dev/null; then
            echo -e "${GREEN}✅ Merged ${branch}${NC}"
            ((merged_count++))
        else
            echo -e "${RED}❌ Conflict in ${branch} - skipping${NC}"
            git merge --abort 2>/dev/null || true
            ((conflict_count++))
        fi
    done
    
    echo ""
    echo -e "${GREEN}📊 Consolidation Summary:${NC}"
    echo -e "${GREEN}   ✅ Successfully merged: ${merged_count} branches${NC}"
    echo -e "${RED}   ❌ Conflicts (skipped): ${conflict_count} branches${NC}"
    
    # Commit the consolidated changes
    if [ $merged_count -gt 0 ]; then
        git add .
        git commit -m "chore: consolidate dependency updates

- Merged ${merged_count} dependency update branches
- Skipped ${conflict_count} branches due to conflicts
- Consolidated updates for better maintainability

This PR consolidates multiple Dependabot updates into a single, reviewable change."
        
        # Push the consolidated branch
        git push origin "$CONSOLIDATED_BRANCH"
        
        echo ""
        echo -e "${GREEN}🎉 Consolidated branch created successfully!${NC}"
        echo -e "${BLUE}📋 Next steps:${NC}"
        echo -e "1. Create a PR: ${REPO_URL}/compare/main...${CONSOLIDATED_BRANCH}"
        echo -e "2. Review the consolidated changes"
        echo -e "3. Merge the PR once approved"
        echo -e "4. Close individual Dependabot PRs after merging"
        
        return 0
    else
        echo -e "${RED}❌ No branches could be merged. All had conflicts.${NC}"
        git checkout main
        git branch -D "$CONSOLIDATED_BRANCH" 2>/dev/null || true
        return 1
    fi
}

# Function to close individual PRs
close_individual_prs() {
    echo -e "${BLUE}🗑️  Instructions for closing individual PRs:${NC}"
    echo ""
    echo -e "${YELLOW}After merging the consolidated PR, you can close these individual PRs:${NC}"
    
    # List all Dependabot branches
    ALL_DEPENDABOT_BRANCHES=($(git branch -r | grep "dependabot" | sed 's/remotes\/origin\///'))
    
    for branch in "${ALL_DEPENDABOT_BRANCHES[@]}"; do
        echo -e "${PURPLE}   - ${branch}${NC}"
    done
    
    echo ""
    echo -e "${BLUE}To close them via GitHub web interface:${NC}"
    echo -e "1. Go to: ${REPO_URL}/pulls"
    echo -e "2. Find each Dependabot PR"
    echo -e "3. Add comment: 'Consolidated in #XXX' (replace XXX with consolidated PR number)"
    echo -e "4. Close the PR"
}

# Main execution
main() {
    # Ensure we're on main branch
    git checkout main
    git pull origin main
    
    # Categorize branches
    categorize_branches
    
    # Show details for each category
    echo -e "${BLUE}📋 Branch Details:${NC}"
    echo ""
    
    for branch in "${DOCKER_BRANCHES[@]}"; do
        show_branch_details "$branch" "Docker Update"
    done
    
    for branch in "${ACTIONS_BRANCHES[@]}"; do
        show_branch_details "$branch" "GitHub Actions Update"
    done
    
    for branch in "${NPM_BRANCHES[@]}"; do
        show_branch_details "$branch" "NPM/Yarn Update"
    done
    
    # Ask user what they want to do
    echo -e "${YELLOW}What would you like to do?${NC}"
    echo -e "${BLUE}1) Create consolidated PR (recommended)${NC}"
    echo -e "${BLUE}2) Show instructions for manual consolidation${NC}"
    echo -e "${BLUE}3) Exit${NC}"
    echo ""
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1)
            create_consolidated_pr
            close_individual_prs
            ;;
        2)
            echo -e "${BLUE}📋 Manual Consolidation Instructions:${NC}"
            echo ""
            echo -e "${YELLOW}1. Create a new branch:${NC}"
            echo -e "   git checkout -b consolidated-updates"
            echo ""
            echo -e "${YELLOW}2. Merge each branch one by one:${NC}"
            for branch in "${ALL_DEPENDABOT_BRANCHES[@]}"; do
                echo -e "   git merge origin/$branch"
            done
            echo ""
            echo -e "${YELLOW}3. Push and create PR:${NC}"
            echo -e "   git push origin consolidated-updates"
            echo -e "   # Then create PR via GitHub web interface"
            ;;
        3)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting...${NC}"
            exit 1
            ;;
    esac
}

# Run main function
main
