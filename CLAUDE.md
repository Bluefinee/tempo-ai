# Development Guidelines

## 📋 Required Reference Documents

**IMPORTANT**: Always consult these coding standards before implementation:

- **Swift Development**: [Swift Coding Standards](.claude/swift-coding-standards.md)
- **TypeScript + Hono**: [TypeScript Hono Standards](.claude/typescript-hono-standards.md)
- **UX Design Principles**: [UX Concepts & Principles](.claude/ux_concepts.md)
- **Messaging Guidelines**: [Messaging Guidelines](guidelines/messaging-guidelines.md)

These documents contain project-specific best practices, naming conventions, architecture patterns, UX guidelines, and quality requirements. Reference them during every implementation task.

## Philosophy

### Core Beliefs

- **Incremental progress over big bangs** - Small changes that compile and pass tests
- **Learning from existing code** - Study and plan before implementing
- **Pragmatic over dogmatic** - Adapt to project reality
- **Clear intent over clever code** - Be boring and obvious

### Simplicity Means

- Single responsibility per function/class
- Avoid premature abstractions
- No clever tricks - choose the boring solution
- If you need to explain it, it's too complex

## Process

### 1. Planning & Staging

Break complex work into 3-5 stages. Document in `IMPLEMENTATION_PLAN.md`:

```markdown
## Stage N: [Name]

**Goal**: [Specific deliverable]
**Success Criteria**: [Testable outcomes]
**Tests**: [Specific test cases]
**Status**: [Not Started|In Progress|Complete]
```

### 2. Implementation Flow

1. **Understand** - Study existing patterns in codebase
2. **Test** - Write test first (red)
3. **Implement** - Minimal code to pass (green)
4. **Refactor** - Clean up with tests passing
5. **Commit** - With clear message linking to plan

### 3. When Stuck (After 3 Attempts)

**CRITICAL**: Maximum 3 attempts per issue, then STOP and reassess.

## Technical Standards

### Architecture Principles (SOLID)

- **Single Responsibility** - One reason to change
- **Open/Closed** - Open for extension, closed for modification
- **Liskov Substitution** - Subtypes must be substitutable
- **Interface Segregation** - Many specific interfaces over one general
- **Dependency Inversion** - Depend on abstractions, not concretions

### TypeScript/JavaScript Standards

#### Type Safety

- **NEVER use `any`** - Use `unknown` if type is truly unknown
- **Strict mode enabled** - All strict TypeScript flags on
- **Explicit return types** - Always declare function return types
- **Prefer `const` over `let`** - Immutability by default

```typescript
// ❌ Bad
const getData = (id: any) => fetch(`/api/${id}`).then((res) => res.json());

// ✅ Good
const getData = async (id: string): Promise<UserData> => {
  const response = await fetch(`/api/${id}`);
  if (!response.ok) throw new Error(`Failed: ${response.statusText}`);
  return response.json();
};
```

#### Function Style

- **Use arrow functions** - Consistent lexical `this` binding
- **Named exports** - Better for refactoring and tree-shaking

```typescript
// ✅ Prefer
export const processUser = (user: User): ProcessedUser => {
  // ...
};
```

#### DRY Principle

- Extract common logic into reusable utilities
- Single source of truth for constants/types
- Centralize validation and business rules

```typescript
// ❌ Bad - Repeated validation
const validateEmail = (email: string): boolean =>
  /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
const validateUserEmail = (email: string): boolean =>
  /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

// ✅ Good - Single implementation
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
export const isValidEmail = (email: string): boolean => EMAIL_REGEX.test(email);
```

### Comments Policy

**ONLY comment when**:

- Explaining "why" not "what" (business logic, workarounds)
- Documenting public APIs (JSDoc)
- Warning about non-obvious side effects

**NEVER comment**:

- Self-explanatory code
- Commented-out code (delete it)
- Obvious operations

```typescript
// ❌ Bad
// Get user by ID
const getUser = (id: string) => users.find((u) => u.id === id);

// ✅ Good - Self-documenting
const getUserById = (id: string): User | undefined =>
  users.find((user) => user.id === id);

// ✅ Good - Explains "why"
/**
 * Retry logic for flaky external API
 * Note: 3 retries needed due to rate limiting (see issue #123)
 */
const fetchWithRetry = async <T>(
  fetcher: () => Promise<T>,
  maxRetries = 3
): Promise<T> => {
  /* ... */
};
```

### JSDoc for Public APIs

```typescript
/**
 * Processes health data from multiple sources
 *
 * @param userId - Unique identifier for the user
 * @param options - Configuration options
 * @returns Promise resolving to health report
 * @throws {ValidationError} If user data is incomplete
 */
export const generateHealthReport = async (
  userId: string,
  options: ReportOptions
): Promise<HealthReport> => {
  // Implementation
};
```

### Error Handling

- Fail fast with descriptive messages
- Include context for debugging
- Use custom error types for domain errors
- Never silently swallow exceptions

```typescript
class ValidationError extends Error {
  constructor(
    message: string,
    public readonly field: string,
    public readonly value: unknown
  ) {
    super(message);
    this.name = "ValidationError";
  }
}
```

## Code Quality

### Every Commit Must

- Compile successfully
- Pass all existing tests
- Include tests for new functionality
- Follow project formatting/linting
- No TypeScript errors (strict mode)
- No `any` types

### Definition of Done

- [ ] Tests written and passing
- [ ] No linter/formatter warnings
- [ ] Public APIs have JSDoc
- [ ] Implementation matches plan
- [ ] No TODOs without issue numbers

## Decision Framework

When multiple valid approaches exist:

1. **Type Safety** - Is this fully type-safe?
2. **Testability** - Can I easily test this?
3. **Readability** - Will someone understand this in 6 months?
4. **Consistency** - Does this match project patterns?
5. **Simplicity** - Is this the simplest solution that works?

## Important Reminders

**NEVER**:

- Use `any` type (use `unknown` instead)
- Use `--no-verify` to bypass hooks
- Disable tests instead of fixing them
- Use function declarations (use arrow functions)
- Leave commented-out code

**ALWAYS**:

- Use arrow functions consistently
- Enable strict TypeScript mode
- Apply DRY and SOLID principles
- Write JSDoc for public APIs
- Keep comments minimal and purposeful
- Commit working code incrementally
- Stop after 3 failed attempts and reassess

# Phase 0 Development Commands

## Automated Development Workflow

Phase 0 introduces streamlined development commands for improved efficiency:

### Quality Assurance

```bash
# Comprehensive quality check (iOS + Backend)
./scripts/dev-commands.sh test-all

# Auto-fix linting issues
./scripts/dev-commands.sh lint-fix
```

### Development Servers

```bash
# Start backend development server
./scripts/dev-commands.sh dev-backend

# Build iOS application
./scripts/dev-commands.sh build-ios
```

### Help & Documentation

```bash
# Show available commands
./scripts/dev-commands.sh help
```

## Legacy Commands (Still Supported)

```bash
# iOS specific quality checks
cd ios && ./scripts/quality-check.sh

# Backend specific checks
cd backend && pnpm run type-check && pnpm run test

# Manual lint fixes
cd ios && ./scripts/fix-all.sh
cd backend && npx biome check --write .
```

## Multi-language Development

With Phase 0 internationalization infrastructure:

- iOS: LocalizationManager supports Japanese/English switching
- Backend: Localized Claude API prompts and error messages
- Resource files: Complete ja.lproj and en.lproj localization strings

See `guidelines/claude-plans/phase-0-implementation-plan.md` for detailed documentation.
