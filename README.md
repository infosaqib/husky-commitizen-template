# Husky + Commitizen + Commitlint Template

Automated Git commit conventions and hooks setup for any project.

## 🚀 Quick Start

Choose the installation method for your operating system:

### 🍎 macOS / Linux

**Method 1: Process Substitution (Recommended)**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh)
```

**Method 2: Direct Pipe**
```bash
curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh | bash
```

**Method 3: With Auto-cleanup**
```bash
cd /tmp && curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh -o husky-setup-temp.sh && cd - && bash /tmp/husky-setup-temp.sh && rm -f /tmp/husky-setup-temp.sh
```

---

### 🪟 Windows

#### Option A: PowerShell (Recommended)

Open **PowerShell** in your project directory:

```powershell
iwr -Uri "https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh" -OutFile "$env:TEMP\setup-husky.sh"; bash "$env:TEMP\setup-husky.sh"; Remove-Item "$env:TEMP\setup-husky.sh"
```

#### Option B: Git Bash (Simplest)

Right-click in your project folder → **"Git Bash Here"**, then run:

```bash
curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh | bash
```

Or using process substitution:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh)
```

#### Option C: Command Prompt (CMD)

Open **CMD** in your project directory:

```cmd
curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh -o %TEMP%\setup-husky.sh && bash %TEMP%\setup-husky.sh && del %TEMP%\setup-husky.sh
```

#### Option D: WSL (Windows Subsystem for Linux)

If you have WSL installed, open WSL terminal and use the Linux commands above.

**⚠️ Windows Requirements:**
- Git Bash (comes with [Git for Windows](https://git-scm.com/download/win))
- OR Windows Subsystem for Linux (WSL)
- OR have `bash` available in your PATH

---

## ✨ What It Does

The setup script will interactively:

1. ✅ Install required packages (Husky, Commitizen, Commitlint)
2. ✅ Create `commitlint.config.js` with conventional commit rules
3. ✅ Initialize Husky with three git hooks:
   - `pre-commit` - Run linting/tests before commits
   - `commit-msg` - Validate commit message format
   - `prepare-commit-msg` - Launch Commitizen for guided commits
4. ✅ Add `node_modules` to `.gitignore` (if needed)
5. ✅ Add npm scripts to `package.json`
6. ✅ Create/update `LICENSE` with your project name
7. ✅ Create/update `README.md` with usage instructions
8. ✅ Create/update `SECURITY.md` with security policies

**The script runs entirely from your GitHub repository and doesn't leave any files in your local project except the necessary configuration.**

## 🎯 Features

- **Interactive Setup**: Asks permission at every step
- **Non-Destructive**: Won't overwrite files without asking
- **Smart Detection**: Detects existing files and configurations
- **Clean Execution**: No leftover files in your project
- **Colorful Output**: Easy to follow progress

## 📋 Requirements

- Node.js and npm installed
- Git repository initialized
- Internet connection (to download from GitHub)

## 🔧 What You Get

After setup, you can make commits using:

```bash
npm run commit
```

This launches an interactive commit wizard that ensures your commits follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <subject>
```

### Commit Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `build`: Build system changes
- `ci`: CI/CD changes
- `chore`: Other changes
- `revert`: Revert previous commit

## 📦 Installed Packages

- `husky` - Git hooks management
- `@commitlint/cli` - Commit message linting
- `@commitlint/config-conventional` - Conventional commit rules
- `commitizen` - Interactive commit CLI
- `cz-conventional-changelog` - Conventional commits adapter

## 🛠️ Manual Installation

If you prefer to review the script before running it:

### 1. Download the Script

**macOS/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh -o setup-husky.sh
```

**Windows (PowerShell):**
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh" -OutFile "setup-husky.sh"
```

**Windows (CMD):**
```cmd
curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh -o setup-husky.sh
```

### 2. Review the Script

```bash
cat setup-husky.sh
# or open it in your favorite editor
```

### 3. Make it Executable (macOS/Linux only)

```bash
chmod +x setup-husky.sh
```

### 4. Run the Script

**All Platforms:**
```bash
bash setup-husky.sh
```

Or on macOS/Linux after chmod:
```bash
./setup-husky.sh
```

### 5. Clean Up

```bash
rm setup-husky.sh
```

## 🔒 Security

This script:
- Does NOT require sudo/admin privileges
- Does NOT modify system files
- Only modifies files in your current project directory
- Asks permission before every action
- Is hosted on GitHub for transparency

## 📝 Example Workflow

### macOS/Linux

1. Navigate to your project:
```bash
cd my-awesome-project
```

2. Run the setup command:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh)
```

3. Answer the interactive prompts (press Enter for default "yes")

4. Make your first commit:
```bash
npm run commit
```

5. Follow the Commitizen prompts

6. Push to your repository:
```bash
git push
```

---

### Windows

1. Navigate to your project:
```cmd
cd my-awesome-project
```

2. Run the setup command (choose your preferred method):

   **PowerShell:**
   ```powershell
   iwr -Uri "https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh" -OutFile "$env:TEMP\setup-husky.sh"; bash "$env:TEMP\setup-husky.sh"; Remove-Item "$env:TEMP\setup-husky.sh"
   ```

   **Git Bash:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh | bash
   ```

   **CMD:**
   ```cmd
   curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh -o %TEMP%\setup-husky.sh && bash %TEMP%\setup-husky.sh && del %TEMP%\setup-husky.sh
   ```

3. Answer the interactive prompts (press Enter for default "yes")

4. Make your first commit:
```bash
npm run commit
```

5. Follow the Commitizen prompts

6. Push to your repository:
```bash
git push
```

## 🤝 Contributing

Feel free to open issues or submit pull requests to improve this template!

## 📄 License

MIT License - feel free to use this in your projects!

## 🙏 Acknowledgments

- [Husky](https://typicode.github.io/husky/)
- [Commitizen](https://commitizen.github.io/cz-cli/)
- [Commitlint](https://commitlint.js.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

**Note**: Replace `infosaqib/husky-commitizen-template` with your actual GitHub username and repository name in all commands.
