# Husky + Commitizen + Commitlint Template

Automated Git commit conventions and hooks setup for any project.

## 🚀 Quick Start

Run this single command in your project directory:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh)
```

**Alternative methods:**

Using wget:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh)
```

Using temporary download (auto-cleanup):
```bash
(cd /tmp && curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh -o husky-setup-temp.sh && cd - && bash /tmp/husky-setup-temp.sh && rm -f /tmp/husky-setup-temp.sh)
```

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

If you prefer to review the script first:

1. Download the script:
```bash
curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh -o setup-husky.sh
```

2. Review it:
```bash
cat setup-husky.sh
```

3. Make it executable and run:
```bash
chmod +x setup-husky.sh
./setup-husky.sh
```

4. Clean up (optional):
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

1. Navigate to your project:
```bash
cd my-awesome-project
```

2. Run the setup command:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/infosaqib/husky-commitizen-template/main/setup-husky.sh)
```

3. Answer the interactive prompts (typically all "yes")

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
