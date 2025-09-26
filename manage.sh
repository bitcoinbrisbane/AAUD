#!/bin/bash

# AAUD Token Project Management Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}AAUD Token Swap Project${NC}"
echo "========================"

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "foundry.toml" ]]; then
    print_error "Please run this script from the AAUD project root directory"
    exit 1
fi

case "$1" in
    "install")
        echo "Installing dependencies..."
        print_status "Installing frontend dependencies"
        cd frontend && npm install
        cd ..
        print_status "Dependencies installed"
        ;;
    
    "build")
        echo "Building project..."
        print_status "Building smart contracts"
        if command -v forge &> /dev/null; then
            forge build
        else
            print_warning "Foundry not installed, skipping smart contract build"
        fi
        
        print_status "Building frontend"
        cd frontend && npm run build
        cd ..
        print_status "Build completed"
        ;;
    
    "test")
        echo "Running tests..."
        if command -v forge &> /dev/null; then
            print_status "Running smart contract tests"
            forge test
        else
            print_warning "Foundry not installed, skipping smart contract tests"
        fi
        print_status "All tests completed"
        ;;
    
    "dev")
        echo "Starting development server..."
        cd frontend && npm run dev
        ;;
    
    "deploy-local")
        echo "Deploying to local network..."
        if command -v forge &> /dev/null; then
            print_status "Starting local deployment"
            forge script script/Deploy.s.sol --rpc-url localhost --broadcast
        else
            print_error "Foundry not installed"
            exit 1
        fi
        ;;
    
    "clean")
        echo "Cleaning build artifacts..."
        rm -rf out/
        rm -rf cache/
        rm -rf broadcast/
        rm -rf frontend/dist/
        rm -rf frontend/node_modules/.vite
        print_status "Clean completed"
        ;;
    
    "setup")
        echo "Setting up project..."
        print_status "Installing frontend dependencies"
        cd frontend && npm install
        cd ..
        
        if [[ ! -f ".env" ]]; then
            cp .env.example .env
            print_warning "Created .env file from template. Please update with your values."
        fi
        
        print_status "Project setup completed"
        print_warning "Don't forget to:"
        echo "  1. Update .env with your API keys"
        echo "  2. Deploy contracts and update addresses in frontend/src/config/web3.ts"
        ;;
    
    *)
        echo "Usage: $0 {install|build|test|dev|deploy-local|clean|setup}"
        echo ""
        echo "Commands:"
        echo "  install       Install dependencies"
        echo "  build         Build smart contracts and frontend"
        echo "  test          Run smart contract tests"
        echo "  dev           Start development server"
        echo "  deploy-local  Deploy contracts to local network"
        echo "  clean         Clean build artifacts"
        echo "  setup         Initial project setup"
        exit 1
        ;;
esac