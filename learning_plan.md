
## LLM Agent Development Learning Plan

**Goal:** Build LLM systems in Elixir with minimal dependencies to understand core concepts

**Approach:**
- Start with raw API calls, gradually add complexity
- Keep dependencies minimal (Req, Jason, maybe InstructorLite later)
- Focus on message chains and explicit communication
- Use Elixir's natural strengths (pattern matching, Tasks, functional composition)

**Learning Progression:**
1. **Week 1:** Raw HTTP calls to OpenAI/Anthropic APIs
2. **Week 2:** Add message history management
3. **Week 3:** Add structured outputs (JSON mode)
4. **Week 4:** Implement patterns from the blog post

**Key Resources:**
- Blog series: "Why Elixir/OTP doesn't need an Agent framework" (Parts 1 & 2)
- Focus on understanding message chains before adding abstractions
- MCP understanding can come later for production systems

**Philosophy:**
- Understand what's happening under the hood
- Build intuition about LLM behavior through direct interaction
- Avoid heavy frameworks until you understand the fundamentals
- Let Elixir's concurrency model handle parallelization naturally

**Next Steps:**
Start with a minimal HTTP client example using `Req` and `Jason` for basic LLM conversation.
