# Ruby Guidelines

## Rich Domain Objects Over Service Objects
Encapsulate behavior and data together in domain models rather than separating logic into procedural service classes.

* Put business logic directly in the models that own the data
* Use model methods that read like natural language about the domain
* Avoid creating service objects for operations that belong to a specific model
* Let models know how to save themselves, validate themselves, and perform their business operations

Good example:
```ruby
class Item < ActiveRecord::Base
  def activate!
    self.active = true
    self.activated_at = Time.current
    notify_watchers
    save!
  end
end

# Usage
item.activate!
```

Bad example:
```ruby
class ItemActivationService
  def activate(item)
    item.active = true
    item.activated_at = Time.current
    NotificationService.new(item).notify
    item.save!
  end
end

# Usage
ItemActivationService.new.activate(item)
```

## Immutable Chain Building
Build chainable interfaces that return new instances rather than mutating self, allowing chains to be forked and reused.

* Return new instances from chain methods, not mutated self
* Use `with` pattern to create modified copies with new parameters
* Allow branching chains from any point without affecting the original
* Preserve immutability to enable safe concurrent use

Good example:
```ruby
class Search
  def where(conditions)
    with(conditions: @conditions.merge(conditions))
  end

  def limit(n)
    with(limit: n)
  end

  def with(**params)
    self.class.new(@opts.merge(params))
  end
end

# Usage - can fork chains
base = Search.new.where(active: true)
admins = base.where(role: 'admin')
users = base.where(role: 'user')
```

Bad example:
```ruby
class Search
  def where(conditions)
    @conditions.merge!(conditions)
    self
  end

  def limit(n)
    @limit = n
    self
  end
end

# Usage - mutations prevent forking
base = Search.new.where(active: true)
admins = base.where(role: 'admin') # base is now modified!
```

## Clear Mutation Signals
Make mutation explicit with bang methods (!) or use functional transformations that return new values without side effects.

* Use `!` suffix for methods that mutate the receiver or have significant side effects
* Prefer returning transformed values over mutating instance variables
* Build complex transformations through method composition, not stateful accumulation
* Make it obvious whether a method changes state or returns a new value

Good example:
```ruby
class Processor
  def process(data)
    transform(data)
      .then { |d| filter(d) }
      .then { |d| format(d) }
  end

  private

  def filter(data)
    data.merge("items" => data["items"].select(&:valid?))
  end
end

# Usage
result = Processor.new.process(data)
```

Bad example:
```ruby
class Processor
  def process(data)
    @data = data.dup
    filter_items
    format_output
    @data
  end

  private

  def filter_items
    @data["items"] = @data["items"].select(&:valid?)
  end
end
```