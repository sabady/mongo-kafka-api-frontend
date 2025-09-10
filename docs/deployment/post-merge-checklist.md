# Post-Merge Checklist

This guide outlines what to do after merging all pull requests to ensure your repository is clean and properly maintained.

## 🧹 Immediate Cleanup Tasks

### 1. **Clean Up Local Branches**
```bash
# Delete merged branches locally
git branch --merged main | grep -v main | xargs -n 1 git branch -d

# Delete remote tracking branches for merged PRs
git remote prune origin

# Verify clean state
git status
git branch -a
```

### 2. **Update Local Repository**
```bash
# Pull latest changes
git checkout main
git pull origin main

# Verify everything is up to date
git log --oneline -10
```

### 3. **Clean Up Dependabot Branches**
```bash
# List all Dependabot branches
git branch -r | grep dependabot

# Delete remote Dependabot branches (if they still exist)
git branch -r | grep dependabot | sed 's/origin\///' | xargs -I {} git push origin --delete {} 2>/dev/null || true
```

## 🔍 Verification Tasks

### 4. **Verify All Changes**
```bash
# Check what was merged
git log --oneline --since="1 week ago"

# Verify no conflicts remain
git status
git diff HEAD~1

# Check for any uncommitted changes
git diff --staged
```

### 5. **Test the Application**
```bash
# Run tests to ensure everything works
npm test
cd frontend && npm test

# Check if the application builds
npm run build
cd frontend && npm run build

# Verify Docker builds work
docker build -t api-server .
docker build -t frontend ./frontend
```

### 6. **Check Dependencies**
```bash
# Update package-lock files
npm install
cd frontend && npm install

# Check for security vulnerabilities
npm audit
cd frontend && npm audit

# Fix any vulnerabilities
npm audit fix
cd frontend && npm audit fix
```

## 🚀 Deployment Tasks

### 7. **Deploy to Staging/Production**
```bash
# Deploy using your deployment scripts
./deploy-all.sh

# Or deploy individual components
./deploy-mongodb.sh
./deploy-kafka.sh
./deploy-api-server.sh
./deploy-frontend.sh
```

### 8. **Verify Deployment**
```bash
# Check pod status
kubectl get pods

# Check services
kubectl get services

# Check logs for any issues
kubectl logs -l app=api-server
kubectl logs -l app=frontend
kubectl logs -l app=kafka
kubectl logs -l app=mongodb
```

## 📊 Monitoring and Maintenance

### 9. **Set Up Monitoring**
```bash
# Check if monitoring is working
kubectl get pods -l app=prometheus
kubectl get pods -l app=metrics-server

# Verify metrics endpoints
curl http://localhost:3000/metrics
curl http://localhost:3000/health
```

### 10. **Update Documentation**
- Update README.md with any new features
- Update API documentation if endpoints changed
- Update deployment instructions if needed
- Update troubleshooting guides

## 🔧 Repository Maintenance

### 11. **Configure Ongoing Automation**
```bash
# Verify auto-merge is working
gh pr list --author "app/dependabot"

# Check GitHub Actions workflows
gh workflow list

# Verify branch protection rules
gh api repos/sabady/mongo-kafka-api-frontend/branches/main/protection
```

### 12. **Set Up Regular Maintenance**
```bash
# Schedule regular dependency updates
# (Already configured in .github/dependabot.yml)

# Set up regular security scans
# (Already configured in .github/workflows/security.yml)

# Configure regular performance tests
# (Already configured in .github/workflows/performance.yml)
```

## 📋 Long-term Maintenance Tasks

### 13. **Weekly Tasks**
- [ ] Review and merge Dependabot PRs
- [ ] Check for security vulnerabilities
- [ ] Monitor application performance
- [ ] Review and update documentation

### 14. **Monthly Tasks**
- [ ] Review and update dependencies
- [ ] Check for deprecated packages
- [ ] Update Docker base images
- [ ] Review and optimize CI/CD pipelines

### 15. **Quarterly Tasks**
- [ ] Major dependency updates
- [ ] Security audit and penetration testing
- [ ] Performance optimization review
- [ ] Infrastructure cost optimization

## 🚨 Troubleshooting Common Issues

### 16. **If Something Breaks After Merge**
```bash
# Check recent commits
git log --oneline -5

# Revert if necessary
git revert <commit-hash>

# Or reset to previous state
git reset --hard HEAD~1
git push --force-with-lease origin main
```

### 17. **If Dependencies Cause Issues**
```bash
# Check for breaking changes
npm ls
cd frontend && npm ls

# Downgrade problematic packages
npm install package@previous-version
cd frontend && npm install package@previous-version
```

### 18. **If Deployment Fails**
```bash
# Check Kubernetes resources
kubectl get all
kubectl describe pods
kubectl logs <pod-name>

# Restart services if needed
kubectl rollout restart deployment/api-server
kubectl rollout restart deployment/frontend
```

## 📈 Success Metrics

### 19. **Track These Metrics**
- [ ] All tests passing
- [ ] No security vulnerabilities
- [ ] Application performance maintained
- [ ] All services healthy
- [ ] Documentation up to date
- [ ] CI/CD pipelines green

### 20. **Documentation Updates**
- [ ] Update CHANGELOG.md
- [ ] Update version numbers if needed
- [ ] Update API documentation
- [ ] Update deployment guides
- [ ] Update troubleshooting guides

## 🎯 Next Steps

### 21. **Plan Future Updates**
- [ ] Schedule next major dependency update
- [ ] Plan feature additions
- [ ] Review and optimize architecture
- [ ] Plan scaling strategies

### 22. **Team Communication**
- [ ] Notify team of changes
- [ ] Share deployment status
- [ ] Document any breaking changes
- [ ] Update team on new features

## 🔗 Useful Commands

```bash
# Quick status check
git status && git branch -a && kubectl get pods

# Full system health check
./dev-test.sh

# Deploy everything
./deploy-all.sh

# Check all services
kubectl get all

# View logs
kubectl logs -l app=api-server --tail=50
kubectl logs -l app=frontend --tail=50
kubectl logs -l app=kafka --tail=50
kubectl logs -l app=mongodb --tail=50
```

## 📝 Notes

- Keep this checklist handy for future merge cycles
- Customize based on your specific needs
- Update as your system evolves
- Share with your team for consistency

Remember: The goal is to maintain a clean, secure, and well-functioning system after every merge cycle! 🎉
