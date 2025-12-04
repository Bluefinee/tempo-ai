# TypeScript + Hono Standards

> **Prerequisite**: Read [CLAUDE.md](../CLAUDE.md) TypeScript standards first. This document covers Hono-specific patterns.

## 🏗️ Hono Architecture

### Project Structure
```
src/
├── routes/              # API route handlers
│   ├── health.ts       
│   └── test.ts
├── services/           # Business logic (external API calls)
│   ├── ai.ts          # Claude AI integration
│   └── weather.ts     # Weather API
├── types/             # Domain-specific types
│   ├── health.ts
│   └── advice.ts
├── utils/             # Pure utility functions
│   ├── errors.ts
│   └── prompts.ts
└── middleware/        # Hono middleware
```

### App Initialization
```typescript
// ✅ Main app with typed bindings
import { Hono } from 'hono'
import { cors } from 'hono/cors'

interface Bindings {
  ANTHROPIC_API_KEY: string
  ENVIRONMENT: 'development' | 'production'
}

const app = new Hono<{ Bindings: Bindings }>()

app.use('/*', cors())
app.route('/api/health', healthRoutes)

export default app
```

## 🛤️ Route Patterns

### Route File Structure
```typescript
// ✅ routes/health.ts
import { Hono } from 'hono'
import { analyzeHealth } from '../services/ai'

const healthRoutes = new Hono<{ Bindings: Bindings }>()

healthRoutes.post('/analyze', async (c) => {
  try {
    const body = await c.req.json()
    
    if (!isValidAnalyzeRequest(body)) {
      return c.json({ error: 'Invalid request data' }, 400)
    }
    
    const result = await analyzeHealth({
      ...body,
      apiKey: c.env.ANTHROPIC_API_KEY
    })
    
    return c.json({ success: true, data: result })
  } catch (error) {
    return handleApiError(c, error)
  }
})

export { healthRoutes }
```

### Response Patterns
```typescript
// ✅ Consistent API responses
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
}

// ✅ Status code constants
const HttpStatus = {
  OK: 200,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  INTERNAL_SERVER_ERROR: 500
} as const

// Usage
return c.json({ success: true, data: result }, HttpStatus.OK)
```

## 🔍 Input Validation

### Request Validation
```typescript
// ✅ Type-safe request validation
interface AnalyzeHealthRequest {
  healthData: HealthData
  location: LocationData
  userProfile: UserProfile
}

const isValidAnalyzeRequest = (data: unknown): data is AnalyzeHealthRequest => {
  return (
    typeof data === 'object' &&
    data !== null &&
    'healthData' in data &&
    'location' in data &&
    'userProfile' in data
  )
}
```

## 🎯 Service Layer

### Business Logic Separation
```typescript
// ✅ services/ai.ts - Pure business logic
interface AnalyzeParams {
  healthData: HealthData
  location: LocationData
  userProfile: UserProfile
  apiKey: string
}

export const analyzeHealth = async (
  params: AnalyzeParams
): Promise<DailyAdvice> => {
  const prompt = buildPrompt(params)
  const response = await callClaudeApi(prompt, params.apiKey)
  return parseAdviceResponse(response)
}
```

## ⚡ Cloudflare Workers Optimization

### Performance Patterns
```typescript
// ✅ Minimize CPU time
export const processHealthData = (data: HealthData): ProcessedData => {
  // Fast calculations only
  return {
    summary: calculateQuickSummary(data),
    trends: identifyBasicTrends(data)
  }
}

// ✅ Efficient data structures for Workers
const responseCache = new Map<string, DailyAdvice>()
```

### Environment Variables
```typescript
// ✅ Type-safe environment access
const getApiKey = (c: Context<{ Bindings: Bindings }>): string => {
  const key = c.env.ANTHROPIC_API_KEY
  if (!key || key === 'test-key-not-configured') {
    throw new ApiError('Claude API key not configured', 500)
  }
  return key
}
```

## 🚨 Error Handling

### Hono Error Patterns
```typescript
// ✅ Custom error handling
export const handleApiError = (c: Context, error: unknown): Response => {
  if (error instanceof ValidationError) {
    return c.json({ error: error.message }, 400)
  }
  
  if (error instanceof ApiError) {
    return c.json({ error: error.message }, error.statusCode)
  }
  
  console.error('Unexpected error:', error)
  return c.json({ error: 'Internal server error' }, 500)
}
```

## 🧪 Testing Patterns

### Route Testing
```typescript
// ✅ Hono route testing
import { testClient } from 'hono/testing'
import app from '../src/index'

describe('Health Routes', () => {
  const client = testClient(app)
  
  it('should analyze health data', async () => {
    const response = await client.api.health.analyze.$post({
      json: mockAnalyzeRequest
    })
    
    expect(response.status).toBe(200)
    const data = await response.json()
    expect(data.success).toBe(true)
  })
})
```

## 🔐 Security Patterns

### Input Sanitization
```typescript
// ✅ Never log sensitive data
const logRequest = (request: AnalyzeHealthRequest): void => {
  console.log({
    timestamp: new Date().toISOString(),
    userAge: request.userProfile.age,
    hasHealthData: !!request.healthData
    // Never log actual health data
  })
}
```

## ✅ Hono Quality Checklist

- [ ] Routes use typed Hono context
- [ ] Input validation for all endpoints  
- [ ] Consistent API response format
- [ ] Environment variables typed
- [ ] Error handling with proper status codes
- [ ] Business logic in service layer
- [ ] Performance optimized for Workers
- [ ] No sensitive data in logs

---

**Note**: This supplements CLAUDE.md TypeScript standards with Hono-specific patterns.