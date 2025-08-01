# SonarQube Community Edition with Branch Support

这是一个修改版的SonarQube Community Edition，移除了对分支功能的限制，允许Community Edition支持非main分支和Pull Request的分析。

## 🚀 主要改进

### 分支支持
- ✅ **非main分支分析**：支持分析任意分支
- ✅ **Pull Request分析**：支持分析Pull Request
- ✅ **分支功能**：移除了Community Edition的分支限制

## 📋 使用方法

### 分析特定分支
```bash
sonar-scanner \
  -Dsonar.branch.name=feature-branch \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=src
```

### 分析Pull Request
```bash
sonar-scanner \
  -Dsonar.pullrequest.key=123 \
  -Dsonar.pullrequest.branch=feature-branch \
  -Dsonar.pullrequest.base=main \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=src
```

## 🔍 修改内容

主要修改了以下文件：
- `server/sonar-ce-task-projectanalysis/src/main/java/org/sonar/ce/task/projectanalysis/analysis/AnalysisMetadataHolderImpl.java`
- `server/sonar-ce-task-projectanalysis/src/main/java/org/sonar/ce/task/projectanalysis/component/BranchLoader.java`
- `server/sonar-ce-task-projectanalysis/src/main/java/org/sonar/ce/task/projectanalysis/component/CommunityBranchImpl.java`
- `sonar-scanner-engine/src/main/java/org/sonar/scanner/scan/ProjectReactorValidator.java`
- `sonar-scanner-engine/src/main/java/org/sonar/scanner/scan/ScanProperties.java`

## 📝 许可证

本项目基于LGPL-3.0许可证开源。
