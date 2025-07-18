# Testing Improvement Agent Context

## Testing Focus
- **Test Type**: [Unit/Integration/E2E/Performance]
- **Target Module**: [Module/Component name]
- **Current Coverage**: [XX%]
- **Target Coverage**: [XX%]

## Objectives
- [ ] Increase test coverage
- [ ] Fix failing tests
- [ ] Add missing test cases
- [ ] Improve test performance
- [ ] Add integration tests
- [ ] Add E2E Playwright tests

## Current Testing Gaps

### Missing Test Coverage
```
# Files with low/no coverage
- module/file1.py (20% coverage)
- module/file2.py (0% coverage)
- module/views.py (missing integration tests)
```

### Failing Tests
```
# Currently failing tests to fix
- test_module.py::test_specific_case
- test_integration.py::test_workflow
```

### Critical Paths Without Tests
1. [User workflow 1]
2. [User workflow 2]
3. [API endpoint X]

## Test Implementation Plan

### 1. Unit Tests
```python
# New test files to create
tests/test_[module]_models.py
tests/test_[module]_services.py
tests/test_[module]_utils.py

# Test categories to add:
- Happy path tests
- Edge case tests
- Error handling tests
- Boundary condition tests
```

### 2. Integration Tests
```python
# Playwright tests to add
tests/playwright/test_[feature]_flow.py
tests/playwright/test_[feature]_errors.py
```

### 3. Performance Tests
```python
# Performance benchmarks
tests/performance/test_[module]_performance.py
```

## Testing Best Practices to Follow

### Test Structure
```python
def test_descriptive_name_explains_what_is_tested():
    # Arrange
    # Set up test data and conditions
    
    # Act
    # Perform the action being tested
    
    # Assert
    # Verify the expected outcome
```

### Fixtures and Factories
- Use existing factories in `tests/factories.py`
- Create reusable fixtures in `conftest.py`
- Avoid test interdependencies

### Mocking Strategy
- Mock external services
- Use real database for integration tests
- Mock time-dependent functions

## Specific Areas to Test

### Models
- [ ] Field validation
- [ ] Model methods
- [ ] Model relationships
- [ ] Signal handlers

### Views
- [ ] GET requests
- [ ] POST requests
- [ ] Permission checks
- [ ] Error handling

### API Endpoints
- [ ] Authentication
- [ ] Request validation
- [ ] Response format
- [ ] Error responses

### Frontend Integration
- [ ] User interactions
- [ ] Form submissions
- [ ] AJAX requests
- [ ] Error displays

## Test Data Requirements
```python
# Sample test data needed
- Valid user accounts
- Sample projects
- Test datasets
- Edge case inputs
```

## Commands and Scripts

### Running Tests
```bash
# Run specific test file
pytest tests/test_specific.py -xvs

# Run with coverage
pytest --cov=module --cov-report=html

# Run Playwright tests
pytest tests/playwright/ --headed

# Run only failing tests
pytest --lf
```

### Coverage Reports
```bash
# Generate coverage report
coverage run -m pytest
coverage report
coverage html

# Check specific module coverage
coverage report --include="module/*"
```

## Success Criteria
- [ ] All new tests pass
- [ ] No regressions in existing tests
- [ ] Coverage increased to target
- [ ] Tests run in < [X] seconds
- [ ] Tests are maintainable and clear

## Common Patterns in This Codebase

### Factory Pattern
```python
# Use existing factories
from tests.factories import UserFactory, ProjectFactory

user = UserFactory()
project = ProjectFactory(user=user)
```

### Client Testing
```python
# Django test client
response = client.get('/url/')
assert response.status_code == 200
```

### Playwright Pattern
```python
# E2E test pattern
page.goto('/feature/')
page.click('button[type="submit"]')
expect(page.locator('.success')).to_be_visible()
```

## Anti-patterns to Avoid
- Don't test implementation details
- Don't use production data
- Don't make tests dependent on order
- Don't skip error case testing
- Don't use hardcoded wait times

## Documentation
- [ ] Update test README
- [ ] Document test helpers
- [ ] Add testing guide
- [ ] Document CI changes