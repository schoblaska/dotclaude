# Ruby Guidelines

## Rich Domain Objects Over Service Objects
* Put business logic in models that own the data
* Use methods that read like natural language
* Avoid service objects for model-specific operations
* Models handle their own persistence and validation

Good: `item.activate!` (domain method)
Bad: `ItemActivationService.new.activate(item)` (procedural service)

## Immutable Chain Building
* Return new instances from chain methods, not self
* Use `with` pattern for modified copies
* Enable chain forking without affecting originals

```ruby
# Good - returns new instance
def where(conditions)
  with(conditions: @conditions.merge(conditions))
end

# Bad - mutates self
def where(conditions)
  @conditions.merge!(conditions)
  self
end
```

## Clear Mutation Signals
* Use `!` for methods that mutate or have side effects
* Return transformed values instead of mutating state
* Compose transformations functionally

Good: `.then { |d| filter(d) }` (functional composition)
Bad: `@data = data; filter_items` (stateful mutation)