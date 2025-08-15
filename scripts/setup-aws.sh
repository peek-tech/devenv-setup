#!/bin/bash

# AWS Development Tools Setup
# Installs AWS CLI, SAM CLI, CDK, and other AWS development tools

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠️${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ️${NC} $1"; }

# Detect OS
OS="$(uname -s)"
ARCH="$(uname -m)"

echo ""
echo -e "${BLUE}☁️  AWS Development Tools Setup${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Install AWS CLI v2
install_aws_cli() {
    if command -v aws &> /dev/null; then
        print_status "AWS CLI already installed: $(aws --version)"
    else
        print_info "Installing AWS CLI v2..."
        
        case "${OS}" in
            Darwin*)
                if command -v brew &> /dev/null; then
                    brew install awscli
                else
                    print_error "Homebrew not found. Please install Homebrew first."
                    return 1
                fi
                ;;
            Linux*)
                curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "awscliv2.zip"
                unzip -q awscliv2.zip
                sudo ./aws/install
                rm -rf aws awscliv2.zip
                ;;
        esac
        
        print_status "AWS CLI installed: $(aws --version)"
    fi
}

# Install Session Manager Plugin
install_session_manager() {
    print_info "Installing AWS Session Manager Plugin..."
    
    case "${OS}" in
        Darwin*)
            if command -v brew &> /dev/null; then
                brew install --cask session-manager-plugin
            else
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        Linux*)
            curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
            sudo dpkg -i session-manager-plugin.deb
            rm session-manager-plugin.deb
            ;;
    esac
    
    print_status "Session Manager Plugin installed"
}

# Install AWS SAM CLI
install_sam_cli() {
    if command -v sam &> /dev/null; then
        print_status "AWS SAM CLI already installed: $(sam --version)"
    else
        print_info "Installing AWS SAM CLI..."
        
        case "${OS}" in
            Darwin*)
                if command -v brew &> /dev/null; then
                    brew install aws-sam-cli
                else
                    print_error "Homebrew not found. Please install Homebrew first."
                    return 1
                fi
                ;;
            Linux*)
                wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
                unzip -q aws-sam-cli-linux-x86_64.zip -d sam-installation
                sudo ./sam-installation/install
                rm -rf sam-installation aws-sam-cli-linux-x86_64.zip
                ;;
        esac
        
        print_status "AWS SAM CLI installed"
    fi
}

# Install AWS CDK
install_cdk() {
    if command -v cdk &> /dev/null; then
        print_status "AWS CDK already installed: $(cdk --version)"
    else
        print_info "Installing AWS CDK..."
        
        # Check if npm is installed
        if ! command -v npm &> /dev/null; then
            print_warning "npm not found. Installing Node.js first..."
            
            case "${OS}" in
                Darwin*)
                    brew install node
                    ;;
                Linux*)
                    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                    ;;
            esac
        fi
        
        npm install -g aws-cdk
        print_status "AWS CDK installed: $(cdk --version)"
    fi
}


# Configure AWS CLI
configure_aws() {
    print_info "Checking AWS configuration..."
    
    if [ ! -f ~/.aws/credentials ] && [ ! -f ~/.aws/config ]; then
        print_warning "AWS CLI not configured"
        echo "Would you like to configure AWS CLI now? (y/n)"
        read -r response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            aws configure
        else
            print_info "You can configure AWS CLI later with: aws configure"
        fi
    else
        print_status "AWS configuration found"
        
        # Setup AWS profile selector
        if [ -f ~/.aws/config ]; then
            print_info "Available AWS profiles:"
            grep '\[profile' ~/.aws/config | sed 's/\[profile /  • /g' | sed 's/\]//g'
            grep '\[default\]' ~/.aws/config > /dev/null 2>&1 && echo "  • default"
        fi
    fi
}

# Install additional AWS tools
install_additional_tools() {
    print_info "Installing additional AWS tools..."
    
    # Install aws-vault for secure credential storage
    case "${OS}" in
        Darwin*)
            if command -v brew &> /dev/null; then
                brew install --cask aws-vault
                print_status "aws-vault installed"
            fi
            ;;
        Linux*)
            wget https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-amd64
            sudo mv aws-vault-linux-amd64 /usr/local/bin/aws-vault
            sudo chmod +x /usr/local/bin/aws-vault
            print_status "aws-vault installed"
            ;;
    esac
}

# Main execution
main() {
    install_aws_cli
    install_session_manager
    install_sam_cli
    install_cdk
    install_additional_tools
    configure_aws
    
    print_status "AWS development tools setup complete!"
    echo ""
    echo "Installed tools:"
    echo "  • AWS CLI v2"
    echo "  • AWS Session Manager Plugin"
    echo "  • AWS SAM CLI"
    echo "  • AWS CDK"
    echo "  • aws-vault"
    echo ""
    echo "Next steps:"
    echo "  • Configure AWS profiles: aws configure --profile <profile-name>"
    echo "  • Initialize CDK: cdk bootstrap"
    echo "  • Set default region: export AWS_DEFAULT_REGION=us-east-1"
}

main "$@"