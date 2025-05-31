#!/usr/bin/env python3
"""
So sánh thực tế giữa Pydantic và Dataclass approaches.
"""

import time
from typing import Dict, Any


def test_dataclass_approach():
    """Test dataclass approach (hiện tại)."""
    print("🧪 Testing Dataclass Approach")
    print("=" * 40)
    
    start_time = time.time()
    
    try:
        from powerapp_yaml import AdvancedYAMLHandler
        
        # Create handler
        handler = AdvancedYAMLHandler()
        handler.create_sample_button_component()
        
        # Get info
        info = handler.get_component_info()
        validation = handler.validate_component_structure()
        
        # Performance
        yaml_output = handler.to_yaml_string()
        json_output = handler.to_json_string()
        
        end_time = time.time()
        
        print(f"✅ Components created: {info['total_components']}")
        print(f"✅ Validation passed: {validation['valid']}")
        print(f"✅ YAML output: {len(yaml_output)} chars")
        print(f"✅ JSON output: {len(json_output)} chars")
        print(f"⏱️ Time taken: {end_time - start_time:.4f}s")
        
        return {
            'success': True,
            'time': end_time - start_time,
            'yaml_size': len(yaml_output),
            'json_size': len(json_output),
            'validation': validation['valid']
        }
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return {'success': False, 'error': str(e)}


def test_pydantic_approach():
    """Test Pydantic approach."""
    print("\n🧪 Testing Pydantic Approach")
    print("=" * 40)
    
    start_time = time.time()
    
    try:
        from powerapp_yaml.core.pydantic_handler import PydanticYAMLHandler
        
        # Create handler
        handler = PydanticYAMLHandler()
        handler.create_sample_button_component()
        
        # Get info
        info = handler.get_component_info()
        validation = handler.validate_component_structure()
        
        # Performance
        yaml_output = handler.to_yaml_string()
        json_output = handler.to_json_string()
        
        end_time = time.time()
        
        print(f"✅ Components created: {info['total_components']}")
        print(f"✅ Validation passed: {validation.is_valid}")
        print(f"✅ YAML output: {len(yaml_output)} chars")
        print(f"✅ JSON output: {len(json_output)} chars")
        print(f"⏱️ Time taken: {end_time - start_time:.4f}s")
        
        return {
            'success': True,
            'time': end_time - start_time,
            'yaml_size': len(yaml_output),
            'json_size': len(json_output),
            'validation': validation.is_valid
        }
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return {'success': False, 'error': str(e)}


def test_type_safety():
    """Test type safety của cả hai approaches."""
    print("\n🔍 Type Safety Comparison")
    print("=" * 40)
    
    print("📋 Dataclass Type Safety:")
    try:
        from powerapp_yaml.models.enums import PropertyKind, DataType
        print(f"   ✅ Enums: {PropertyKind.INPUT}, {DataType.TEXT}")
        
        from powerapp_yaml.validation.validators import ValidationResult
        result = ValidationResult(True, [], [])
        print(f"   ✅ ValidationResult: errors={result.total_errors}")
        
        print("   ✅ Basic type safety working")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    print("\n📋 Pydantic Type Safety:")
    try:
        from powerapp_yaml.models.pydantic_models import PropertyKind as PydPropertyKind
        from powerapp_yaml.models.pydantic_models import ValidationResult as PydValidationResult
        
        # Test enum
        print(f"   ✅ Enums: {PydPropertyKind.INPUT}")
        
        # Test ValidationResult
        result = PydValidationResult(is_valid=True, errors=[], warnings=[])
        print(f"   ✅ ValidationResult: errors={result.total_errors}")
        
        # Test validation
        from powerapp_yaml.models.pydantic_models import CustomProperty
        try:
            # This should fail type checking
            prop = CustomProperty(
                PropertyKind="Invalid",  # Wrong type
                DisplayName="Test", 
                Description="Test",
                Default="=test"
            )
            print("   ⚠️ Type validation not catching errors")
        except Exception as validation_error:
            print(f"   ✅ Pydantic validation working: {str(validation_error)[:50]}...")
            
    except Exception as e:
        print(f"   ❌ Error: {e}")


