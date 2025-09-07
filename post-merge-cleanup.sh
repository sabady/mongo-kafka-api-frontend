#!/bin/bash

# Post-Merge Cleanup Script
# This script automates the cleanup process after merging all PRs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Post-Merge Cleanup Script${NC}"
echo -e "${BLUE}============================${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run command with error handling
run_command() {
    local description="$1"
    local command="$2"
    
    echo -e "${BLUE}📋 $description${NC}"
    if eval "$command"; then
        echo -e "${GREEN}✅ $description completed${NC}"
    else
        echo -e "${RED}❌ $description failed${NC}"
        return 1
    fi
    echo ""
}

# Function to check git status
check_git_status() {
    echo -e "${BLUE}🔍 Checking Git Status${NC}"
    
    # Check if we're on main branch
    current_branch=$(git branch --show-current)
    if [[ "$current_branch" != "main" ]]; then
        echo -e "${YELLOW}⚠️  Not on main branch. Switching to main...${NC}"
        git checkout main
    fi
    
    # Check if working directory is clean
    if [[ -n $(git status --porcelain) ]]; then
        echo -e "${YELLOW}⚠️  Working directory has uncommitted changes:${NC}"
        git status --short
        echo -e "${YELLOW}Please commit or stash changes before running cleanup.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Git status is clean${NC}"
    echo ""
}

