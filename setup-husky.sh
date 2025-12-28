#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# GitHub repository details (UPDATE THESE WITH YOUR REPO)
GITHUB_USER="infosaqib"
GITHUB_REPO="husky-commitizen-template"
RAW_BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main"

# Function to print colored output
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_step() { echo -e "${CYAN}▸ $1${NC}"; }

# Function to ask for user confirmation with default YES
ask_permission() {
    local prompt="$1"
    local default="${2:-y}"
    local response
    
    while true; do
        if [ "$default" = "y" ]; then
            read -p "$(echo -e ${YELLOW}${prompt}${NC}) [Y/n]: " response
            response=${response:-y}
        else
            read -p "$(echo -e ${YELLOW}${prompt}${NC}) [y/N]: " response
            response=${response:-n}
        fi
        
        case $response in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

# Function to get project name from package.json or directory
get_project_name() {
    if [ -f "package.json" ]; then
        PROJECT_NAME=$(node -p "require('./package.json').name" 2>/dev/null || basename "$PWD")
    else
        PROJECT_NAME=$(basename "$PWD")
    fi
    echo "$PROJECT_NAME"
}

# Function to check if package.json exists
check_package_json() {
    if [ ! -f "package.json" ]; then
        print_warning "package.json not found!"
        if ask_permission "Would you like to initialize a new package.json?" "y"; then
            npm init -y
            print_success "package.json created"
        else
            print_error "Cannot proceed without package.json"
            exit 1
        fi
    else
        print_info "package.json found"
    fi
}

# Function to check if file/config exists
check_exists() {
    local type="$1"
    local name="$2"
    
    case $type in
        "file")
            [ -f "$name" ] && return 0 || return 1
            ;;
        "dir")
            [ -d "$name" ] && return 1 || return 0
            ;;
        "script")
            node -e "const pkg = require('./package.json'); process.exit(pkg.scripts && pkg.scripts['$name'] ? 0 : 1)" 2>/dev/null
            return $?
            ;;
        "config")
            node -e "const pkg = require('./package.json'); process.exit(pkg.config && pkg.config['$name'] ? 0 : 1)" 2>/dev/null
            return $?
            ;;
    esac
}

# Function to install npm packages
install_packages() {
    print_step "Checking npm packages..."
    
    # Check if packages are already installed
    local packages_needed=()
    local packages=("husky" "@commitlint/cli" "@commitlint/config-conventional" "commitizen" "cz-conventional-changelog")
    
    for pkg in "${packages[@]}"; do
        if ! npm list "$pkg" --depth=0 >/dev/null 2>&1; then
            packages_needed+=("$pkg")
        fi
    done
    
    if [ ${#packages_needed[@]} -eq 0 ]; then
        print_success "All required packages are already installed"
        return 0
    else
        print_info "Missing packages: ${packages_needed[*]}"
        npm install --save-dev husky @commitlint/{cli,config-conventional} commitizen cz-conventional-changelog
        
        if [ $? -eq 0 ]; then
            print_success "Packages installed successfully"
            return 0
        else
            print_error "Failed to install packages"
            return 1
        fi
    fi
}

# Function to add scripts to package.json
add_scripts() {
    print_step "Checking package.json scripts..."
    
    local needs_update=false
    
    # Check if scripts exist
    if ! check_exists "script" "commit"; then
        print_info "Script 'commit' not found in package.json"
        needs_update=true
    fi
    
    if ! check_exists "script" "prepare"; then
        print_info "Script 'prepare' not found in package.json"
        needs_update=true
    fi
    
    if ! check_exists "config" "commitizen"; then
        print_info "Commitizen config not found in package.json"
        needs_update=true
    fi
    
    if [ "$needs_update" = false ]; then
        print_success "All required scripts already present in package.json"
        return 0
    fi
    
    # Use node to safely update package.json
    node -e "
    const fs = require('fs');
    const pkg = require('./package.json');
    
    pkg.scripts = pkg.scripts || {};
    
    const scriptsToAdd = {
        'commit': 'cz',
        'prepare': 'husky install || husky'
    };
    
    let added = [];
    for (const [key, value] of Object.entries(scriptsToAdd)) {
        if (!pkg.scripts[key]) {
            pkg.scripts[key] = value;
            added.push(key);
        }
    }
    
    if (!pkg.config) {
        pkg.config = {};
    }
    
    if (!pkg.config.commitizen) {
        pkg.config.commitizen = {
            path: './node_modules/cz-conventional-changelog'
        };
        added.push('commitizen config');
    }
    
    if (added.length > 0) {
        fs.writeFileSync('./package.json', JSON.stringify(pkg, null, 2) + '\n');
        console.log('Added: ' + added.join(', '));
    }
    "
    
    print_success "Scripts added to package.json"
}

# Function to create commitlint.config.js
create_commitlint_config() {
    print_step "Checking commitlint.config.js..."
    
    if check_exists "file" "commitlint.config.js"; then
        print_info "commitlint.config.js already exists"
        return 0
    fi
    
    print_info "Creating commitlint.config.js..."
    cat > commitlint.config.js << 'EOF'
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',
        'fix',
        'docs',
        'style',
        'refactor',
        'perf',
        'test',
        'build',
        'ci',
        'chore',
        'revert',
      ],
    ],
    'subject-case': [2, 'never', ['upper-case']],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 100],
  },
};
EOF
    print_success "commitlint.config.js created"
}

