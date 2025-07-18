# Bug Fix Agent Context

## Issue Information
- **Issue Number**: #[ISSUE_NUMBER]
- **Issue Title**: [ISSUE_TITLE]
- **Issue URL**: https://github.com/[ORG]/globalviz/issues/[ISSUE_NUMBER]
- **Priority**: [HIGH/MEDIUM/LOW]

## Bug Description
[Paste the full issue description here]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Affected Components
- [ ] Frontend (JavaScript/Templates)
- [ ] Backend (Django Views)
- [ ] Database/Models
- [ ] API
- [ ] Tests
- [ ] Other: [Specify]

## Investigation Checklist
- [ ] Reproduce the bug locally
- [ ] Identify the root cause
- [ ] Check for similar issues in codebase
- [ ] Review recent changes to affected files

## Implementation Requirements
- [ ] Create failing test that demonstrates the bug
- [ ] Implement the fix
- [ ] Ensure test now passes
- [ ] Run full test suite for regressions
- [ ] Update documentation if needed

## Files Likely Involved
```
# Add suspected files here
- stats/views/
- templates/
- tests/
```

## Testing Commands
```bash
# Specific test for this issue
pytest tests/test_[relevant].py::test_[specific] -xvs

# Run related test suite
pytest stats/tests/ -x

# Full regression test
pytest
```

## Validation Criteria
1. Bug no longer reproduces with original steps
2. New test case prevents regression
3. All existing tests still pass
4. No performance degradation
5. Code follows project conventions

## Notes
[Any additional context, related issues, or considerations]

## Don't Forget
- [ ] Add test for the bug before fixing
- [ ] Check if bug exists in other similar code
- [ ] Update any affected documentation
- [ ] Add inline comments explaining the fix