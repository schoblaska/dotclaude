# Ruby Guidelines

## Expressive Objects Over Procedural Code
* Design objects with intuitive interfaces that minimize surprise
* Favor behavioral messages over class checking (duck typing)
* Balance expressiveness with clarity - code should read like intent
* Keep interfaces small and focused on what objects do, not what they are

```ruby
# Good - expressive interface
class Temperature
  def to_fahrenheit
    @celsius * 9/5.0 + 32
  end
  
  def freezing?
    @celsius <= 0
  end
end

temp.freezing? # reads like a question

# Bad - procedural utilities
class TemperatureUtils
  def self.convert_c_to_f(celsius)
    celsius * 9/5.0 + 32
  end
  
  def self.is_freezing(celsius)
    celsius <= 0
  end
end

TemperatureUtils.is_freezing(temp_c) # procedural, not object-oriented
```

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