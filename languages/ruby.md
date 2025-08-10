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

## Utility Objects For Complex Logic
* Break complex operations into focused, reusable utility objects
* Create single-purpose classes that encapsulate specific responsibilities
* Coordinate objects to achieve sophisticated behavior
* Even procedural-seeming tasks can benefit from object-oriented decomposition

```ruby
# Good - utility objects coordinate to handle CSV export
class CsvExporter
  def initialize(data, formatter: CsvFormatter.new)
    @data = data
    @formatter = formatter
  end

  def export
    @formatter.format(@data)
  end
end

class CsvFormatter
  def format(records)
    CSV.generate do |csv|
      csv << headers_for(records.first)
      records.each { |record| csv << values_for(record) }
    end
  end

  private

  def headers_for(record)
    record.attributes.keys.map(&:humanize)
  end

  def values_for(record)
    record.attributes.values
  end
end

# Usage - clean, testable, extensible
exporter = CsvExporter.new(users)
csv_content = exporter.export

# Bad - procedural service class
class ExportService
  def self.export_users_to_csv(users)
    CSV.generate do |csv|
      csv << users.first.attributes.keys.map(&:humanize)
      users.each do |user|
        csv << user.attributes.values
      end
    end
  end
end

# Usage - harder to test, extend, or reuse
csv_content = ExportService.export_users_to_csv(users)
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