# SonarQube Community Edition 分支支持修改

## 概述

本修改移除了SonarQube Community Edition中对分支功能的限制，允许Community Edition支持非main分支和Pull Request的分析。

## 修改的文件

### 1. AnalysisMetadataHolderImpl.java
**位置：** `server/sonar-ce-task-projectanalysis/src/main/java/org/sonar/ce/task/projectanalysis/analysis/AnalysisMetadataHolderImpl.java`

**修改内容：**
- 移除了`setBranch`方法中的版本检查逻辑
- 注释掉了Community Edition分支限制的代码
- 现在允许Community Edition支持所有分支类型

**修改前：**
```java
boolean isCommunityEdition = editionProvider.get().filter(t -> t == EditionProvider.Edition.COMMUNITY).isPresent();
checkState(
  !isCommunityEdition || branch.isMain(),
  "Branches and Pull Requests are not supported in Community Edition");
```

**修改后：**
```java
// 移除版本检查逻辑，允许Community Edition支持所有分支类型
// boolean isCommunityEdition = editionProvider.get().filter(t -> t == EditionProvider.Edition.COMMUNITY).isPresent();
// checkState(
//   !isCommunityEdition || branch.isMain(),
//   "Branches and Pull Requests are not supported in Community Edition");
```

### 2. BranchLoader.java
**位置：** `server/sonar-ce-task-projectanalysis/src/main/java/org/sonar/ce/task/projectanalysis/component/BranchLoader.java`

**修改内容：**
- 移除了分支功能不支持的错误提示
- 添加了对分支属性的基本支持
- 引入了新的`CommunityBranchImpl`类

**修改前：**
```java
} else if (hasBranchProperties(metadata)) {
  throw MessageException.of("Current edition does not support branch feature");
}
```

**修改后：**
```java
} else if (hasBranchProperties(metadata)) {
  // 移除版本限制，允许Community Edition支持分支功能
  // 创建基于分支属性的分支对象
  String branchName = metadata.getBranchName();
  if (!branchName.isEmpty()) {
    // 创建非main分支
    metadataHolder.setBranch(new CommunityBranchImpl(branchName, false));
  } else if (!metadata.getPullRequestKey().isEmpty()) {
    // 创建Pull Request分支
    metadataHolder.setBranch(new CommunityBranchImpl(metadata.getPullRequestKey(), BranchType.PULL_REQUEST));
  } else {
    // 默认使用main分支
    metadataHolder.setBranch(new DefaultBranchImpl(defaultBranchNameResolver.getEffectiveMainBranchName()));
  }
}
```

### 3. CommunityBranchImpl.java (新增)
**位置：** `server/sonar-ce-task-projectanalysis/src/main/java/org/sonar/ce/task/projectanalysis/component/CommunityBranchImpl.java`

**功能：**
- 为Community Edition提供分支支持
- 支持非main分支和Pull Request
- 实现了Branch接口的所有必要方法

### 4. ProjectReactorValidator.java
**位置：** `sonar-scanner-engine/src/main/java/org/sonar/scanner/scan/ProjectReactorValidator.java`

**修改内容：**
- 注释掉了分支参数验证方法
- 移除了Community Edition的分支限制

### 5. ScanProperties.java
**位置：** `sonar-scanner-engine/src/main/java/org/sonar/scanner/scan/ScanProperties.java`

**修改内容：**
- 注释掉了`validateBranch`方法中的分支限制
- 允许使用分支相关属性

### 6. AnalysisMetadataHolderImplTest.java
**位置：** `server/sonar-ce-task-projectanalysis/src/test/java/org/sonar/ce/task/projectanalysis/analysis/AnalysisMetadataHolderImplTest.java`

**修改内容：**
- 更新了测试用例以反映Community Edition现在支持非main分支的变化

## 使用方法

修改后，您可以在Community Edition中使用以下属性来指定分支：

### 分支分析
```bash
sonar-scanner \
  -Dsonar.branch.name=feature-branch \
  -Dsonar.projectKey=my-project
```

### Pull Request分析
```bash
sonar-scanner \
  -Dsonar.pullrequest.key=123 \
  -Dsonar.pullrequest.branch=feature-branch \
  -Dsonar.pullrequest.base=main \
  -Dsonar.projectKey=my-project
```

## 注意事项

1. **功能限制**：虽然移除了版本检查，但某些高级分支功能可能仍然不可用
2. **数据库兼容性**：确保数据库结构支持分支功能
3. **插件依赖**：某些分支相关功能可能仍需要特定的插件支持
4. **测试覆盖**：建议在修改后进行充分的测试

## 构建和部署

1. 重新编译项目：
   ```bash
   ./gradlew build
   ```

2. 部署修改后的SonarQube实例

3. 测试分支功能是否正常工作

## 免责声明

这些修改移除了SonarQube的商业限制，仅用于学习和研究目的。在生产环境中使用前，请确保符合相关的许可证条款。 