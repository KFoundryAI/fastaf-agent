# Architecture Decision Record (ADR)

This document serves as the single source of truth for all architectural decisions in this project. 
**Every agent MUST consult this document before implementing features and update it when making architectural choices.**

Last Updated: [Auto-updated by agents]

## Table of Contents
1. [System Architecture Overview](#system-architecture-overview)
2. [Core Principles](#core-principles)
3. [Technology Stack](#technology-stack)
4. [Architecture Decisions Log](#architecture-decisions-log)
5. [API Design Conventions](#api-design-conventions)
6. [Data Model Conventions](#data-model-conventions)
7. [Frontend Patterns](#frontend-patterns)
8. [Integration Points](#integration-points)

---

## System Architecture Overview

### High-Level Architecture
```
[Frontend] <-> [API Gateway] <-> [Backend Services] <-> [Database]
                                        |
                                  [External APIs]
```

### Service Boundaries
- **Frontend**: [Framework] application handling all UI concerns
- **Backend**: [API Type] API handling business logic
- **Database**: [Database] for persistent storage
- **External Services**: [List any: OpenAI, Stripe, etc.]

---

## Core Principles

1. **API-First Design**: All features exposed through [REST/GraphQL] endpoints
2. **Separation of Concerns**: Clear boundaries between layers
3. **Fail Gracefully**: Every error must be handled with user-friendly messages
4. **Test Coverage**: No feature without tests
5. **Environment Agnostic**: All config through environment variables

---

## Technology Stack

### Backend
- **Language**: [Language + Version]
- **Framework**: [Framework]
- **ORM/ODM**: [ORM/ODM]
- **Testing**: [Test Framework]

### Frontend  
- **Language**: [Language]
- **Framework**: [Framework + Version]
- **State Management**: [Context/Redux/Zustand/Pinia]
- **Styling**: [Tailwind/CSS Modules/Styled Components]
- **Testing**: [Test Framework]

### Infrastructure
- **Containerization**: Docker + Docker Compose
- **Database**: [Database + Version]
- **Caching**: [Redis/Memcached if applicable]
- **Queue**: [RabbitMQ/Kafka/SQS if applicable]

---

## Architecture Decisions Log

<!-- Add new decisions at the top, increment ADR number -->

### ADR-001: [First Major Decision]
- **Date**: [YYYY-MM-DD]
- **Status**: [Proposed/Accepted/Deprecated/Superseded]
- **Issue**: #[N]
- **Agent**: Agent-[X]
- **Decision**: [What was decided]
- **Rationale**: [Why this approach]
- **Consequences**: [What this means for the system]
- **Compliance**: [✅ Follows arch-standards.md / ⚠️ Deviates from standards: reason]

---

## API Design Conventions

### Endpoint Structure
```
GET    /api/v1/resources          # List all
GET    /api/v1/resources/:id      # Get one
POST   /api/v1/resources          # Create
PUT    /api/v1/resources/:id      # Update (full)
PATCH  /api/v1/resources/:id      # Update (partial)
DELETE /api/v1/resources/:id      # Delete
```

### Response Format
```json
{
  "data": {},
  "meta": {
    "timestamp": "2025-01-15T10:30:00Z",
    "version": "1.0"
  },
  "errors": []
}
```

### Error Response
```json
{
  "errors": [{
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "field": "email"
  }]
}
```

### Status Codes
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 422: Validation Error
- 500: Server Error

---

## Data Model Conventions

### Naming
- Tables: plural, snake_case (e.g., `user_profiles`)
- Columns: snake_case (e.g., `created_at`)
- Foreign keys: `<table>_id` (e.g., `user_id`)

### Required Columns
Every table must have:
```sql
id: UUID PRIMARY KEY
created_at: TIMESTAMP NOT NULL DEFAULT NOW()
updated_at: TIMESTAMP NOT NULL DEFAULT NOW()
```

### Soft Deletes
Use `deleted_at` timestamp instead of hard deletes for important data

---

## Frontend Patterns

### Component Structure
```
/components
  /common        # Shared components
  /features      # Feature-specific components
  /layouts       # Page layouts
```

### State Management
- Local state for component-specific data
- Context/Global state for user auth, theme
- Server state with react-query/SWR for API data

### Error Boundaries
Every feature must have error boundary with fallback UI

---

## Integration Points

### External Services

#### [Service Name]
- **Purpose**: [What it's used for]
- **Endpoints Used**: [List specific endpoints]
- **Rate Limits**: [Document any limits]
- **Error Handling**: [How to handle failures]

---

## How to Update This Document

When making architectural decisions:

1. **Before Implementation**: Check if your approach aligns with existing decisions
2. **New Decision Required?**: 
   - Add entry to Architecture Decisions Log (at the top)
   - Update relevant sections (API conventions, etc.)
   - Include: Date, Issue #, Agent ID, Decision, Rationale, Consequences, Compliance
3. **Commit Message**: `docs: Add ADR-XXX for [decision topic]`

## When to Ask the User

**ALWAYS ask the user before proceeding if:**
- Your implementation conflicts with an existing ADR
- You need to make a new architectural decision not covered by existing ADRs
- Two or more ADRs seem to contradict each other
- The "best" approach differs from what's documented here
- You're unsure if something qualifies as an architectural decision

**Example questions to ask:**
- "Issue #23 requires WebSocket support, but ADR-002 chose REST. Should I add WebSockets or find a REST-based solution?"
- "The existing pattern uses local state, but this feature seems to need global state. Should I follow the existing pattern or document a new approach?"
- "I found two different error handling patterns in the codebase. Which should I follow for this feature?"

**Remember**: This document is our collective memory. Keep it accurate and up-to-date!