# Debugging Investigation Agent Context

## Issue Overview
- **Problem Description**: [Brief description]
- **Severity**: [Critical/High/Medium/Low]
- **Affected Users**: [Who is impacted]
- **First Reported**: [Date]
- **Frequency**: [Always/Sometimes/Rarely]

## Symptoms
- [ ] [Symptom 1]
- [ ] [Symptom 2]
- [ ] [Symptom 3]

## Investigation Goals
1. Identify root cause
2. Document reproduction steps
3. Assess impact scope
4. Propose solutions
5. Estimate fix complexity

## Initial Information

### Error Messages
```
[Paste any error messages, stack traces, or logs here]
```

### Environment Details
- **Environment**: [Development/Staging/Production]
- **Browser**: [If applicable]
- **User Role**: [If applicable]
- **Data Context**: [Specific project/data that triggers issue]

### Timeline
- When did this start happening?
- Any recent deployments?
- Any configuration changes?

## Investigation Checklist

### 1. Reproduction
- [ ] Can reproduce locally
- [ ] Can reproduce in staging
- [ ] Happens consistently
- [ ] Specific steps documented

### 2. Code Analysis
- [ ] Check recent commits
- [ ] Review error handling
- [ ] Inspect related modules
- [ ] Check for race conditions

### 3. Data Analysis
- [ ] Examine problematic data
- [ ] Check data integrity
- [ ] Look for edge cases
- [ ] Verify data migrations

### 4. System Analysis
- [ ] Check system resources
- [ ] Review performance metrics
- [ ] Examine external dependencies
- [ ] Check configuration

## Debugging Tools and Commands

### Log Analysis
```bash
# Check application logs
tail -f logs/app.log | grep ERROR

# Check specific timeframe
grep "2024-01-15" logs/app.log | grep -C 5 "error"

# Database queries
python manage.py dbshell
```

### Performance Profiling
```bash
# Django debug toolbar
# Python profiling
python -m cProfile manage.py runserver

# Memory profiling
python -m memory_profiler script.py
```

### Database Investigation
```sql
-- Check for locks
SELECT * FROM pg_locks WHERE NOT granted;

-- Slow queries
SELECT * FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;

-- Table sizes
SELECT relname, n_live_tup, n_dead_tup FROM pg_stat_user_tables;
```

## Areas to Investigate

### Frontend
- [ ] JavaScript console errors
- [ ] Network requests failing
- [ ] UI state issues
- [ ] Browser compatibility

### Backend
- [ ] View logic errors
- [ ] Model validation
- [ ] Middleware issues
- [ ] Cache problems

### Database
- [ ] Query performance
- [ ] Deadlocks
- [ ] Migration issues
- [ ] Connection pool

### Infrastructure
- [ ] Memory usage
- [ ] CPU usage
- [ ] Disk space
- [ ] Network issues

## Hypotheses
1. **Hypothesis 1**: [Description]
   - Evidence for:
   - Evidence against:
   - How to test:

2. **Hypothesis 2**: [Description]
   - Evidence for:
   - Evidence against:
   - How to test:

## Findings Log
```
[Date/Time] - [What was investigated]
- Finding: [What was discovered]
- Conclusion: [What this means]

[Date/Time] - [Next investigation]
- Finding: [What was discovered]
- Conclusion: [What this means]
```

## Root Cause Analysis

### Confirmed Root Cause
[Once identified, document the actual cause]

### Contributing Factors
- [Factor 1]
- [Factor 2]

### Why It Happened
[5 Whys analysis or similar]

## Proposed Solutions

### Option 1: [Quick Fix]
- **Pros**: Fast to implement
- **Cons**: May not address all cases
- **Effort**: [Hours/Days]

### Option 2: [Proper Fix]
- **Pros**: Addresses root cause
- **Cons**: More complex
- **Effort**: [Hours/Days]

### Option 3: [Refactor]
- **Pros**: Prevents future issues
- **Cons**: Larger scope
- **Effort**: [Days/Weeks]

## Impact Analysis
- **Users Affected**: [Number/Percentage]
- **Features Affected**: [List features]
- **Data Impact**: [Any data issues]
- **Business Impact**: [Revenue/Operations]

## Prevention Measures
- [ ] Add monitoring/alerts
- [ ] Improve error handling
- [ ] Add validation
- [ ] Write tests
- [ ] Update documentation

## Lessons Learned
[Document what can be learned from this issue]

## Next Steps
1. [Immediate action]
2. [Short-term fix]
3. [Long-term improvement]