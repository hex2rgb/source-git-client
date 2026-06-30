# Claude Code 镜像设计决策

## 1. Node.js 版本

Claude Code 是 npm 包，依赖 Node.js 运行时。

| 选项 | 说明 |
|------|------|
| A: 指定精确版本 | `v22.14.0` 写死，可复现 |
| B: 你给链接 | 你指定版本，我只用你给的 URL |

**建议**: 确认 Claude Code 当前支持的 Node.js 版本范围，选一个 LTS 版本写死。

---

## 2. 工作区目录

容器里的代码放在哪。

| 选项 | 说明 |
|------|------|
| A: 镜像不定，由 compose/run 时挂载 | 镜像不设 WORKDIR，用户自己 `-w /app` |
| B: 镜像设 WORKDIR，外面挂载 | 例如 `WORKDIR /workspace`，docker run 挂载宿主机目录过去 |

**建议**: 镜像不定，挂载点交给运行时。镜像只管环境。

---

## 3. 交互模式

Claude Code 是交互式 REPL，容器需要 `-it` 才能使用。

```bash
docker run -it claude-code:local
# 或用 compose: tty: true + stdin_open: true
```

**无选项，这是强制要求**。镜像 CMD 用 `claude` 还是 `/bin/bash`，取决于你想不想要"默认启动就进 claude"。

| 选项 | 说明 |
|------|------|
| A: CMD 为 claude | `docker run -it` 直接进 claude REPL |
| B: CMD 为 bash | 进去再手动敲 `claude`，灵活 |

**建议**: B，进容器先确认环境再启动 claude。

---

## 4. 认证方式

Claude Code 需要认证才能调用 Anthropic API。

| 选项 | 说明 |
|------|------|
| A: 环境变量 | `docker run -e ANTHROPIC_API_KEY=sk-xxx`，不用持久化 |
| B: 挂载配置目录 | 外面 `claude login` 完，把 `~/.config/claude/` 挂进容器，不用每次传 key |
| C: 镜像统一处理 | 镜像带个入口脚本，优先读 env，没有就走交互式 login |

**建议**: A 最简单，适合 CI/CD。B 适合本地长期使用。

---

## 5. 镜像源

| 源 | 当前状态 |
|----|---------|
| APT | 已配清华源（`ARG APT_MIRROR`，可覆写） |
| pip | 已配清华源 |
| npm | 未配（你要求保持官方） |

**无变更**。APT 和 pip 已配清华，npm 保持官方源。

---

## 6. 额外依赖

除了你已指定的（curl, git, python3, python3-pip, ca-certificates），是否还需要其他运行时工具。

| 工具 | 必要性 |
|------|--------|
| git | Claude Code 内部依赖 git 做版本管理 |
| jq / yq / curl | 日常操作常用，但不属于 Claude Code 必需 |
| ssh / openssh-client | 如果 clone 私有仓库 |

**建议**: 先只装必需的（git + ca-certificates + curl 已经有了），缺了再说。

---

## 7. 代理

国内访问 Anthropic API 可能需要代理。

| 选项 | 说明 |
|------|------|
| A: 镜像中预置代理配置 | 预设 `HTTP_PROXY` / `HTTPS_PROXY` env |
| B: 运行时传 | `docker run -e HTTPS_PROXY=http://host:port` |

**建议**: B。代理地址是运行时环境信息，不该陷入镜像。
