# PR Review Assistant

Collaboratively prepare thorough pull request reviews by analyzing code changes, suggesting tests, and building feedback lists together.

## Usage

```bash
/pr-review <pr-url-or-number>
```

## Process Overview

I'll help you prepare a comprehensive PR review by:
1. Checking out the PR branch locally for testing
2. Fetching any referenced tickets (Linear, GitHub Issues) to verify requirements
3. Analyzing code changes and test coverage
4. Presenting initial assessment with discussion points
5. Working through each point together
6. Providing final bullet-point summary for your review

**Important**: I assist with review preparation only. You maintain full control over the final review content and submission.

## Workflow Steps

### 1. Branch Setup
- Parse PR URL or number to identify repository and PR
- Fetch latest changes from remote
- Check out PR branch locally
- Show branch info and changed files overview

### 2. Requirements Verification
- Check PR description for ticket references (Linear, GitHub Issues, etc.)
- Fetch ticket details in background to understand requirements
- Verify PR implementation satisfies all acceptance criteria
- Flag any gaps between spec and implementation

### 3. Code Analysis
- Load relevant pattern files from ~/.claude/patterns/ based on file types
- Compare implementation against established conventions
- Check for consistency with existing codebase patterns
- Identify potential improvements or concerns

### 4. Test Coverage Review
- **Automated Tests**: Review test coverage included in the PR
  - Assess if tests adequately cover new functionality
  - Check for edge cases in test scenarios
  - Identify gaps in test coverage if any

### 5. Local Testing
Suggest manual testing approaches to perform with the user to verify PR behavior locally.
  - Recommend specific scenarios to verify locally
  - Identify edge cases worth testing manually
  - Provide commands, scripts, or steps for local verification

### 6. Initial Assessment
- Generate comprehensive bullet list of review points
- Organize by category: requirements, implementation, testing, etc.
- Present list for collaborative discussion
- Each point becomes a mini-discussion topic

### 7. Point-by-Point Discussion
- Work through each assessment point individually
- Discuss implications and alternatives
- Refine understanding of issues
- Determine if additional investigation needed

### 8. Final Summary
- Compile refined feedback from discussions
- Provide clean bullet-point summary
- Include only actionable feedback items
- Ready for user to craft personal review

## Output Format

### Initial Assessment
After analyzing the PR, I'll present a brief overview with points to discuss:

```markdown
## Initial Review Assessment

[Brief paragraph summarizing the PR changes and my initial findings - what the PR does well, any concerns noticed, and overall impression]

### Points for Discussion
- [First observation or question to explore together]
- [Pattern adherence or design consideration]
- [Test coverage observation]
- [Any requirements gaps found during background check]
- [Additional points worth discussing...]
```

### Final Summary
After our discussion, I'll provide:

```markdown
## Final Review Feedback

### Strengths
- [Well-implemented features worth highlighting]

### Must Fix
- [Blocking issues that need addressing]

### Consider
- [Non-blocking suggestions for improvement]

### Questions for Author
- [Clarifications needed]

### Testing Recommendations
- [Specific local testing to perform]
```

## Best Practices

- Provide constructive suggestions with examples when possible
- Acknowledge good implementations and clever solutions
- Consider the PR's scope - avoid scope creep in feedback
- Reference relevant patterns or documentation

## Interactive Elements

During our review session, you can:
- Ask me to focus on specific areas of concern
- Request deeper analysis of complex changes
- Have me explain potential impacts of changes
- Add your own observations to the list

## Limitations

- I prepare a summary of feedback items but do NOT submit reviews
- I won't use GitHub API to post comments or reviews
- Review submission remains your responsibility
- You maintain editorial control over all feedback

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
I noticed it lists rate limiting as a core requirement - "must handle 100 req/s per user" -
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