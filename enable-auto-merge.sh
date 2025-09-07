#!/bin/bash

# Enable Auto-merge for Dependabot PRs Script
# This script enables auto-merge for all Dependabot PRs that are ready

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 Enabling Auto-merge for Dependabot PRs${NC}"
echo -e "${BLUE}=========================================${NC}"

# Repository information
REPO_OWNER="sabady"
REPO_NAME="mongo-kafka-api-frontend"

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed.${NC}"
    echo -e "${YELLOW}Please install it first:${NC}"
    echo "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    echo "sudo apt update && sudo apt install gh"
    echo "gh auth login"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with GitHub CLI.${NC}"
    echo -e "${YELLOW}Please run: gh auth login${NC}"
    exit 1
fi

# Function to check if PR is ready for auto-merge
check_pr_ready() {
    local pr_number=$1
    
    # Check if PR is mergeable
    local mergeable=$(gh pr view $pr_number --json mergeable --jq '.mergeable')
    if [[ "$mergeable" != "true" ]]; then
        echo "not_mergeable"
        return
    fi
    
    # Check if all status checks are passing
    local failed_checks=$(gh pr view $pr_number --json statusCheckRollup --jq '.statusCheckRollup[] | select(.conclusion != "SUCCESS" and .conclusion != "SKIPPED" and .conclusion != null) | .name')
    if [[ -n "$failed_checks" ]]; then
        echo "status_checks_failed"
        return
    fi
    
    # Check if PR is approved (if required)
    local review_decision=$(gh pr view $pr_number --json reviewDecision --jq '.reviewDecision')
    if [[ "$review_decision" == "CHANGES_REQUESTED" ]]; then
        echo "changes_requested"
        return
    fi
    
    echo "ready"
}

# Function to enable auto-merge for a PR
enable_auto_merge() {
    local pr_number=$1
    local pr_title=$2
    
    echo -e "${BLUE}Processing PR #$pr_number: $pr_title${NC}"
    
    # Check if PR is ready
    local status=$(check_pr_ready $pr_number)
    
    case $status in
        "ready")
            echo -e "${GREEN}✅ PR #$pr_number is ready for auto-merge${NC}"
            
            # Enable auto-merge
            if gh pr merge $pr_number --auto --squash --delete-branch; then
                echo -e "${GREEN}🚀 Auto-merge enabled for PR #$pr_number${NC}"
                
                # Add comment
                gh pr comment $pr_number --body "🤖 **Auto-merge enabled!**
                
                This PR has been automatically set to merge once all checks pass.
                
                - ✅ PR is mergeable
                - ✅ All status checks are passing
                - ✅ Ready for auto-merge
                
                The PR will be merged using squash merge and the branch will be deleted after merging."
                
                return 0
            else
                echo -e "${RED}❌ Failed to enable auto-merge for PR #$pr_number${NC}"
                return 1
            fi
            ;;
        "not_mergeable")
            echo -e "${RED}❌ PR #$pr_number has merge conflicts${NC}"
            return 1
            ;;
        "status_checks_failed")
            echo -e "${YELLOW}⚠️  PR #$pr_number has failing status checks${NC}"
            return 1
            ;;
        "changes_requested")
            echo -e "${YELLOW}⚠️  PR #$pr_number has requested changes${NC}"
            return 1
            ;;
        *)
            echo -e "${RED}❌ Unknown status for PR #$pr_number: $status${NC}"
            return 1
            ;;
    esac
}

# Get all open Dependabot PRs
echo -e "${BLUE}📋 Fetching open Dependabot PRs...${NC}"

DEPENDABOT_PRS=$(gh pr list --author "app/dependabot" --state open --json number,title --jq '.[] | "\(.number)|\(.title)"')

if [[ -z "$DEPENDABOT_PRS" ]]; then
    echo -e "${YELLOW}No open Dependabot PRs found.${NC}"
    exit 0
fi

echo -e "${GREEN}Found Dependabot PRs:${NC}"
echo "$DEPENDABOT_PRS" | while IFS='|' read -r pr_number pr_title; do
    echo -e "${PURPLE}  #$pr_number: $pr_title${NC}"
done
echo ""

# Process each PR
auto_merge_enabled=0
auto_merge_failed=0

echo "$DEPENDABOT_PRS" | while IFS='|' read -r pr_number pr_title; do
    if enable_auto_merge "$pr_number" "$pr_title"; then
        ((auto_merge_enabled++))
    else
        ((auto_merge_failed++))
    fi
    echo ""
done

echo -e "${BLUE}📊 Summary:${NC}"
echo -e "${GREEN}   ✅ Auto-merge enabled: $auto_merge_enabled PRs${NC}"
echo -e "${RED}   ❌ Auto-merge failed: $auto_merge_failed PRs${NC}"

echo ""
echo -e "${BLUE}🔗 View PRs:${NC}"
echo -e "${YELLOW}All PRs:${NC} https://github.com/$REPO_OWNER/$REPO_NAME/pulls"
echo -e "${YELLOW}Dependabot PRs:${NC} https://github.com/$REPO_OWNER/$REPO_NAME/pulls?q=is%3Apr+is%3Aopen+author%3Aapp%2Fdependabot"

echo ""
echo -e "${PURPLE}💡 Note:${NC} The auto-merge workflow will now automatically handle new Dependabot PRs."
echo -e "${PURPLE}   PRs will be auto-merged when they meet all requirements.${NC}"
