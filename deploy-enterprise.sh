#!/bin/bash
# Azure Enterprise Landing Zone Deployment Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Azure CLI is installed and logged in
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Initialize Terraform
init_terraform() {
    log_info "Initializing Terraform..."
    terraform init
    log_success "Terraform initialized"
}

# Validate configuration
validate_config() {
    log_info "Validating Terraform configuration..."
    
    # Check if tfvars file exists
    if [[ ! -f "terraform-enterprise.tfvars" ]]; then
        log_warning "terraform-enterprise.tfvars not found. Creating from example..."
        cp terraform-enterprise.tfvars.example terraform-enterprise.tfvars
        log_warning "Please edit terraform-enterprise.tfvars with your values before continuing."
        exit 1
    fi
    
    # Check if VPN shared key is set
    if [[ -z "${TF_VAR_vpn_shared_key}" ]]; then
        log_warning "VPN shared key not set. Please set TF_VAR_vpn_shared_key environment variable."
        read -s -p "Enter VPN shared key: " vpn_key
        export TF_VAR_vpn_shared_key="$vpn_key"
        echo
    fi
    
    terraform validate
    log_success "Configuration validated"
}

# Plan deployment
plan_deployment() {
    log_info "Creating deployment plan..."
    terraform plan -var-file="terraform-enterprise.tfvars" -out=tfplan
    log_success "Deployment plan created"
}

# Apply deployment
apply_deployment() {
    log_info "Applying deployment..."
    log_warning "This will create Azure resources and may incur costs."
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deployment cancelled"
        exit 0
    fi
    
    terraform apply tfplan
    log_success "Deployment completed successfully"
}

# Show outputs
show_outputs() {
    log_info "Deployment outputs:"
    terraform output
}

# Main deployment function
deploy() {
    log_info "Starting Azure Enterprise Landing Zone deployment..."
    
    check_prerequisites
    init_terraform
    validate_config
    plan_deployment
    apply_deployment
    show_outputs
    
    log_success "Azure Enterprise Landing Zone deployed successfully!"
    log_info "Next steps:"
    echo "1. Configure Azure Bastion for secure VM access"
    echo "2. Set up monitoring and alerting"
    echo "3. Configure backup policies"
    echo "4. Review and adjust firewall rules as needed"
}

# Destroy function
destroy() {
    log_warning "This will destroy all Azure resources created by this deployment."
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Destroy cancelled"
        exit 0
    fi
    
    log_info "Destroying resources..."
    terraform destroy -var-file="terraform-enterprise.tfvars"
    log_success "Resources destroyed"
}

# Help function
show_help() {
    echo "Azure Enterprise Landing Zone Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy    Deploy the enterprise landing zone (default)"
    echo "  destroy   Destroy all resources"
    echo "  plan      Show deployment plan only"
    echo "  help      Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  TF_VAR_vpn_shared_key    VPN shared key (required)"
    echo ""
    echo "Examples:"
    echo "  $0 deploy"
    echo "  TF_VAR_vpn_shared_key='your-key' $0 deploy"
    echo "  $0 destroy"
}

# Main script logic
case "${1:-deploy}" in
    deploy)
        deploy
        ;;
    destroy)
        destroy
        ;;
    plan)
        check_prerequisites
        init_terraform
        validate_config
        plan_deployment
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac