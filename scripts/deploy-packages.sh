#!/bin/bash
# AT4DX Enterprise Example - Package Deployment Script
# This script demonstrates how to deploy the packages in the correct order

set -e  # Exit immediately if a command exits with a non-zero status

# Configuration
# ----------------------------------------------------------------------------
SCRATCH_ORG_ALIAS="at4dx-enterprise"  # Change this to match your org alias
DEPLOY_ALL=false
TARGET_PACKAGE=""

# Function Definitions
# ----------------------------------------------------------------------------

# Print usage information
function print_usage {
  echo "Usage: $0 [options] [package]"
  echo ""
  echo "Options:"
  echo "  -a, --all                 Deploy all packages in dependency order"
  echo "  -h, --help                Show this help message"
  echo ""
  echo "Packages:"
  echo "  shared-services           Core utilities and cross-cutting concerns"
  echo "  account-management        Account domain implementation"
  echo "  product-management        Product domain implementation"
  echo "  marketing                 Marketing extension package"
  echo "  sales                     Sales package"
  echo "  service                   Service package"
  echo "  operations                Operations package"
  echo "  finance                   Finance package"
  echo "  legal                     Legal package"
  echo "  happysoup                 Non-packageable components"
  echo ""
  echo "When deploying a specific package, this script will automatically"
  echo "deploy its dependencies first."
}

# Deploy a specific package and log results
function deploy_package {
  local package_name=$1
  echo "----------------------------------------"
  echo "Deploying $package_name package..."
  echo "----------------------------------------"
  sf project deploy start -d $package_name
  
  if [ $? -eq 0 ]; then
    echo "✅ $package_name deployed successfully"
  else
    echo "❌ Error deploying $package_name"
    exit 1
  fi
}

# Deploy dependencies for a package
function deploy_dependencies {
  local package_name=$1
  
  case $package_name in
    marketing)
      deploy_package "shared-services"
      deploy_package "account-management"
      ;;
    sales)
      deploy_package "shared-services"
      deploy_package "account-management"
      deploy_package "product-management"
      ;;
    service)
      deploy_package "shared-services"
      deploy_package "account-management"
      deploy_package "product-management"
      ;;
    operations)
      deploy_package "shared-services"
      deploy_package "account-management"
      deploy_package "product-management"
      deploy_package "sales"
      ;;
    finance)
      deploy_package "shared-services"
      deploy_package "account-management"
      deploy_package "sales"
      ;;
    legal)
      deploy_package "shared-services"
      deploy_package "account-management"
      ;;
    account-management)
      deploy_package "shared-services"
      ;;
    product-management)
      deploy_package "shared-services"
      ;;
    happysoup)
      # Deploy all packages before deploying happysoup
      deploy_package "shared-services"
      deploy_package "account-management"
      deploy_package "product-management"
      deploy_package "marketing"
      deploy_package "sales"
      deploy_package "service"
      deploy_package "operations"
      deploy_package "finance"
      deploy_package "legal"
      ;;
  esac
}

# Deploy all packages in the correct order
function deploy_all_packages {
  echo "Deploying all packages in dependency order..."
  
  # Foundation packages
  deploy_package "shared-services"
  deploy_package "account-management"
  deploy_package "product-management"
  
  # Domain packages
  deploy_package "marketing"
  deploy_package "sales"
  deploy_package "service"
  deploy_package "operations"
  deploy_package "finance"
  deploy_package "legal"
  
  # Non-packageable components
  deploy_package "happysoup"
  
  echo "✅ All packages deployed successfully!"
}

# Check org
function check_org {
  echo "Checking connection to Salesforce org..."
  sf org display user
  
  if [ $? -ne 0 ]; then
    echo "❌ Not authenticated to a Salesforce org."
    echo "Please run: sf org login web -a $SCRATCH_ORG_ALIAS"
    exit 1
  fi
}

# Parse command line arguments
# ----------------------------------------------------------------------------
if [ $# -eq 0 ]; then
  print_usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -a|--all)
      DEPLOY_ALL=true
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      if [ -z "$TARGET_PACKAGE" ]; then
        TARGET_PACKAGE="$1"
      else
        echo "Unknown argument: $1"
        print_usage
        exit 1
      fi
      shift
      ;;
  esac
done

# Main Execution
# ----------------------------------------------------------------------------
check_org

if [ "$DEPLOY_ALL" = true ]; then
  deploy_all_packages
else
  if [ -z "$TARGET_PACKAGE" ]; then
    echo "❌ No package specified."
    print_usage
    exit 1
  fi
  
  if [ ! -d "$TARGET_PACKAGE" ]; then
    echo "❌ Package directory not found: $TARGET_PACKAGE"
    print_usage
    exit 1
  fi
  
  echo "Deploying $TARGET_PACKAGE package and its dependencies..."
  deploy_dependencies "$TARGET_PACKAGE"
  deploy_package "$TARGET_PACKAGE"
  echo "✅ Deployment completed successfully!"
fi
