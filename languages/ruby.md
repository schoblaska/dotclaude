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
* Transform procedural state mutation into composable transformations

```ruby
# Good - each object has one clear job
class PriceCalculator
  def initialize(order)
    @order = order
  end

  def total
    base = BasePrice.new(@order.items).calculate
    discount = Discount.new(@order.coupon, base).calculate
    shipping = Shipping.new(@order.items, @order.address).calculate

    base - discount + shipping
  end
end

class Discount
  def initialize(coupon, amount)
    @coupon = coupon
    @amount = amount
  end

  def calculate
    return 0 unless @coupon

    case @coupon.type
    when :percentage then @amount * @coupon.value / 100.0
    when :fixed then [@coupon.value, @amount].min
    else 0
    end
  end
end

# Bad - procedural class with tangled state
class OrderProcessor
  def initialize(order)
    @order = order
    @subtotal = 0
    @discount = 0
  end

  def calculate_total
    calculate_subtotal
    apply_discount
    calculate_shipping
    @subtotal  # mutated through the chain
  end

  private

  def calculate_subtotal
    @subtotal = @order.items.sum { |i| i.quantity * i.unit_price }
  end

  def apply_discount
    return unless @order.coupon

    if @order.coupon.type == :percentage
      @discount = @subtotal * @order.coupon.value / 100.0
    elsif @order.coupon.type == :fixed
      @discount = [@order.coupon.value, @subtotal].min
    end

    @subtotal -= @discount  # mutates running total
  end

  def calculate_shipping
    weight = @order.items.sum(&:weight)
    shipping = weight * @order.address.zone_rate
    shipping += weight > 50 ? 15 : 5

    @subtotal += shipping  # mutates again
  end
end
```

## Domain Concepts Over Arbitrary Fragments
* Extract methods only when they represent genuine domain concepts or reusable logic
* Keep related steps together when they form a coherent process
* Resist fragmenting logic into arbitrary "helper" methods that lack domain meaning
* Test: Can you explain what this method does without reading its implementation?

TODO: example