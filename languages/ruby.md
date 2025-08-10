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
class Query
  def where(conditions)
    with(conditions: @conditions.merge(conditions))
  end

  def limit(n)
    with(limit: n)
  end

  private

  def with(attrs)
    self.class.new(@base_attrs.merge(attrs))
  end
end

base = Query.new(table: 'users')
active = base.where(active: true)
recent = active.where(created: '2024-01-01..')
limited = recent.limit(10)
# base remains unchanged

# Bad - mutates self
class Query
  def where(conditions)
    @conditions.merge!(conditions)
    self
  end
end
```

## Block-Based Configuration
* Use blocks for optional configuration
* Yield self or configuration object for DSL-style setup
* Enable both inline and block-based usage

```ruby
# Good - flexible configuration
class Client
  attr_accessor :url, :timeout, :headers

  def initialize(url = nil)
    @url = url
    yield self if block_given?
  end
end

# Both styles work
client = Client.new('https://api.example.com')

client = Client.new do |c|
  c.url = 'https://api.example.com'
  c.timeout = 30
  c.headers = { 'Authorization' => 'Bearer token' }
end

# Bad - rigid initialization
class Client
  def initialize(url, timeout, headers)
    @url = url
    @timeout = timeout
    @headers = headers
  end
end
```

## Clear Mutation Signals
* Use `!` for methods that mutate or have side effects
* Return transformed values instead of mutating state
* Compose transformations functionally

```ruby
# Good - clear mutation signal
def normalize!
  @name = @name.strip.downcase
  @email = @email.strip.downcase
  self
end

def normalized
  self.class.new(
    name: @name.strip.downcase,
    email: @email.strip.downcase
  )
end

# Bad - hidden mutation
def normalize
  @name = @name.strip.downcase
  @email = @email.strip.downcase
end
```