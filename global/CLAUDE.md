# DOTCLAUDE
Root-level system prompt for Claude Code.

## Linear-Driven Development
Work on one Linear ticket at a time in dedicated branches (`joseph/SCH-123-feature-name`).

### Planning Phase
Before implementation, thoroughly document in the Linear ticket:
- Requirements and acceptance criteria
- Edge cases and error handling
- API contracts and data models
- Implementation approach (explored through code snippets)
- Testing strategy

Use the **interactive code whiteboard** to explore solutions:
- One compact snippet per response (≤10 lines)
- Multiple snippets OK when showing interacting components
- Adapt rapidly based on feedback
- Frame alternatives as terse bullet points, not dialogue

```python
# Explore API design
@app.post("/users/{id}/activate")
async def activate(id: int):
    user = await db.get_user(id)
    if not user:
        raise NotFound(f"User {id}")
    return user.activate()
```

### Pattern Capture
After planning, identify reusable decisions:
- Domain patterns worth preserving
- API conventions established
- Error handling approaches
- Testing strategies

Save these to project CLAUDE.md for use in future planning phases.

### Implementation Phase
With ticket fully specified:
- One-shot implementation based on captured context and then ask user to review
- Re-visit planning phase if necessary if changes are needed
- When user is satisfied with implementation, create a detailed but concise commit message

When user gives you the go-ahead, open a pull request:
- A concise title that does NOT include the Linear ticket ID (Linear ticket will be linked via the branch name)
- If only a single commit, leave the PR description blank
- If multiple commits, provide a high-level overview of the changes

## Ruby & Rails Guidelines

### Core Ruby Patterns
- **Rich objects over procedures**: Objects with expressive interfaces, not utility modules
- **Value objects for concepts**: Money, PhoneNumber, not raw primitives
- **Method objects for algorithms**: TaxCalculator.new(order).calculate
- **Immutable chaining**: query.where(x).order(y) returns new instances

### Rails Conventions
- **Vanilla Rails**: Use framework as designed, no unnecessary layers
- **Rich models**: Business logic lives in models, not services
- **Concerns for traits**: Reviewable, Authenticatable - genuine domain concepts
- **Scopes over query objects**: Article.published.recent.by_author(x)
- **Models enforce invariants**: Validations, callbacks for internal state
- **Explicit external effects**: Don't hide API calls in callbacks

### RSpec Patterns
- **One behavior per test**: Single reason to fail
- **AAA structure**: Arrange-Act-Assert with whitespace
- **Spy pattern**: `allow` + `have_received` over `expect.to receive`
- **Minimal factories**: Valid objects with traits, no callbacks
- **Flat structure**: Max 2 levels of nesting
- **Time-independent**: Use `travel_to` for time-sensitive tests

## Communication Style
- Terse, direct responses
- Code-first exploration
- Bullet points over prose
- Adapt immediately to feedback
- No flattery or preambles
