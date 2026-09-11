# SSH 自动密码登录 (SSH_ASKPASS)

适用于需要通过密码登录、但不想每次手动输入的 SSH 服务器。

## 原理

```
你敲 ssh <host>（或 agent 调用）
        │
        ▼
shell 环境变量：
  SSH_ASKPASS=~/.../askpass-xxx.sh    ← 密码供给脚本
  SSH_ASKPASS_REQUIRE=force           ← 强制走 askpass，跳过 TTY
  DISPLAY=...                         ← SSH 调用 askpass 的前置条件
        │
        ▼
SSH 连接目标服务器
        │
        ▼
服务器要求密码
  → SSH 不弹 TTY 提示，直接执行 askpass 脚本
  → 脚本从本地安全存储取出密码，打印到 stdout
  → SSH 拿到密码，认证成功
        │
        ▼
ControlMaster auto / ControlPersist yes
  → 首次创建 socket，后续复用秒连
```

核心思路：**不同平台的密码存储方式不同，但 `SSH_ASKPASS` 这套接口是统一的。**

## 文件清单

| 文件 | 作用 |
|------|------|
| `~/.zshenv`（macOS/Linux）或系统环境变量（Windows） | 注入 `SSH_ASKPASS` / `SSH_ASKPASS_REQUIRE` / `DISPLAY` |
| `~/.ssh/askpass-<platform>.sh`（平台相关） | 从安全存储取出密码，打印到 stdout |
| `~/.ssh/config` (目标 Host) | ControlMaster、网关隧道等 |
| 各平台的安全存储 | 密码加密存放 |

## 平台差异（仅密码存储与 askpass 脚本不同）

### macOS — Keychain

```bash
# 存（替换 <username> 和 <server> 为实际值）
security add-generic-password -a <username> -s <server> -w

# askpass 脚本：账号/服务名走环境变量，脚本本身不含任何身份信息
# 仓库版见 ssh/askpass-keychain.sh
cat > ~/.ssh/askpass-keychain.sh << 'EOF'
#!/bin/sh
security find-generic-password \
    -a "${SSH_KEYCHAIN_ACCOUNT:?set SSH_KEYCHAIN_ACCOUNT}" \
    -s "${SSH_KEYCHAIN_SERVICE:?set SSH_KEYCHAIN_SERVICE}" \
    -w 2>/dev/null
EOF
chmod 700 ~/.ssh/askpass-keychain.sh
```

> 多台服务器共用一个 askpass 脚本时，在每次调用前切换 `SSH_KEYCHAIN_ACCOUNT` / `SSH_KEYCHAIN_SERVICE`；
> 或者为每台服务器生成一个只含占位值的小包装脚本 —— 但**不要**把包装脚本提交进仓库。

### Linux — GNOME Keyring（secret-tool）

```bash
# 存
secret-tool store --label="SSH <server>" account <username> service <server>

# askpass 脚本
cat > ~/.ssh/askpass-secret-tool.sh << 'EOF'
#!/bin/sh
secret-tool lookup account <username> service <server>
EOF
chmod 700 ~/.ssh/askpass-secret-tool.sh
```

### Linux — 简单文件（无需额外依赖）

```bash
# 存
echo "你的密码" > ~/.ssh/<server>-pass
chmod 600 ~/.ssh/<server>-pass

# askpass 脚本
cat > ~/.ssh/askpass-file.sh << 'EOF'
#!/bin/sh
cat ~/.ssh/<server>-pass
EOF
chmod 700 ~/.ssh/askpass-file.sh
```

### Windows — DPAPI 加密文件 + PowerShell

```powershell
# 1. 存（PowerShell）
"你的密码" | ConvertTo-SecureString -AsPlainText -Force |
  ConvertFrom-SecureString | Out-File "$env:USERPROFILE\.ssh\<server>-pass.enc"

# 2. askpass 脚本（PowerShell）
@'
$enc = Get-Content "$env:USERPROFILE\.ssh\<server>-pass.enc" | ConvertTo-SecureString
[Runtime.InteropServices.Marshal]::PtrToStringAuto(
  [Runtime.InteropServices.Marshal]::SecureStringToBSTR($enc))
'@ | Out-File "$env:USERPROFILE\.ssh\askpass.ps1"

# 3. 设置环境变量（系统级或 PowerShell profile）
[Environment]::SetEnvironmentVariable('SSH_ASKPASS',
  'powershell -WindowStyle Hidden -File %USERPROFILE%\.ssh\askpass.ps1', 'User')
[Environment]::SetEnvironmentVariable('SSH_ASKPASS_REQUIRE', 'force', 'User')
[Environment]::SetEnvironmentVariable('DISPLAY', 'dummy', 'User')
```

> Windows OpenSSH 同样支持 `SSH_ASKPASS`，但脚本必须是可执行文件。PowerShell 配合 `-WindowStyle Hidden` 可实现无窗口弹出。

## 平台差异总览

| 平台 | 存储 | askpass 取密码命令 |
|------|------|------------------|
| macOS | Keychain | `security find-generic-password -a <username> -s <server> -w` |
| Linux | GNOME Keyring | `secret-tool lookup account <username> service <server>` |
| Linux | 文件 | `cat ~/.ssh/<server>-pass`（chmod 600） |
| Windows | DPAPI 加密 | PowerShell `ConvertFrom-SecureString` |

## SSH config 示例

```ssh-config
Host <server-alias>
    HostName <actual-hostname>
    User <username>
    ProxyCommand ssh -W %h:%p <jump-host>   # 如有跳板机
    ControlMaster auto
    ControlPath ~/.ssh/control-%r@%h:%p
    ControlPersist yes
    ServerAliveInterval 120
    ServerAliveCountMax 5
    TCPKeepAlive yes
```

> 前提：`<jump-host>` 已配置且可用公钥登录。ControlPath 的 `~` 在 Windows 下需改为 `%USERPROFILE%` 或绝对路径。

## 日常使用

```bash
ssh <server-alias>             # 直接进，不输密码
ssh <server-alias> "command"   # agent 调用同理
```

## 修改密码

```bash
# macOS
security delete-generic-password -a <username> -s <server>
security add-generic-password -a <username> -s <server> -w

# Linux (secret-tool)
secret-tool clear account <username> service <server>
secret-tool store --label="SSH <server>" account <username> service <server>

# Linux (file)
echo "新密码" > ~/.ssh/<server>-pass

# Windows (PowerShell)
Remove-Item "$env:USERPROFILE\.ssh\<server>-pass.enc"
# 重新执行上面的 DPAPI 存密码步骤
```

## 故障排查

```bash
# 1. 密码还能取出来吗？
# macOS
security find-generic-password -a <username> -s <server> -w
# Linux
secret-tool lookup account <username> service <server>
# 没输出或报错 → 密码丢失，重新存

# 2. 环境变量加载了没？
echo $SSH_ASKPASS
echo $SSH_ASKPASS_REQUIRE
echo $DISPLAY
# 空 → 检查 .zshenv 或系统环境变量，新终端 source 一下

# 3. askpass 脚本可执行？
ls -la ~/.ssh/askpass-*.sh
# 不是 700 → chmod 700 ~/.ssh/askpass-xxx.sh

# 4. 手工调试
ssh -v <server-alias> 2>&1 | grep -iE "askpass|authenticated"
# 应看到 "read_passphrase: requested to askpass" 和 "Authenticated ... using password"
```
