# GitHub Actions Secrets 设置指南

本项目的 GitHub Actions 工作流需要推送 Docker 镜像到 Docker Hub。为保证安全，需在 GitHub 仓库中配置以下 Secrets。

## 必须的 Secrets

| Secret 名称           | 说明                       |
|----------------------|----------------------------|
| `DOCKERHUB_USERNAME` | Docker Hub 用户名           |
| `DOCKERHUB_TOKEN`    | Docker Hub 访问令牌（Token）|

## 设置方法

1. 打开你的 GitHub 仓库页面。
2. 点击顶部菜单栏的 `Settings`（设置）。
3. 在左侧菜单中选择 `Secrets and variables` > `Actions`。
4. 点击 `New repository secret` 按钮。
5. 分别添加如下 Secrets：
   - `DOCKERHUB_USERNAME`：你的 Docker Hub 用户名
   - `DOCKERHUB_TOKEN`：你的 Docker Hub 访问令牌（推荐使用 [Docker Hub Access Token](https://hub.docker.com/settings/security) 生成，不建议直接使用密码）

## 获取 Docker Hub Token

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击右上角头像，选择 `Account Settings`
3. 进入 `Security` 标签页
4. 点击 `New Access Token`，填写名称并生成
5. 复制生成的 Token，作为 `DOCKERHUB_TOKEN` 添加到 GitHub Secrets

## 示例

| Name                | Value（示例）      |
|---------------------|--------------------|
| DOCKERHUB_USERNAME  | your-docker-username |
| DOCKERHUB_TOKEN     | ghp_xxxxxxxxxxxxxxxx |

## 参考
- [GitHub 官方文档：加密的 secrets](https://docs.github.com/zh/actions/security-guides/encrypted-secrets)
- [Docker Hub 官方文档](https://docs.docker.com/docker-hub/access-tokens/)

---

配置完成后，GitHub Actions 工作流即可自动登录并推送镜像到你的 Docker Hub 仓库。