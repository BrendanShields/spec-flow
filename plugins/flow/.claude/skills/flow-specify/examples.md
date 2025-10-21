# Flow Specify: Examples

## Example 1: E-commerce Feature
**Input**: "Add a shopping cart with checkout"

**Generated Output**:
```markdown
# Feature Specification: Shopping Cart & Checkout

## User Stories (Prioritized)

### User Story 1 - Add Items to Cart (P1)
**As a** shopper
**I want to** add products to my cart
**So that** I can purchase multiple items

**Acceptance Criteria**:
- Given product page, When click "Add to Cart", Then item appears in cart
- Given cart has items, When view cart, Then see all items with quantities

### User Story 2 - Checkout Process (P1)
**As a** shopper
**I want to** complete checkout securely
**So that** I can receive my items

### User Story 3 - Save Cart for Later (P2)
**As a** returning customer
**I want to** save my cart
**So that** I can continue shopping later
```

## Example 2: API Feature
**Input**: "Create REST API for user management"

**Generated with Domain Detection**: API patterns, OpenAPI spec references, CRUD operations

## Example 3: Real-time Feature
**Input**: "Add real-time chat to the app"

**Auto-detected**: WebSocket requirements, presence indicators, message persistence