# Function to update local repository
update_repository() {
    echo -e "${BLUE}🔄 Updating Local Repository${NC}"
    
    # Pull latest changes
    run_command "Pulling latest changes from origin" "git pull origin main"
    
    # Verify we're up to date
    local commits_behind=$(git rev-list --count HEAD..origin/main)
    if [[ $commits_behind -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  Local branch is $commits_behind commits behind origin/main${NC}"
        run_command "Pulling additional changes" "git pull origin main"
    else
        echo -e "${GREEN}✅ Local repository is up to date${NC}"
    fi
    echo ""
}

# Function to clean up branches
cleanup_branches() {
    echo -e "${BLUE}🧹 Cleaning Up Branches${NC}"
    
    # Delete merged branches locally
    echo -e "${BLUE}📋 Deleting merged local branches...${NC}"
    merged_branches=$(git branch --merged main | grep -v main | grep -v "^\*" || true)
    
    if [[ -n "$merged_branches" ]]; then
        echo -e "${YELLOW}Found merged branches to delete:${NC}"
        echo "$merged_branches"
        echo "$merged_branches" | xargs -r git branch -d
        echo -e "${GREEN}✅ Deleted merged local branches${NC}"
    else
        echo -e "${GREEN}✅ No merged branches to delete${NC}"
    fi
    
    # Clean up remote tracking branches
    echo -e "${BLUE}📋 Cleaning up remote tracking branches...${NC}"
    git remote prune origin
    
    # Delete remote Dependabot branches (if they still exist)
    echo -e "${BLUE}📋 Cleaning up remote Dependabot branches...${NC}"
    dependabot_branches=$(git branch -r | grep dependabot | sed 's/origin\///' || true)
    
    if [[ -n "$dependabot_branches" ]]; then
        echo -e "${YELLOW}Found Dependabot branches to delete:${NC}"
        echo "$dependabot_branches"
        echo "$dependabot_branches" | xargs -I {} git push origin --delete {} 2>/dev/null || true
        echo -e "${GREEN}✅ Cleaned up remote Dependabot branches${NC}"
    else
        echo -e "${GREEN}✅ No remote Dependabot branches to clean up${NC}"
    fi
    
    echo ""
}

# Function to verify changes
verify_changes() {
    echo -e "${BLUE}🔍 Verifying Recent Changes${NC}"
    
    # Show recent commits
    echo -e "${BLUE}📋 Recent commits:${NC}"
    git log --oneline -10
    
    # Check for any issues
    echo -e "${BLUE}📋 Checking for potential issues...${NC}"
    
    # Check for merge conflicts
    if git grep -l "<<<<<<< HEAD" -- .; then
        echo -e "${RED}❌ Found merge conflict markers!${NC}"
        return 1
    fi
    
    # Check for TODO/FIXME comments
    todo_count=$(git grep -i "TODO\|FIXME" -- . | wc -l)
    if [[ $todo_count -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  Found $todo_count TODO/FIXME comments${NC}"
    fi
    
    echo -e "${GREEN}✅ No merge conflicts found${NC}"
    echo ""
}

# Function to test the application
test_application() {
    echo -e "${BLUE}🧪 Testing Application${NC}"
    
    # Test backend
    if [[ -f "package.json" ]]; then
        echo -e "${BLUE}📋 Testing backend...${NC}"
        if npm test 2>/dev/null; then
            echo -e "${GREEN}✅ Backend tests passed${NC}"
        else
            echo -e "${YELLOW}⚠️  Backend tests failed or not configured${NC}"
        fi
    fi
    
    # Test frontend
    if [[ -f "frontend/package.json" ]]; then
        echo -e "${BLUE}📋 Testing frontend...${NC}"
        cd frontend
        if npm test -- --watchAll=false 2>/dev/null; then
            echo -e "${GREEN}✅ Frontend tests passed${NC}"
        else
            echo -e "${YELLOW}⚠️  Frontend tests failed or not configured${NC}"
        fi
        cd ..
    fi
    
    echo ""
}

# Function to check dependencies
check_dependencies() {
    echo -e "${BLUE}📦 Checking Dependencies${NC}"
    
    # Check backend dependencies
    if [[ -f "package.json" ]]; then
        echo -e "${BLUE}📋 Checking backend dependencies...${NC}"
        npm install
        if npm audit --audit-level moderate; then
            echo -e "${GREEN}✅ Backend dependencies are secure${NC}"
        else
            echo -e "${YELLOW}⚠️  Backend has security vulnerabilities${NC}"
            echo -e "${YELLOW}Run 'npm audit fix' to fix them${NC}"
        fi
    fi
    
    # Check frontend dependencies
    if [[ -f "frontend/package.json" ]]; then
        echo -e "${BLUE}📋 Checking frontend dependencies...${NC}"
        cd frontend
        npm install
        if npm audit --audit-level moderate; then
            echo -e "${GREEN}✅ Frontend dependencies are secure${NC}"
        else
            echo -e "${YELLOW}⚠️  Frontend has security vulnerabilities${NC}"
            echo -e "${YELLOW}Run 'npm audit fix' to fix them${NC}"
        fi
        cd ..
    fi
    
    echo ""
}

# Function to check deployment status
check_deployment() {
    echo -e "${BLUE}🚀 Checking Deployment Status${NC}"
    
    if command_exists kubectl; then
        echo -e "${BLUE}📋 Checking Kubernetes resources...${NC}"
        
        # Check pods
        echo -e "${BLUE}Pods:${NC}"
        kubectl get pods
        
        # Check services
        echo -e "${BLUE}Services:${NC}"
        kubectl get services
        
        # Check for any failed pods
        failed_pods=$(kubectl get pods --field-selector=status.phase=Failed -o name 2>/dev/null || true)
        if [[ -n "$failed_pods" ]]; then
            echo -e "${RED}❌ Found failed pods:${NC}"
            echo "$failed_pods"
        else
            echo -e "${GREEN}✅ No failed pods found${NC}"
        fi
        
    else
        echo -e "${YELLOW}⚠️  kubectl not found. Skipping deployment check.${NC}"
    fi
    
    echo ""
}

# Function to show summary
show_summary() {
    echo -e "${BLUE}📊 Cleanup Summary${NC}"
    echo -e "${BLUE}=================${NC}"
    
    # Show current branch
    current_branch=$(git branch --show-current)
    echo -e "${GREEN}Current branch: $current_branch${NC}"
    
    # Show recent commits
    commit_count=$(git rev-list --count HEAD~10..HEAD)
    echo -e "${GREEN}Recent commits: $commit_count${NC}"
    
    # Show branch status
    local_branches=$(git branch | wc -l)
    remote_branches=$(git branch -r | wc -l)
    echo -e "${GREEN}Local branches: $local_branches${NC}"
    echo -e "${GREEN}Remote branches: $remote_branches${NC}"
    
    # Show working directory status
    if [[ -z $(git status --porcelain) ]]; then
        echo -e "${GREEN}Working directory: Clean${NC}"
    else
        echo -e "${YELLOW}Working directory: Has changes${NC}"
    fi
    
    echo ""
    echo -e "${PURPLE}🎉 Post-merge cleanup completed!${NC}"
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "${YELLOW}1. Deploy the updated system: ./deploy-all.sh${NC}"
    echo -e "${YELLOW}2. Monitor the deployment: kubectl get pods${NC}"
    echo -e "${YELLOW}3. Test the application: ./dev-test.sh${NC}"
    echo -e "${YELLOW}4. Update documentation if needed${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}Starting post-merge cleanup...${NC}"
    echo ""
    
    # Check prerequisites
    if ! command_exists git; then
        echo -e "${RED}❌ Git is not installed${NC}"
        exit 1
    fi
    
    # Run cleanup steps
    check_git_status
    update_repository
    cleanup_branches
    verify_changes
    test_application
    check_dependencies
    check_deployment
    show_summary
}

# Run main function
main
