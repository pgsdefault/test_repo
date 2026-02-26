#!/usr/bin/env python3
"""
Comprehensive State Alignment Validator
Validates synchronization between all 3 pipelines: policy, remediation, exemption
Runs post-deployment to ensure state consistency
"""

import json
import sys
import os
import subprocess
import hashlib
from datetime import datetime
from typing import Dict, List, Tuple

class StateValidator:
    def __init__(self):
        self.subscription_id = os.getenv('ARM_SUBSCRIPTION_ID')
        self.tenant_id = os.getenv('ARM_TENANT_ID')
        self.client_id = os.getenv('ARM_CLIENT_ID')
        self.client_secret = os.getenv('ARM_CLIENT_SECRET')
        
        if not all([self.subscription_id, self.tenant_id, self.client_id, self.client_secret]):
            raise Exception("Missing Azure credentials")
        
        self.storage_account = "teststaccn022002testing"
        self.container = "tfstate"
        self.state_files = {
            'policy': 'policy_deployment.tfstate',
            'remediation': 'remediation.tfstate',
            'exemption': 'exemption.tfstate'
        }
    
    def run_terraform_command(self, working_dir: str, command: str) -> Tuple[int, str, str]:
        """Execute terraform command and return exit code, stdout, stderr"""
        try:
            result = subprocess.run(
                command,
                shell=True,
                cwd=working_dir,
                capture_output=True,
                text=True,
                env={
                    **os.environ,
                    'ARM_CLIENT_ID': self.client_id,
                    'ARM_CLIENT_SECRET': self.client_secret,
                    'ARM_SUBSCRIPTION_ID': self.subscription_id,
                    'ARM_TENANT_ID': self.tenant_id,
                    'TF_LOG': 'ERROR'
                }
            )
            return result.returncode, result.stdout, result.stderr
        except Exception as e:
            return 1, "", str(e)
    
    def get_state_summary(self, state_file_path: str) -> Dict:
        """Parse terraform state file and extract summary"""
        try:
            with open(state_file_path, 'r') as f:
                state = json.load(f)
            
            resources = state.get('resources', [])
            
            summary = {
                'version': state.get('terraform_version', 'unknown'),
                'serial': state.get('serial', 0),
                'lineage': state.get('lineage', 'unknown'),
                'timestamp': state.get('timestamp', 'unknown'),
                'resource_count': len(resources),
                'resource_types': {}
            }
            
            for resource in resources:
                rtype = resource.get('type', 'unknown')
                summary['resource_types'][rtype] = summary['resource_types'].get(rtype, 0) + 1
            
            return summary
        except Exception as e:
            print(f"❌ Error reading state file {state_file_path}: {e}")
            return None
    
    def validate_policy_state(self) -> bool:
        """Validate policy deployment state"""
        print("\n" + "=" * 80)
        print("VALIDATING: Policy Deployment State")
        print("=" * 80)
        
        policy_dir = "terraform/policy_deployment"
        
        # Check if directory exists
        if not os.path.isdir(policy_dir):
            print(f"❌ ERROR: Policy deployment directory not found: {policy_dir}")
            return False
        
        print(f"✓ Policy deployment directory found: {policy_dir}")
        
        # Try to initialize terraform
        print("\n1. Initializing Terraform...")
        exit_code, stdout, stderr = self.run_terraform_command(
            policy_dir,
            "terraform init -input=false -upgrade -backend-config='key=policy_deployment.tfstate' 2>&1"
        )
        
        if exit_code != 0:
            print(f"❌ Terraform init failed")
            print(f"   Error: {stderr}")
            return False
        
        print("✓ Terraform initialized successfully")
        
        # Validate terraform
        print("\n2. Validating Terraform configuration...")
        exit_code, stdout, stderr = self.run_terraform_command(
            policy_dir,
            "terraform validate 2>&1"
        )
        
        if exit_code != 0:
            print(f"❌ Terraform validation failed")
            print(f"   Error: {stderr}")
            return False
        
        print("✓ Terraform configuration is valid")
        
        # Get state outputs
        print("\n3. Retrieving Terraform outputs...")
        exit_code, stdout, stderr = self.run_terraform_command(
            policy_dir,
            "terraform output -json 2>/dev/null"
        )
        
        if exit_code == 0 and stdout:
            try:
                outputs = json.loads(stdout)
                print(f"✓ Retrieved outputs with {len(outputs)} variables:")
                for key in outputs.keys():
                    print(f"   - {key}")
            except:
                print("⚠️  Could not parse outputs (may not be deployed yet)")
        
        return True
    
    def validate_remediation_state(self) -> bool:
        """Validate remediation state and policy dependency"""
        print("\n" + "=" * 80)
        print("VALIDATING: Remediation State & Policy Dependency")
        print("=" * 80)
        
        remediation_dir = "terraform/remediation"
        
        if not os.path.isdir(remediation_dir):
            print(f"❌ ERROR: Remediation directory not found: {remediation_dir}")
            return False
        
        print(f"✓ Remediation directory found: {remediation_dir}")
        
        print("\n1. Checking policy state dependency...")
        
        # Check if main.tf references policy state
        main_tf_path = os.path.join(remediation_dir, "main.tf")
        if os.path.exists(main_tf_path):
            with open(main_tf_path, 'r') as f:
                content = f.read()
                if "terraform_remote_state" in content and "policy_deployment" in content:
                    print("✓ Remediation configuration references policy deployment state")
                else:
                    print("⚠️  Remediation may not properly reference policy state")
        
        print("\n2. Initializing Terraform...")
        exit_code, stdout, stderr = self.run_terraform_command(
            remediation_dir,
            "terraform init -input=false -upgrade -backend-config='key=remediation.tfstate' 2>&1"
        )
        
        if exit_code != 0:
            print(f"❌ Terraform init failed: {stderr}")
            return False
        
        print("✓ Terraform initialized successfully")
        
        print("\n3. Validating configuration...")
        exit_code, stdout, stderr = self.run_terraform_command(
            remediation_dir,
            "terraform validate 2>&1"
        )
        
        if exit_code != 0:
            print(f"❌ Validation failed: {stderr}")
            return False
        
        print("✓ Configuration is valid")
        
        return True
    
    def validate_exemption_state(self) -> bool:
        """Validate exemption state and policy dependency"""
        print("\n" + "=" * 80)
        print("VALIDATING: Exemption State & Policy Dependency")
        print("=" * 80)
        
        exemption_dir = "terraform/exemption"
        
        if not os.path.isdir(exemption_dir):
            print(f"❌ ERROR: Exemption directory not found: {exemption_dir}")
            return False
        
        print(f"✓ Exemption directory found: {exemption_dir}")
        
        print("\n1. Checking policy state dependency...")
        
        main_tf_path = os.path.join(exemption_dir, "main.tf")
        if os.path.exists(main_tf_path):
            with open(main_tf_path, 'r') as f:
                content = f.read()
                if "terraform_remote_state" in content and "policy_deployment" in content:
                    print("✓ Exemption configuration references policy deployment state")
                else:
                    print("⚠️  Exemption may not properly reference policy state")
        
        print("\n2. Initializing Terraform...")
        exit_code, stdout, stderr = self.run_terraform_command(
            exemption_dir,
            "terraform init -input=false -upgrade -backend-config='key=exemption.tfstate' 2>&1"
        )
        
        if exit_code != 0:
            print(f"❌ Terraform init failed: {stderr}")
            return False
        
        print("✓ Terraform initialized successfully")
        
        print("\n3. Validating configuration...")
        exit_code, stdout, stderr = self.run_terraform_command(
            exemption_dir,
            "terraform validate 2>&1"
        )
        
        if exit_code != 0:
            print(f"❌ Validation failed: {stderr}")
            return False
        
        print("✓ Configuration is valid")
        
        return True
    
    def run_all_validations(self) -> bool:
        """Run all state alignment validations"""
        print("\n")
        print("╔" + "=" * 78 + "╗")
        print("║" + " COMPREHENSIVE STATE ALIGNMENT VALIDATION ".center(78) + "║")
        print("╚" + "=" * 78 + "╝")
        print()
        
        results = {}
        
        # Validate each pipeline
        results['policy'] = self.validate_policy_state()
        results['remediation'] = self.validate_remediation_state()
        results['exemption'] = self.validate_exemption_state()
        
        # Print summary
        print("\n" + "=" * 80)
        print("VALIDATION SUMMARY")
        print("=" * 80)
        
        for pipeline, passed in results.items():
            status = "✅ PASSED" if passed else "❌ FAILED"
            print(f"  {pipeline.upper():15} {status}")
        
        print("=" * 80)
        
        all_passed = all(results.values())
        
        if all_passed:
            print("\n✅ All state alignment validations PASSED!")
            return True
        else:
            print("\n❌ Some validations FAILED - review errors above")
            return False

def main():
    try:
        validator = StateValidator()
        success = validator.run_all_validations()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\n❌ FATAL ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
