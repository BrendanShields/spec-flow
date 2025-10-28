# Flow Clarify Examples

## 1. API Authentication Method

**Ambiguity in spec**:
```markdown
## FR-2: User Authentication
[NEEDS CLARIFICATION: Authentication method not specified]
```

**Clarification Q&A**:
```
Q1: Authentication Method

Recommended: OAuth2 with JWT tokens
Rationale: Industry standard, scalable, stateless

Options:
A. OAuth2 + JWT - Scalable, supports refresh tokens, stateless
B. Session-based - Simpler implementation, requires session store
C. API Keys - Service-to-service only, not for user auth

User selected: A (OAuth2 + JWT)
```

**Updated spec**:
```markdown
## FR-2: User Authentication

Users authenticate via OAuth2 with JWT tokens:
- Access token: 15 minute expiration
- Refresh token: 7 day expiration
- Token storage: HTTP-only cookies
```

## 2. Performance Requirements

**Ambiguity**:
```markdown
## NFR-3: Performance
System should be "fast" and "responsive"
[NEEDS CLARIFICATION: "fast" and "responsive" are vague]
```

**Clarification**:
```
Q2: Performance Metrics

Recommended: API <500ms p95, UI <2s load
Rationale: Industry standard for web applications

What specific metrics define "fast"?
A. API response time target
B. Page load time target
C. Database query performance
D. All of the above

User selected: D (All metrics)

Follow-up: What are the specific thresholds?
- API response: <500ms (p95)
- Page load: <2s (first contentful paint)
- DB queries: <100ms (p95)
```

**Updated spec**:
```markdown
## NFR-3: Performance

**API Response Time**:
- p95: <500ms
- p99: <1000ms

**Page Load Time**:
- First Contentful Paint: <2s
- Time to Interactive: <3s

**Database Queries**:
- Simple queries: <50ms (p95)
- Complex queries: <100ms (p95)
```

## 3. Error Handling Strategy

**Ambiguity**:
```markdown
## FR-5: Product Search
Users can search products
[NEEDS CLARIFICATION: Error handling for no results, invalid queries, timeouts]
```

**Clarification**:
```
Q3: Search Error Handling

Recommended: User-friendly messages with recovery options

Scenarios to clarify:
1. No results found - Show "No products match" + suggestions?
2. Invalid query - Validate before search or show error after?
3. Search timeout - Retry automatically or show error?

User responses:
1. Show "No results" with: similar products, clear filters
2. Client-side validation, prevent invalid searches
3. Show error after 5s timeout, manual retry button
```

**Updated spec**:
```markdown
## FR-5: Product Search - Error Handling

**No Results**:
- Display: "No products match your search"
- Suggestions: Show 3 similar products
- Action: "Clear filters" button

**Invalid Query**:
- Client-side validation (min 2 chars, max 100)
- Prevent search submission if invalid
- Show inline error message

**Timeout**:
- Timeout threshold: 5 seconds
- Display: "Search is taking longer than expected"
- Action: Manual "Try again" button
- No automatic retry
```

## 4. Data Model Ambiguity

**Ambiguity**:
```markdown
## DM-1: User Profile
Users have profiles
[NEEDS CLARIFICATION: Required vs optional fields, validation rules]
```

**Clarification**:
```
Q4: User Profile Fields

Which fields are required vs optional?

Recommended structure:
Required: email, name, password
Optional: phone, address, bio

User response: Accepted with additions:
- Required: email, first_name, last_name, password
- Optional: phone, address, bio, avatar_url, preferences
```

**Updated spec**:
```markdown
## DM-1: User Profile

**Required Fields**:
- email (string, unique, validated)
- first_name (string, 1-50 chars)
- last_name (string, 1-50 chars)
- password (string, min 8 chars, hashed)

**Optional Fields**:
- phone (string, E.164 format)
- address (JSON object)
- bio (text, max 500 chars)
- avatar_url (string, URL)
- preferences (JSON object)
```

## 5. Multiple Valid Approaches

**Ambiguity**:
```markdown
## FR-8: File Upload
Users can upload product images
[NEEDS CLARIFICATION: Direct upload vs presigned URL vs background processing]
```

**Clarification**:
```
Q5: File Upload Strategy

Options with tradeoffs:

A. Direct Upload to Server
   + Simple implementation
   - Server bandwidth intensive
   - Blocking during upload

B. Presigned S3 URLs
   + Client uploads directly to S3
   + No server bandwidth
   - More complex flow

C. Background Processing
   + Non-blocking for user
   + Can resize/optimize
   - Delayed availability

User selected: B (Presigned S3 URLs)
Reasoning: Scalability is priority, can handle complexity
```

**Updated spec**:
```markdown
## FR-8: File Upload - Implementation

**Strategy**: Presigned S3 URL approach

**Flow**:
1. Client requests upload URL from API
2. API generates presigned S3 URL (15 min expiration)
3. Client uploads directly to S3 using presigned URL
4. Client notifies API of successful upload
5. API validates and associates image with product

**Constraints**:
- Max file size: 10MB
- Allowed formats: JPEG, PNG, WebP
- Max 5 images per product
```

For detailed clarification patterns and best practices, see [REFERENCE.md](./REFERENCE.md).
