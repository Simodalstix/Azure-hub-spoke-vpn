#!/bin/bash
set -e

echo "🔍 Validating Terraform configuration..."

# Format check
echo "📝 Checking Terraform formatting..."
terraform fmt -check -recursive

# Initialize without backend
echo "🚀 Initializing Terraform..."
terraform init -backend=false

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan with example variables
echo "📋 Creating Terraform plan..."
terraform plan -var-file="terraform-enterprise.tfvars.example" -var="vpn_shared_key=dummy-key-for-validation" -out=plan.out

echo "✅ All validations passed!"