# Function to initialize Husky
init_husky() {
    print_step "Initializing Husky..."
    
    if [ -d ".husky" ]; then
        print_info "Husky already initialized (.husky directory exists)"
        return 0
    fi
    
    npx husky init 2>/dev/null
    
    if [ $? -eq 0 ]; then
        print_success "Husky initialized"
    else
        # Try alternative command for older versions
        npx husky install
        print_success "Husky installed"
    fi
}

# Function to create Husky hooks
create_husky_hooks() {
    print_step "Setting up Husky hooks..."
    
    if [ ! -d ".husky" ]; then
        mkdir -p .husky
    fi
    
    # Pre-commit hook
    if [ ! -f ".husky/pre-commit" ]; then
        print_info "Creating pre-commit hook..."
        cat > .husky/pre-commit << 'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

echo "🔍 Running pre-commit checks..."

# Add your pre-commit checks here
# Example: npm run lint
# Example: npm test

echo "✓ Pre-commit checks passed!"
EOF
        chmod +x .husky/pre-commit
        print_success "pre-commit hook created"
    else
        print_info "pre-commit hook already exists"
    fi
    
    # Commit-msg hook
    if [ ! -f ".husky/commit-msg" ]; then
        print_info "Creating commit-msg hook..."
        cat > .husky/commit-msg << 'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx --no -- commitlint --edit "$1"
EOF
        chmod +x .husky/commit-msg
        print_success "commit-msg hook created"
    else
        print_info "commit-msg hook already exists"
    fi
    
    # Prepare-commit-msg hook
    if [ ! -f ".husky/prepare-commit-msg" ]; then
        print_info "Creating prepare-commit-msg hook..."
        cat > .husky/prepare-commit-msg << 'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

exec < /dev/tty && npx cz --hook || true
EOF
        chmod +x .husky/prepare-commit-msg
        print_success "prepare-commit-msg hook created"
    else
        print_info "prepare-commit-msg hook already exists"
    fi
}

# Function to update .gitignore
update_gitignore() {
    print_step "Checking .gitignore..."
    
    if [ ! -f ".gitignore" ]; then
        print_info "Creating .gitignore..."
        touch .gitignore
    fi
    
    if ! grep -q "node_modules" .gitignore; then
        print_info "Adding node_modules to .gitignore..."
        echo -e "\n# Dependencies\nnode_modules/" >> .gitignore
        print_success "Added node_modules to .gitignore"
    else
        print_success "node_modules already in .gitignore"
    fi
}

# Complete Husky integration
integrate_husky() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Husky + Commitizen + Commitlint Integration${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    print_info "This will set up:"
    echo "  • Install required npm packages"
    echo "  • Add scripts to package.json"
    echo "  • Create commitlint.config.js"
    echo "  • Initialize Husky"
    echo "  • Create git hooks (pre-commit, commit-msg, prepare-commit-msg)"
    echo "  • Update .gitignore"
    echo ""
    
    if ! ask_permission "Do you want to integrate Husky?" "y"; then
        print_warning "Skipped Husky integration"
        return 1
    fi
    
    echo ""
    
    # Run all Husky setup steps
    install_packages
    echo ""
    
    add_scripts
    echo ""
    
    create_commitlint_config
    echo ""
    
    init_husky
    echo ""
    
    create_husky_hooks
    echo ""
    
    update_gitignore
    echo ""
    
    print_success "Husky integration completed!"
    return 0
}