def run_mypy_comparison():
    """So sánh MyPy results."""
    print("\n🔬 MyPy Comparison")
    print("=" * 40)
    
    import subprocess
    
    print("📋 Dataclass MyPy Results:")
    try:
        result = subprocess.run([
            "mypy", 
            "powerapp_yaml/validation/validators.py",
            "powerapp_yaml/models/enums.py",
            "--ignore-missing-imports"
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("   ✅ MyPy passed - No errors")
        else:
            errors = result.stdout.count("error:")
            print(f"   ⚠️ MyPy found {errors} errors")
            
    except Exception as e:
        print(f"   ❌ Could not run MyPy: {e}")
    
    print("\n📋 Pydantic MyPy Results:")
    try:
        result = subprocess.run([
            "mypy", 
            "powerapp_yaml/models/pydantic_models.py",
            "powerapp_yaml/core/pydantic_handler.py",
            "--ignore-missing-imports"
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("   ✅ MyPy passed - No errors")
        else:
            errors = result.stdout.count("error:")
            print(f"   ⚠️ MyPy found {errors} errors")
            
    except Exception as e:
        print(f"   ❌ Could not run MyPy: {e}")


def comparison_analysis(dataclass_result: Dict[str, Any], pydantic_result: Dict[str, Any]):
    """Phân tích so sánh."""
    print("\n📊 Detailed Comparison Analysis")
    print("=" * 50)
    
    if not dataclass_result['success'] or not pydantic_result['success']:
        print("❌ Không thể so sánh do lỗi trong một trong hai approaches")
        return
    
    print("| Metric | Dataclass | Pydantic | Winner |")
    print("|--------|-----------|----------|---------|")
    
    # Performance
    dc_time = dataclass_result['time']
    pyd_time = pydantic_result['time']
    perf_winner = "Dataclass" if dc_time < pyd_time else "Pydantic"
    print(f"| Performance | {dc_time:.4f}s | {pyd_time:.4f}s | {perf_winner} |")
    
    # Output size
    dc_yaml = dataclass_result['yaml_size']
    pyd_yaml = pydantic_result['yaml_size']
    size_winner = "Equal" if dc_yaml == pyd_yaml else ("Dataclass" if dc_yaml < pyd_yaml else "Pydantic")
    print(f"| YAML Size | {dc_yaml} | {pyd_yaml} | {size_winner} |")
    
    # Validation
    dc_valid = dataclass_result['validation']
    pyd_valid = pydantic_result['validation']
    valid_winner = "Equal" if dc_valid == pyd_valid else ("Dataclass" if dc_valid else "Pydantic")
    print(f"| Validation | {dc_valid} | {pyd_valid} | {valid_winner} |")
    
    print(f"\n🏆 Performance winner: {perf_winner}")
    print(f"⚖️ Size comparison: {size_winner}")
    

def main():
    """Main comparison function."""
    print("🎯 PYDANTIC vs DATACLASS COMPARISON")
    print("=" * 50)
    
    # Test functionality
    dataclass_result = test_dataclass_approach()
    pydantic_result = test_pydantic_approach()
    
    # Test type safety
    test_type_safety()
    
    # MyPy comparison
    run_mypy_comparison()
    
    # Analysis
    comparison_analysis(dataclass_result, pydantic_result)
    
    print("\n🎯 RECOMMENDATION")
    print("=" * 50)
    
    print("📋 Factors to Consider:")
    print("\n✅ **Pydantic Advantages:**")
    print("   - Runtime validation")
    print("   - Better JSON serialization") 
    print("   - Extensive validation features")
    print("   - Industry standard for APIs")
    print("   - Auto-documentation generation")
    
    print("\n✅ **Dataclass Advantages:**")
    print("   - Part of Python standard library")
    print("   - Lighter weight")
    print("   - Simpler for basic use cases")
    print("   - Faster performance")
    print("   - Less external dependencies")
    
    print("\n⚠️ **Current Issues:**")
    print("   - Pydantic: More MyPy errors")
    print("   - Dataclass: Less validation features")
    print("   - Both: Need type safety improvements")
    
    print("\n🏆 **Final Recommendation:**")
    if pydantic_result['success'] and dataclass_result['success']:
        print("   Choice depends on use case:")
        print("   - Simple usage: Keep Dataclass")
        print("   - Complex validation: Switch to Pydantic")
        print("   - API integration: Use Pydantic")
        print("   - Performance critical: Use Dataclass")
    else:
        print("   Stick with current working solution")


if __name__ == "__main__":
    main() 