#!/bin/bash

# Create Consolidated PR Script
# This script creates a single branch with all dependency updates

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Creating Consolidated Dependency Update PR${NC}"
echo -e "${BLUE}============================================${NC}"

# Repository information
REPO_URL="https://github.com/sabady/mongo-kafka-api-frontend"

# Create a new branch for consolidated updates
CONSOLIDATED_BRANCH="consolidated-dependency-updates-$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}Creating branch: ${CONSOLIDATED_BRANCH}${NC}"

# Ensure we're on main and up to date
git checkout main
git pull origin main

# Create the consolidated branch
git checkout -b "$CONSOLIDATED_BRANCH"

echo -e "${GREEN}✅ Created branch: ${CONSOLIDATED_BRANCH}${NC}"

# Get all Dependabot branches
DEPENDABOT_BRANCHES=($(git branch -r | grep "dependabot" | sed 's/remotes\/origin\///' | sort))

echo -e "${BLUE}📋 Found ${#DEPENDABOT_BRANCHES[@]} Dependabot branches to process${NC}"
echo ""

# Create a summary file
SUMMARY_FILE="DEPENDENCY_UPDATES.md"
cat > "$SUMMARY_FILE" << EOF
# Consolidated Dependency Updates

This PR consolidates all pending Dependabot dependency updates into a single, reviewable change.

## Updates Included

EOF

# Process each branch
merged_count=0
conflict_count=0
skipped_count=0

for branch in "${DEPENDABOT_BRANCHES[@]}"; do
    echo -e "${BLUE}Processing: ${branch}${NC}"
    
    # Extract package info
    if [[ $branch == *"docker"* ]]; then
        package=$(echo "$branch" | sed 's/.*dependabot\/docker\///' | sed 's/-[0-9].*//')
        category="🐳 Docker"
    elif [[ $branch == *"github_actions"* ]]; then
        package=$(echo "$branch" | sed 's/.*dependabot\/github_actions\///' | sed 's/-[0-9].*//')
        category="⚡ GitHub Actions"
    elif [[ $branch == *"npm_and_yarn"* ]]; then
        package=$(echo "$branch" | sed 's/.*dependabot\/npm_and_yarn\///' | sed 's/-[0-9].*//')
        category="📦 NPM/Yarn"
    else
        package="Unknown"
        category="❓ Other"
    fi
    
    # Try to merge the branch
    if git merge origin/$branch --no-edit 2>/dev/null; then
        echo -e "${GREEN}✅ Merged: ${package}${NC}"
        echo "- ${category}: ${package}" >> "$SUMMARY_FILE"
        ((merged_count++))
    else
        echo -e "${RED}❌ Conflict: ${package} - skipping${NC}"
        git merge --abort 2>/dev/null || true
        echo "- ${category}: ${package} (CONFLICT - skipped)" >> "$SUMMARY_FILE"
        ((conflict_count++))
    fi
done

# Add summary to the file
cat >> "$SUMMARY_FILE" << EOF

## Summary

- ✅ Successfully merged: ${merged_count} updates
- ❌ Conflicts (skipped): ${conflict_count} updates
- 📊 Total processed: ${#DEPENDABOT_BRANCHES[@]} branches

## Next Steps

1. Review the changes in this PR
2. Test the application to ensure everything works
3. Merge this PR once approved
4. Close individual Dependabot PRs after merging

## Individual PRs to Close

After merging this PR, you can close these individual Dependabot PRs:

EOF

# Add list of branches to close
for branch in "${DEPENDABOT_BRANCHES[@]}"; do
    echo "- \`${branch}\`" >> "$SUMMARY_FILE"
done

# Commit the consolidated changes
if [ $merged_count -gt 0 ]; then
    git add .
    git commit -m "chore: consolidate dependency updates

- Merged ${merged_count} dependency update branches
- Skipped ${conflict_count} branches due to conflicts
- Consolidated updates for better maintainability

This PR consolidates multiple Dependabot updates into a single, reviewable change.

See DEPENDENCY_UPDATES.md for detailed information."
    
    # Push the consolidated branch
    git push origin "$CONSOLIDATED_BRANCH"
    
    echo ""
    echo -e "${GREEN}🎉 Consolidated PR created successfully!${NC}"
    echo -e "${BLUE}📋 Summary:${NC}"
    echo -e "${GREEN}   ✅ Successfully merged: ${merged_count} updates${NC}"
    echo -e "${RED}   ❌ Conflicts (skipped): ${conflict_count} updates${NC}"
    echo -e "${YELLOW}   📊 Total processed: ${#DEPENDABOT_BRANCHES[@]} branches${NC}"
    
    echo ""
    echo -e "${BLUE}🔗 Next Steps:${NC}"
    echo -e "${YELLOW}1. Create PR:${NC} ${REPO_URL}/compare/main...${CONSOLIDATED_BRANCH}"
    echo -e "${YELLOW}2. Review the changes in the PR${NC}"
    echo -e "${YELLOW}3. Test the application${NC}"
    echo -e "${YELLOW}4. Merge the PR once approved${NC}"
    echo -e "${YELLOW}5. Close individual Dependabot PRs${NC}"
    
    echo ""
    echo -e "${PURPLE}💡 Tip:${NC} The DEPENDENCY_UPDATES.md file contains a detailed summary of all changes."
    
else
    echo -e "${RED}❌ No branches could be merged. All had conflicts.${NC}"
    echo -e "${YELLOW}You may need to resolve conflicts manually or handle updates individually.${NC}"
    
    # Clean up
    git checkout main
    git branch -D "$CONSOLIDATED_BRANCH" 2>/dev/null || true
    exit 1
fi
