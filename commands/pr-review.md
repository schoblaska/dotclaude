# PR Review Assistant

Collaboratively prepare thorough pull request reviews through interactive code analysis and discussion.

## Usage

```bash
/pr-review <pr-url-or-number>
```

## Process

I'll help you build a comprehensive PR review through collaborative analysis:

1. **Setup**: Check out PR branch locally, fetch linked tickets in background
2. **Analyze**: Review code against patterns, requirements, and test coverage
3. **Discuss**: Work through observations together, opening files at specific lines
4. **Finalize**: Write raw feedback items to temp file for you to use to write the actual review

You maintain full control over the final review content and submission.

## Interactive Workflow

### Initial Assessment
After checking out the branch and starting background fetches, I'll present:
- Brief summary of PR changes and initial impressions
- Bullet list of discussion points discovered during analysis
- Each point becomes a focused discussion topic

### Collaborative Discussion
For each point, we'll:
- Open relevant files at specific lines in your editor
- Discuss implications and alternatives together
- Determine if it's a blocker, suggestion, or non-issue
- Update notes based on your expertise and context

### Background Integration
While we discuss:
- Linked tickets (Linear, GitHub Issues) load asynchronously
- Requirements verification happens as data becomes available
- New insights get added to discussion points dynamically

### Final Output
After discussion, I'll write feedback to `/tmp/pr_review_<number>.md`:
- **Strengths**: Well-implemented features worth highlighting
- **Must Fix**: Blocking issues requiring changes
- **Consider**: Non-blocking improvement suggestions
- **Questions**: Clarifications for the author
- **Testing**: Manual verification performed locally

## What I Check

- **Requirements**: Verify implementation matches ticket acceptance criteria
- **Patterns**: Compare against ~/.claude/patterns/ conventions
- **Test Coverage**: Assess automated tests for completeness and edge cases
- **Code Quality**: Identify potential issues, improvements, or concerns
- **Local Behavior**: Suggest and help perform manual testing scenarios

## Example Session

```
User: /pr-review https://github.com/owner/repo/pull/123

Claude: [Checks out branch, starts fetching Linear ticket SCH-456 in background, analyzes code]

This PR implements authentication middleware for the API with JWT token handling
and session management. The implementation is clean and follows established patterns
from our codebase. I've identified a few areas worth discussing around error handling
and configuration.

### Points for Discussion
1. Missing error handling for token refresh failures (auth_middleware.py:45-52)
2. Magic numbers in connection pool logic (db_pool.py:18, 23)
3. Use a script to send concurrent requests locally and confirm throttling behavior

User: Ok, let's look at 1

[Claude opens auth_middleware.py at line 45 in user's editor]

User: I think this is OK, actually. We handle this in the base controller.

Claude: You're right, I see the base controller wraps all responses. Let me update
my notes. Looking at point 2 now - the connection pool has hardcoded values of 10
for min_size and 50 for max_size. Should these be configurable?

User: Yes, good catch. Those should definitely be in config.

Claude: Noted. By the way, the Linear ticket SCH-456 just finished loading in the background.
I noticed it lists rate limiting as a core requirement - "must limit to 100 req/s per user" -
but I don't see any rate limiting implementation in this PR. Should we add this to our
discussion points?

User: Definitely, that's a big miss. Let's flag that as a must-fix.

Claude: Added to the list. Let's continue with point 3 about testing...

[After all points discussed]

Claude: Based on our discussion, I'll compile the final review feedback now.

[Claude writes feedback to /tmp/pr_review_123.md and opens it in editor]

## Final Review Feedback

### Strengths
- Clean implementation of JWT auth middleware following established patterns
- Comprehensive test suite with 92% coverage including edge cases
- Good separation of concerns between auth, session, and token management
- Clear error messages and proper HTTP status codes

### Must Fix
- **Missing rate limiting implementation** (SCH-456 requirement)
  - Ticket specifies "100 req/s per user" but no implementation found
  - At minimum, PR description should explain if this is planned for follow-up
- **Hardcoded connection pool values** (db_pool.py:18, 23)
  - Move min_size=10 and max_size=50 to configuration
  - Consider environment-specific defaults

### Consider
- **Token expiry configuration** (auth_middleware.py:72)
  - Currently hardcoded to 3600 seconds
  - Extract to config with reasonable defaults per environment
- **Add debug logging for token refresh flow** (auth_middleware.py:45-52)
  - Would help troubleshoot issues in production
  - Log token age, refresh attempts, and outcomes

### Automated Tests
- **Missing test for rate limit edge case** (test_auth.py)
  - No test for exactly 100 req/s threshold behavior
  - Add test to verify graceful handling at limit boundary

### Local Testing Results
- Manually tested token refresh with expired tokens:
  ```bash
  # Set TOKEN_EXPIRY=5 in config, wait 6 seconds, attempt API call
  ```
- Verified concurrent request handling:
  ```bash
  # Run provided stress test script: tests/load/concurrent_auth.py
  ```
- Confirmed logout properly clears all session data including cache
```