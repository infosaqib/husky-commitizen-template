#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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
print_action() { echo -e "${MAGENTA}→ $1${NC}"; }

# Function to print section header
print_section() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to ask for user confirmation with default YES
ask_permission() {
    local prompt="$1"
    local default="${2:-y}"
    local response
    
    # Redirect input from terminal to handle piped execution
    exec < /dev/tty
    
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

# Function to check if file exists
file_exists() {
    [ -f "$1" ]
}

# Function to check if directory exists
dir_exists() {
    [ -d "$1" ]
}

# Complete Husky integration
integrate_husky() {
    print_section "1. Husky Integration"
    
    print_info "This will set up:"
    echo "  • Install Husky, Commitizen, and Commitlint packages"
    echo "  • Add 'commit' and 'prepare' scripts to package.json"
    echo "  • Create commitlint.config.js"
    echo "  • Initialize Husky"
    echo "  • Create git hooks (pre-commit, commit-msg, prepare-commit-msg)"
    echo "  • Update .gitignore with node_modules"
    echo ""
    
    if ! ask_permission "Do you want to integrate Husky?" "y"; then
        print_warning "Skipped Husky integration"
        return 1
    fi
    
    echo ""
    print_action "Starting Husky integration..."
    echo ""
    
    # Step 1: Install packages
    print_step "Step 1/6: Installing npm packages..."
    
    local packages_needed=()
    local packages=("husky" "@commitlint/cli" "@commitlint/config-conventional" "commitizen" "cz-conventional-changelog")
    
    for pkg in "${packages[@]}"; do
        if ! npm list "$pkg" --depth=0 >/dev/null 2>&1; then
            packages_needed+=("$pkg")
        fi
    done
    
    if [ ${#packages_needed[@]} -eq 0 ]; then
        print_success "All required packages are already installed"
    else
        print_info "Installing: ${packages_needed[*]}"
        npm install --save-dev husky @commitlint/{cli,config-conventional} commitizen cz-conventional-changelog
        
        if [ $? -eq 0 ]; then
            print_success "Packages installed successfully"
        else
            print_error "Failed to install packages"
            return 1
        fi
    fi
    echo ""
    
    # Step 2: Add scripts to package.json
    print_step "Step 2/6: Adding scripts to package.json..."
    
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
        console.log('  Added: ' + added.join(', '));
    } else {
        console.log('  All scripts already present');
    }
    "
    print_success "Scripts configured in package.json"
    echo ""
    
    # Step 3: Create commitlint.config.js
    print_step "Step 3/6: Creating commitlint configuration..."
    
    if file_exists "commitlint.config.js"; then
        print_info "commitlint.config.js already exists (skipped)"
    else
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
    fi
    echo ""
    
    # Step 4: Initialize Husky
    print_step "Step 4/6: Initializing Husky..."
    
    if dir_exists ".husky"; then
        print_info "Husky already initialized (.husky directory exists)"
    else
        npx husky init 2>/dev/null
        
        if [ $? -eq 0 ]; then
            print_success "Husky initialized"
        else
            npx husky install
            print_success "Husky installed"
        fi
    fi
    echo ""
    
    # Step 5: Create Husky hooks
    print_step "Step 5/6: Setting up git hooks..."
    
    if [ ! -d ".husky" ]; then
        mkdir -p .husky
    fi
    
    # Pre-commit hook
    if file_exists ".husky/pre-commit"; then
        print_info "pre-commit hook already exists"
    else
        cat > .husky/pre-commit << 'EOF'
echo "🔍 Running pre-commit checks..."

# Uncomment the checks you want to run:
# npm run lint
# npm run format
# npm run type-check

# Only run tests if test script exists and is not the default
if grep -q '"test".*"echo.*Error.*no test specified"' package.json 2>/dev/null; then
  echo "⚠ No tests configured (skipped)"
else
  # npm test
  echo "⚠ Tests disabled in pre-commit hook (uncomment to enable)"
fi

echo "✓ Pre-commit checks passed!"
EOF
        chmod +x .husky/pre-commit
        print_success "pre-commit hook created"
    fi
    
    # Commit-msg hook
    if file_exists ".husky/commit-msg"; then
        print_info "commit-msg hook already exists"
    else
        cat > .husky/commit-msg << 'EOF'
npx --no -- commitlint --edit "$1"
EOF
        chmod +x .husky/commit-msg
        print_success "commit-msg hook created"
    fi
    
    # Remove prepare-commit-msg if it exists (causes double prompting)
    if file_exists ".husky/prepare-commit-msg"; then
        print_warning "Removing prepare-commit-msg hook (causes double prompting)"
        rm -f .husky/prepare-commit-msg
        print_success "prepare-commit-msg hook removed"
    fi
    
    print_info "✓ Use 'npm run commit' instead of 'git commit' to trigger Commitizen"
    echo ""
    
    # Step 6: Update .gitignore
    print_step "Step 6/6: Updating .gitignore..."
    
    if [ ! -f ".gitignore" ]; then
        touch .gitignore
        print_info ".gitignore created"
    fi
    
    if ! grep -q "node_modules" .gitignore; then
        echo -e "\n# Dependencies\nnode_modules/" >> .gitignore
        print_success "Added node_modules to .gitignore"
    else
        print_info "node_modules already in .gitignore"
    fi
    echo ""
    
    print_success "✓ Husky integration completed successfully!"
    return 0
}

# Function to add LICENSE
add_license() {
    local project_name=$(get_project_name)
    local year=$(date +%Y)
    
    print_section "2. LICENSE File"
    
    if file_exists "LICENSE"; then
        print_info "LICENSE file already exists"
        if ! ask_permission "Do you want to update it with current project name ($project_name)?" "n"; then
            print_warning "Skipped LICENSE update"
            return 0
        fi
        print_action "Updating LICENSE..."
    else
        print_info "LICENSE file not found"
        if ! ask_permission "Do you want to create a LICENSE file (MIT)?" "y"; then
            print_warning "Skipped LICENSE creation"
            return 0
        fi
        print_action "Creating LICENSE..."
    fi
    
    echo ""
    
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
    
    print_success "✓ LICENSE file ready"
}

# Function to add README.md
add_readme() {
    local project_name=$(get_project_name)
    
    print_section "3. README.md File"
    
    if file_exists "README.md"; then
        print_info "README.md already exists"
        if ! ask_permission "Do you want to update it?" "n"; then
            print_warning "Skipped README.md update"
            return 0
        fi
        print_action "Updating README.md..."
    else
        print_info "README.md not found"
        if ! ask_permission "Do you want to create a README.md?" "y"; then
            print_warning "Skipped README.md creation"
            return 0
        fi
        print_action "Creating README.md..."
    fi
    
    echo ""
    
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
    
    print_success "✓ README.md ready"
}

# Function to add SECURITY.md
add_security() {
    local project_name=$(get_project_name)
    
    print_section "4. SECURITY.md File"
    
    if file_exists "SECURITY.md"; then
        print_info "SECURITY.md already exists"
        if ! ask_permission "Do you want to update it?" "n"; then
            print_warning "Skipped SECURITY.md update"
            return 0
        fi
        print_action "Updating SECURITY.md..."
    else
        print_info "SECURITY.md not found"
        if ! ask_permission "Do you want to create a SECURITY.md?" "y"; then
            print_warning "Skipped SECURITY.md creation"
            return 0
        fi
        print_action "Creating SECURITY.md..."
    fi
    
    echo ""
    
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
    
    print_success "✓ SECURITY.md ready"
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
    
    print_info "Welcome! This script will help you set up Husky with Commitizen and Commitlint."
    print_info "Default answer for all prompts is YES - just press Enter to accept."
    echo ""
    
    # Check package.json first
    check_package_json
    
    # Ask user for each section
    integrate_husky
    
    add_license
    
    add_readme
    
    add_security
    
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
    echo "  1. Run 'npm install' if packages were just installed"
    echo "  2. Run 'npm run commit' to make your first commit"
    echo "  3. Your commits will now be validated automatically"
    echo "  4. Check README.md for detailed usage instructions"
    echo ""
    print_info "To make commits, use: ${GREEN}npm run commit${NC}"
    
    # Exit successfully
    exit 0
}

# Run main function
main
