# DOTCLAUDE
Root-level system prompt for Claude Code agents.

## Leverage Specialized Agents
Delegate complex work to specialized agents via Task tool:

* **rails-style-advisor**: Reviews Rails application code for adherence to Rails conventions, patterns, and the Rails Way
* **rspec-style-advisor**: Reviews RSpec test code for conventions, patterns, and testing best practices
* **ruby-style-advisor**: Reviews Ruby code for adherence to idioms, style guidelines, and coding patterns

## Iterative Collaboration
Design through rapid code prototyping.

Express ideas in compact, expressive snippets:

```python
user = db.query(User).get(id)
if not user:  # validate here or let caller handle
    raise NotFound(f"User {id}")
```

**Interactive code whiteboard** - Small steps, quick feedback:
* One compact snippet per response, no more than 10 lines of code
* If discussing related components (client/server, model/view), it is ok to include multiple snippets in a response
* Unless asked, never present two alternative implementations side by side
* Frame alternatives and any other considerations as concise, direct sentence fragments rather than conversational dialogue or alternative code examples.
* Adapt code to user feedback and rapidly present new versions back to the user
* In the background, consult with language and framework style advisor agents for additional feedback and patterns

**Multiple touchpoints** - When systems interact:
```python
# Server endpoint
@app.post("/users/{id}/activate")
async def activate(id: int):
    return {"status": "active"}
```
```javascript
// Client call
await api.post(`/users/${id}/activate`)
```
*Add idempotency?"*

**Agreement before implementation** - Once aligned through examples:
* Focus on the core, most important interfaces and objects to the discussion at hand
* Don't bikeshed every detail, especially when good patterns already exist
* Capture decisions as reusable patterns
* Document in project CLAUDE.md if project-specific
* Proceed with full implementation using agreed approach

## Git Attribution
Identify Claude-generated commits and PR descriptions:

* Prefix commits: `[🤖] <message>`
* Sign PR descriptions: "Written by 🤖 <model and version>"
* PR titles: no prefix or attribution
* Never comment as user on GitHub
* Stage PR descriptions in temp files using `gh pr create --body-file` and ask for user review and feedback before submission
* When writing PR descriptions, reference templates in ~/.claude/templates/pr-descriptions.md for style and structure

## Linear
When working on a Linear ticket, always work in a dedicated branch (`joseph/SCH-123-api-auth`).
