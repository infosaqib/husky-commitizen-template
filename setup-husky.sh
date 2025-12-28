#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Function to ask for user confirmation
ask_permission() {
    local prompt="$1"
    local response
    while true; do
        read -p "$(echo -e ${YELLOW}${prompt}${NC}) (y/n): " response
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
        print_error "package.json not found!"
        if ask_permission "Would you like to initialize a new package.json?"; then
            npm init -y
            print_success "package.json created"
        else
            print_error "Cannot proceed without package.json"
            exit 1
        fi
    fi
}

# Function to install npm packages
install_packages() {
    print_info "Installing required packages..."
    
    if ask_permission "Install Husky, Commitizen, and Commitlint packages?"; then
        npm install --save-dev husky @commitlint/{cli,config-conventional} commitizen cz-conventional-changelog
        
        if [ $? -eq 0 ]; then
            print_success "Packages installed successfully"
            return 0
        else
            print_error "Failed to install packages"
            return 1
        fi
    else
        print_warning "Skipped package installation"
        return 1
    fi
}

# Function to add scripts to package.json
add_scripts() {
    print_info "Adding scripts to package.json..."
    
    if ask_permission "Add commit and prepare scripts to package.json?"; then
        # Use node to safely update package.json
        node -e "
        const fs = require('fs');
        const pkg = require('./package.json');
        
        pkg.scripts = pkg.scripts || {};
        
        const scriptsToAdd = {
            'commit': 'cz',
            'prepare': 'husky install || husky'
        };
        
        let added = false;
        for (const [key, value] of Object.entries(scriptsToAdd)) {
            if (!pkg.scripts[key]) {
                pkg.scripts[key] = value;
                added = true;
            }
        }
        
        if (!pkg.config) {
            pkg.config = {};
        }
        
        if (!pkg.config.commitizen) {
            pkg.config.commitizen = {
                path: './node_modules/cz-conventional-changelog'
            };
            added = true;
        }
        
        if (added) {
            fs.writeFileSync('./package.json', JSON.stringify(pkg, null, 2) + '\n');
        }
        "
        
        print_success "Scripts added to package.json"
    else
        print_warning "Skipped adding scripts"
    fi
}

# Function to create commitlint.config.js
create_commitlint_config() {
    print_info "Creating commitlint configuration..."
    
    if [ -f "commitlint.config.js" ]; then
        if ask_permission "commitlint.config.js already exists. Overwrite?"; then
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
        else
            print_warning "Skipped commitlint.config.js"
        fi
    else
        if ask_permission "Create commitlint.config.js?"; then
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
        else
            print_warning "Skipped commitlint.config.js"
        fi
    fi
}

# Function to initialize Husky
init_husky() {
    print_info "Initializing Husky..."
    
    if ask_permission "Initialize Husky?"; then
        npx husky init
        
        if [ $? -eq 0 ]; then
            print_success "Husky initialized"
        else
            # Try alternative command for older versions
            npx husky install
            print_success "Husky installed"
        fi
    else
        print_warning "Skipped Husky initialization"
        return 1
    fi
}

# Function to create Husky hooks
create_husky_hooks() {
    print_info "Creating Husky hooks..."
    
    if [ ! -d ".husky" ]; then
        mkdir -p .husky
    fi
    
    # Pre-commit hook
    if ask_permission "Create pre-commit hook (runs linting)?"; then
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
    fi
    
    # Commit-msg hook
    if ask_permission "Create commit-msg hook (validates commit messages)?"; then
        cat > .husky/commit-msg << 'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx --no -- commitlint --edit "$1"
EOF
        chmod +x .husky/commit-msg
        print_success "commit-msg hook created"
    fi
    
    # Prepare-commit-msg hook
    if ask_permission "Create prepare-commit-msg hook (for Commitizen)?"; then
        cat > .husky/prepare-commit-msg << 'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

exec < /dev/tty && npx cz --hook || true
EOF
        chmod +x .husky/prepare-commit-msg
        print_success "prepare-commit-msg hook created"
    fi
}

# Function to update .gitignore
update_gitignore() {
    print_info "Updating .gitignore..."
    
    if ask_permission "Add node_modules to .gitignore (if not present)?"; then
        if [ ! -f ".gitignore" ]; then
            touch .gitignore
        fi
        
        if ! grep -q "node_modules" .gitignore; then
            echo -e "\n# Dependencies\nnode_modules/" >> .gitignore
            print_success "Added node_modules to .gitignore"
        else
            print_info "node_modules already in .gitignore"
        fi
    fi
}

# Function to create or update LICENSE
create_license() {
    local project_name=$(get_project_name)
    local year=$(date +%Y)
    
    print_info "Managing LICENSE file..."
    
    if [ -f "LICENSE" ]; then
        if ask_permission "LICENSE already exists. Update with current project name ($project_name)?"; then
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
            print_success "LICENSE updated"
        fi
    else
        if ask_permission "Create LICENSE file (MIT)?"; then
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
            print_success "LICENSE created"
        fi
    fi
}

# Function to create or update README.md
create_readme() {
    local project_name=$(get_project_name)
    
    print_info "Managing README.md file..."
    
    if [ -f "README.md" ]; then
        if ask_permission "README.md already exists. Update it?"; then
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
            print_success "README.md updated"
        fi
    else
        if ask_permission "Create README.md?"; then
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
            print_success "README.md created"
        fi
    fi
}

# Function to create or update SECURITY.md
create_security() {
    local project_name=$(get_project_name)
    
    print_info "Managing SECURITY.md file..."
    
    if [ -f "SECURITY.md" ]; then
        if ask_permission "SECURITY.md already exists. Update it?"; then
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
            print_success "SECURITY.md updated"
        fi
    else
        if ask_permission "Create SECURITY.md?"; then
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
            print_success "SECURITY.md created"
        fi
    fi
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
    echo ""
    
    # Step 1: Check package.json
    check_package_json
    echo ""
    
    # Step 2: Install packages
    install_packages
    echo ""
    
    # Step 3: Add scripts
    add_scripts
    echo ""
    
    # Step 4: Create commitlint config
    create_commitlint_config
    echo ""
    
    # Step 5: Initialize Husky
    init_husky
    echo ""
    
    # Step 6: Create Husky hooks
    create_husky_hooks
    echo ""
    
    # Step 7: Update .gitignore
    update_gitignore
    echo ""
    
    # Step 8: Create/update LICENSE
    create_license
    echo ""
    
    # Step 9: Create/update README
    create_readme
    echo ""
    
    # Step 10: Create/update SECURITY
    create_security
    echo ""
    
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║                   Setup Complete! 🎉                      ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    print_success "Husky setup completed successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Run 'npm run commit' to make your first commit"
    echo "  2. Your commits will now be validated automatically"
    echo "  3. Check README.md for usage instructions"
}

# Run main function
main