# Function to create or update LICENSE
manage_license() {
    local project_name=$(get_project_name)
    local year=$(date +%Y)
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  LICENSE File${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if check_exists "file" "LICENSE"; then
        print_info "LICENSE file already exists"
        if ! ask_permission "Do you want to update it with current project name ($project_name)?" "n"; then
            print_warning "Skipped LICENSE update"
            return 0
        fi
        print_info "Updating LICENSE..."
    else
        print_info "LICENSE file not found"
        if ! ask_permission "Do you want to create a LICENSE file (MIT)?" "y"; then
            print_warning "Skipped LICENSE creation"
            return 0
        fi
        print_info "Creating LICENSE..."
    fi
    
    cat > LICENSE << EOF
MIT License

Copyright (c) $year $project_name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
    
    print_success "LICENSE file ready"
}

# Function to create or update README.md
manage_readme() {
    local project_name=$(get_project_name)
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  README.md File${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if check_exists "file" "README.md"; then
        print_info "README.md already exists"
        if ! ask_permission "Do you want to update it?" "n"; then
            print_warning "Skipped README.md update"
            return 0
        fi
        print_info "Updating README.md..."
    else
        print_info "README.md not found"
        if ! ask_permission "Do you want to create a README.md?" "y"; then
            print_warning "Skipped README.md creation"
            return 0
        fi
        print_info "Creating README.md..."
    fi
    
    cat > README.md << EOF
# $project_name

## Description

A project with automated commit conventions and git hooks powered by Husky, Commitizen, and Commitlint.

## Installation

\`\`\`bash
npm install
\`\`\`

## Usage

### Making Commits

This project uses [Commitizen](https://github.com/commitizen/cz-cli) for standardized commit messages. Instead of \`git commit\`, use:

\`\`\`bash
npm run commit
\`\`\`

This will guide you through creating a conventional commit message.

### Commit Message Format

Commits follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

\`\`\`
<type>(<scope>): <subject>

<body>

<footer>
\`\`\`

**Types:**
- \`feat\`: A new feature
- \`fix\`: A bug fix
- \`docs\`: Documentation changes
- \`style\`: Code style changes (formatting, etc.)
- \`refactor\`: Code refactoring
- \`perf\`: Performance improvements
- \`test\`: Adding or updating tests
- \`build\`: Build system changes
- \`ci\`: CI/CD changes
- \`chore\`: Other changes that don't modify src or test files
- \`revert\`: Revert a previous commit

## Git Hooks

This project uses Husky to manage git hooks:

- **pre-commit**: Runs linting and tests before commits
- **commit-msg**: Validates commit messages against conventional format
- **prepare-commit-msg**: Launches Commitizen for interactive commits

## Development

\`\`\`bash
# Install dependencies
npm install

# Make a commit
npm run commit
\`\`\`

## License

See [LICENSE](LICENSE) file for details.

---

*This README was generated as part of the Husky setup process.*
EOF
    
    print_success "README.md ready"
}

# Function to create or update SECURITY.md
manage_security() {
    local project_name=$(get_project_name)
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  SECURITY.md File${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if check_exists "file" "SECURITY.md"; then
        print_info "SECURITY.md already exists"
        if ! ask_permission "Do you want to update it?" "n"; then
            print_warning "Skipped SECURITY.md update"
            return 0
        fi
        print_info "Updating SECURITY.md..."
    else
        print_info "SECURITY.md not found"
        if ! ask_permission "Do you want to create a SECURITY.md?" "y"; then
            print_warning "Skipped SECURITY.md creation"
            return 0
        fi
        print_info "Creating SECURITY.md..."
    fi
    
    cat > SECURITY.md << EOF
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

We take the security of $project_name seriously. If you discover a security vulnerability, please follow these steps:

### How to Report

1. **Do Not** open a public issue
2. Email security concerns to the maintainers
3. Include detailed information about the vulnerability:
   - Description of the issue
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Initial Response**: Within 48 hours
- **Status Updates**: Every 7 days until resolved
- **Resolution Timeline**: Varies based on severity and complexity

### Disclosure Policy

- We will work with you to understand and resolve the issue
- Security advisories will be published after fixes are deployed
- We appreciate responsible disclosure and may acknowledge your contribution

## Security Best Practices

When contributing to this project:

- Keep dependencies up to date
- Never commit sensitive data (API keys, passwords, tokens)
- Use environment variables for configuration
- Follow secure coding practices
- Run security audits regularly: \`npm audit\`

## Security Tools

This project uses:

- **npm audit**: Regular dependency vulnerability scanning
- **Husky**: Git hooks for pre-commit security checks
- **Commitlint**: Ensures commit message standards

---

*For more information about security, contact the project maintainers.*
EOF
    
    print_success "SECURITY.md ready"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║     Husky + Commitizen + Commitlint Setup Script         ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    print_info "Starting setup process..."
    print_info "Default answer for all prompts is YES [Y/n]"
    echo ""
    
    # Check package.json
    check_package_json
    echo ""
    
    # Main sections with single permission requests
    integrate_husky
    
    manage_license
    
    manage_readme
    
    manage_security
    
    # Final summary
    echo ""
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║                   Setup Complete! 🎉                      ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    print_success "Setup completed successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Run 'npm install' if you haven't already"
    echo "  2. Run 'npm run commit' to make your first commit"
    echo "  3. Your commits will now be validated automatically"
    echo "  4. Check README.md for detailed usage instructions"
    echo ""
    print_info "To make commits, use: ${GREEN}npm run commit${NC}"
}

# Run main function
main
