# Coordination Templates Guide

This guide explains how to use coordination templates for managing parallel sub-agent execution in Claude Code workflows.

## Overview

Coordination files are JSON files that track the progress of multiple sub-agents working in parallel. They enable:
- Task assignment to specific agents
- Progress monitoring in real-time
- Error tracking and recovery
- Result consolidation
- Performance metrics

## Available Templates

### 1. Issue Coordination (`issue-coordination`)

Used by: `issues-from-mvp` command

**Purpose**: Tracks parallel creation of GitHub issues by multiple issue-creator agents.

**Key Features**:
- Assigns batches of 3-5 issues to each agent
- Tracks issue numbers for dependency linking
- Records creation errors for retry

**Example Usage**:
```bash
# Initialize coordination file
jq '.assignments = {
  "creator-1": ["docker-setup", "env-config", "health-checks"],
  "creator-2": ["db-setup", "first-api", "first-ui"]
}' coordination-templates.json > .issue-coordination.json

# Update progress (done by sub-agents)
jq '.progress."creator-1".completed += 1' .issue-coordination.json > tmp.json && mv tmp.json .issue-coordination.json
```

### 2. Review Coordination (`review-coordination`)

Used by: `review-pr` command

**Purpose**: Manages parallel PR review checks by review-checker agents.

**Key Features**:
- Six parallel check types (architecture, security, testing, etc.)
- Aggregates critical issues vs warnings
- Calculates overall review decision

**Monitoring**:
```bash
# Check review progress
jq '.checks | to_entries | map({check: .key, status: .value.status, critical: .value.critical})' .review-coordination.json

# Get overall status
jq '.overall_status' .review-coordination.json
```

### 3. Architecture Coordination (`arch-coordination`)

Used by: `arch-from-code` command

**Purpose**: Coordinates parallel analysis of different architectural domains.

**Key Features**:
- Six domain analyzers (backend, frontend, data, etc.)
- Quality metrics calculation
- Git history insights
- Clarification tracking

**Progress Tracking**:
```bash
# Monitor domain analysis
watch -n 15 'jq ".domains | to_entries | map({domain: .key, status: .value.status, patterns: .value.patterns_found})" .arch-coordination.json'
```

### 4. Tech Guide Coordination (`tech-guide-coordination`)

Used by: `create-tech-guides` command

**Purpose**: Manages parallel creation of technology guides.

**Key Features**:
- Distributes 2-3 technologies per agent
- Tracks guide completion
- Monitors which technology each agent is working on

### 5. Test Coordination (`test-coordination`)

Used by: Parallel test writing workflows

**Purpose**: Coordinates test creation across multiple components.

**Key Features**:
- Component-to-agent mapping
- Coverage tracking per component
- Test file location recording

## Coordination File Lifecycle

### 1. Initialization
```bash
# Copy template and customize
jq '.["issue-coordination"].template' coordination-templates.json > .issue-coordination.json

# Set start time
jq '.start_time = now | todate' .issue-coordination.json > tmp.json && mv tmp.json .issue-coordination.json
```

### 2. Assignment Phase
```bash
# Assign tasks to agents
jq '.assignments = {
  "agent-1": ["task-1", "task-2"],
  "agent-2": ["task-3", "task-4"]
}' .issue-coordination.json > tmp.json && mv tmp.json .issue-coordination.json
```

### 3. Progress Updates (by sub-agents)
```bash
# Mark task complete
jq '.progress."agent-1".completed += 1 | .progress."agent-1".status = "working"' coord.json > tmp.json && mv tmp.json coord.json

# Record results
jq '.created_issues."task-1" = {"number": 42, "title": "Task Title"}' coord.json > tmp.json && mv tmp.json coord.json
```

### 4. Error Handling
```bash
# Record error
jq '.errors += [{
  "agent": "creator-2",
  "task": "task-3",
  "error": "API rate limit",
  "timestamp": now | todate
}]' coord.json > tmp.json && mv tmp.json coord.json
```

### 5. Completion
```bash
# Calculate metrics
TOTAL=$(jq '.total_tasks' coord.json)
COMPLETED=$(jq '[.progress[].completed] | add' coord.json)
TIME_SAVED=$(jq '.time_saved_percentage = 70' coord.json)
```

## Best Practices

### 1. Atomic Updates
Always use temporary files for updates to prevent corruption:
```bash
jq '.update = "value"' coord.json > tmp.json && mv tmp.json coord.json
```

### 2. Progress Monitoring
Create monitoring scripts:
```bash
#!/bin/bash
while true; do
  clear
  echo "=== Parallel Execution Progress ==="
  jq '.progress | to_entries | map({
    agent: .key,
    completed: .value.completed,
    status: .value.status
  })' .coordination.json
  sleep 5
done
```

### 3. Error Recovery
Check for errors before final processing:
```bash
ERROR_COUNT=$(jq '.errors | length' coord.json)
if [ $ERROR_COUNT -gt 0 ]; then
  echo "Found $ERROR_COUNT errors, handling..."
  jq '.errors[]' coord.json
fi
```

### 4. Clean Shutdown
Always clean up coordination files:
```bash
# Archive for debugging if needed
mv .coordination.json ".coordination-$(date +%Y%m%d-%H%M%S).json"

# Or simply remove
rm -f .coordination.json
```

## Creating Custom Coordination Templates

For new parallel workflows:

1. **Define Structure**:
```json
{
  "my-coordination": {
    "command": "my-command",
    "tasks": [],
    "agents": {},
    "progress": {},
    "results": {}
  }
}
```

2. **Add Progress Tracking**:
```json
{
  "progress": {
    "agent-id": {
      "assigned": 5,
      "completed": 0,
      "current": "task-name",
      "status": "pending|working|complete|error"
    }
  }
}
```

3. **Include Timestamps**:
```json
{
  "start_time": "2024-01-10T10:00:00Z",
  "end_time": null,
  "duration_seconds": null
}
```

## Integration with Commands

Commands should:
1. Initialize coordination file from template
2. Spawn agents with coordination file path
3. Monitor progress during execution
4. Handle errors gracefully
5. Clean up after completion

Example command integration:
```bash
# In command file
COORD_FILE=".my-coordination.json"

# Initialize
jq '.["my-coordination"].template' /docs/templates/coordination-templates.json > "$COORD_FILE"

# Spawn agents
for i in {1..4}; do
  Task: Use my-agent to process batch $i with coordination file $COORD_FILE
done

# Monitor
watch -n 5 "jq '.progress' $COORD_FILE"

# Cleanup
rm -f "$COORD_FILE"
```

This coordination system enables efficient parallel execution while maintaining visibility and control over the distributed work.