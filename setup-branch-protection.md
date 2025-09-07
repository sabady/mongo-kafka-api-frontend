# Branch Protection Setup Guide

## Manual Setup via GitHub Web Interface

### Step 1: Navigate to Repository Settings
1. Go to your repository: `https://github.com/sabady/mongo-kafka-api-frontend`
2. Click on the **Settings** tab
3. In the left sidebar, click on **Branches**

### Step 2: Add Branch Protection Rule
1. Click **Add rule** under "Branch protection rules"
2. In "Branch name pattern", enter: `main`

### Step 3: Configure Protection Settings
Enable the following options:

#### ✅ **Require a pull request before merging**
- ✅ Require approvals: `1` (minimum)
- ✅ Dismiss stale PR approvals when new commits are pushed
- ✅ Require review from code owners (if you have a CODEOWNERS file)

#### ✅ **Require status checks to pass before merging**
- ✅ Require branches to be up to date before merging
- Add these status checks (when available):
  - `CI` (from our GitHub Actions workflow)
  - `Security` (from our security workflow)
  - `Performance` (from our performance workflow)

#### ✅ **Require conversation resolution before merging**
- ✅ All conversations on code must be resolved

#### ✅ **Require signed commits**
- ✅ Require signed commits (enhances security)

#### ✅ **Require linear history**
- ✅ Require linear history (prevents merge commits)

#### ✅ **Include administrators**
- ✅ Include administrators (applies rules to all users)

#### ✅ **Restrict pushes that create files**
- ✅ Restrict pushes that create files larger than 100MB

### Step 4: Save the Rule
Click **Create** to apply the branch protection rule.

## Automated Setup (Optional)

If you install GitHub CLI, you can use the provided script:

```bash
# Install GitHub CLI (Ubuntu/Debian)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authenticate
gh auth login

# Run the setup script
chmod +x setup-branch-protection.sh
./setup-branch-protection.sh
```

## Verification

After setting up branch protection:

1. Try to push directly to main (should fail):
   ```bash
   git checkout -b test-direct-push
   echo "test" >> test.txt
   git add test.txt
   git commit -m "test direct push"
   git push origin test-direct-push:main
   ```

2. Create a pull request instead:
   ```bash
   git push origin test-direct-push
   # Then create PR via GitHub web interface
   ```

## Benefits

- ✅ Prevents accidental direct pushes to main
- ✅ Ensures all changes are reviewed
- ✅ Requires CI tests to pass
- ✅ Maintains clean commit history
- ✅ Enhances security with signed commits
- ✅ Prevents large file uploads
