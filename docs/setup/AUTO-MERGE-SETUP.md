# Auto-merge Setup Guide

This guide explains how to set up automatic merging of pull requests without conflicts.

## 🚀 Quick Setup

### 1. Install GitHub CLI (if not already installed)
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
gh auth login
```

### 2. Enable Auto-merge for Existing PRs
```bash
./enable-auto-merge.sh
```

### 3. Verify Setup
- Check that the auto-merge workflow is active in GitHub Actions
- Verify that new Dependabot PRs get auto-merge labels

## 📋 What's Included

### 🔧 Files Created:
- **`.github/workflows/auto-merge.yml`** - GitHub Actions workflow for auto-merge
- **`.github/dependabot.yml`** - Dependabot configuration with auto-merge settings
- **`.github/auto-merge-config.yml`** - Configuration file for auto-merge rules
- **`enable-auto-merge.sh`** - Script to enable auto-merge for existing PRs

### 🎯 Auto-merge Rules:

#### For Dependabot PRs:
- ✅ **Auto-merge enabled** for dependency updates
- ✅ **All status checks must pass**
- ✅ **No merge conflicts**
- ✅ **PR must be up to date**
- ✅ **Squash merge** with branch deletion
- ✅ **5-minute delay** for final checks

#### For Regular PRs:
- ❌ **Auto-merge disabled** (requires manual review)
- ✅ **Manual approval required**
- ✅ **All checks must pass**

## 🔄 How It Works

### 1. **Dependabot Creates PR**
- Dependabot creates a PR with dependency updates
- PR gets labeled with `dependencies` and `auto-merge`

### 2. **Auto-merge Workflow Triggers**
- Workflow runs on PR events (opened, synchronized, reviewed)
- Checks if PR meets auto-merge criteria

### 3. **Criteria Check**
- ✅ PR is from Dependabot
- ✅ All status checks are passing
- ✅ No merge conflicts
- ✅ PR is up to date with main branch
- ✅ No requested changes

### 4. **Auto-merge Execution**
- Enables auto-merge with squash strategy
- Adds informative comment to PR
- PR merges automatically after delay

## 🛠️ Configuration Options

### Dependabot Settings (`.github/dependabot.yml`):
```yaml
# Group updates by type
groups:
  typescript:
    patterns:
      - "typescript"
      - "@types/*"
  
  testing:
    patterns:
      - "jest"
      - "@types/jest"

# Auto-merge labels
labels:
  - "dependencies"
  - "auto-merge"
```

### Auto-merge Workflow (`.github/workflows/auto-merge.yml`):
```yaml
# Only for Dependabot PRs
if: github.actor == 'dependabot[bot]'

# Check mergeability
MERGEABLE=$(gh pr view $PR_NUMBER --json mergeable --jq '.mergeable')

# Enable auto-merge
gh pr merge $PR_NUMBER --auto --squash --delete-branch
```

## 📊 Monitoring

### View Auto-merge Activity:
1. **GitHub Actions**: Check workflow runs
2. **PR Comments**: Look for auto-merge comments
3. **PR Labels**: Check for `auto-merge` labels

### Common Issues:
- **Merge Conflicts**: PR won't auto-merge, needs manual resolution
- **Failed Checks**: PR waits for checks to pass
- **Requested Changes**: PR waits for approval

## 🔒 Security Features

### Trusted Authors:
- Only `dependabot[bot]` and `sabady` can auto-merge
- Regular contributors require manual review

### File-based Rules:
- **Documentation**: Auto-merge enabled
- **Dependencies**: Auto-merge enabled (Dependabot only)
- **Code Changes**: Manual review required

### Security Checks:
- All status checks must pass
- No security-related changes auto-merge
- Sensitive files require review

## 🎛️ Manual Control

### Enable Auto-merge for Specific PR:
```bash
gh pr merge <PR_NUMBER> --auto --squash --delete-branch
```

### Disable Auto-merge:
```bash
gh pr merge <PR_NUMBER> --disable-auto-merge
```

### Check PR Status:
```bash
gh pr view <PR_NUMBER> --json mergeable,statusCheckRollup
```

## 📈 Benefits

### ✅ **Automation**:
- No manual intervention for dependency updates
- Consistent merge strategy
- Automatic branch cleanup

### ✅ **Quality**:
- All checks must pass before merge
- No conflicts allowed
- Maintains clean history

### ✅ **Efficiency**:
- Reduces PR backlog
- Faster dependency updates
- Less maintenance overhead

## 🚨 Troubleshooting

### Auto-merge Not Working:
1. Check if PR is from Dependabot
2. Verify all status checks are passing
3. Ensure no merge conflicts
4. Check workflow logs in GitHub Actions

### PR Stuck in Auto-merge:
1. Check for failed status checks
2. Look for requested changes
3. Verify PR is up to date
4. Check for blocking labels

### Workflow Not Triggering:
1. Verify workflow file is in `.github/workflows/`
2. Check workflow permissions
3. Ensure GitHub Actions is enabled
4. Verify branch protection rules

## 🔗 Useful Links

- **Repository PRs**: https://github.com/sabady/mongo-kafka-api-frontend/pulls
- **Dependabot PRs**: https://github.com/sabady/mongo-kafka-api-frontend/pulls?q=is%3Apr+is%3Aopen+author%3Aapp%2Fdependabot
- **GitHub Actions**: https://github.com/sabady/mongo-kafka-api-frontend/actions
- **Repository Settings**: https://github.com/sabady/mongo-kafka-api-frontend/settings

## 📝 Next Steps

1. **Test the setup** with a new Dependabot PR
2. **Monitor the workflow** for a few days
3. **Adjust settings** if needed
4. **Document any customizations** for your team

The auto-merge system is now ready to automatically handle dependency updates while maintaining code quality and security! 🎉
