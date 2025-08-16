# Ruby Patterns

## Bold Domain Language
* Choose names that tell a story and evoke the domain
* Use formal, memorable terminology over generic terms
* Make implicit concepts explicit through naming
* Inject personality and intentionality into your code

```ruby
# Good - expressive, memorable naming
class Subscription
  def terminate_with_prejudice
    revoke_all_access
    erect_tombstone
    incinerate_artifacts
  end

  def grant_clemency(grace_period)
    extension = calculate_reprieve(grace_period)
    decree_amnesty(extension)
    dispatch_pardon_notice
  end

  private

  def erect_tombstone
    Tombstone.new(
      epitaph: termination_reason,
      memorial_date: Time.current
    )
  end
end

# Bad - generic, forgettable naming
class Subscription
  def cancel
    remove_access
    mark_deleted
    cleanup_data
  end

  def extend(days)
    new_date = calculate_date(days)
    update_expiry(new_date)
    send_notification
  end
end
```

## Expressive Objects Over Procedural Code
* Design objects with intuitive interfaces that minimize surprise
* Favor behavioral messages over class checking (duck typing)
* Keep interfaces small and focused on what objects do, not what they are
* Objects should collaborate through well-defined protocols

```ruby
# Good - expressive object interface
class Temperature
  def self.from_celsius(degrees)
    new(celsius: degrees)
  end

  def to_fahrenheit
    (@celsius * 9/5.0) + 32
  end

  def freezing?
    @celsius <= 0
  end

  def boiling?
    @celsius >= 100
  end

  def comfortable_for_humans?
    @celsius.between?(18, 26)
  end
end

temp = Temperature.from_celsius(25)
puts "Wear shorts!" if temp.comfortable_for_humans?

# Bad - procedural utility functions
module TemperatureUtils
  def self.celsius_to_fahrenheit(celsius)
    celsius * 9/5.0 + 32
  end

  def self.is_freezing?(celsius)
    celsius <= 0
  end

  def self.is_comfortable?(celsius)
    celsius >= 18 && celsius <= 26
  end
end
```

## Rich Value Objects
* Create immutable objects for domain concepts
* Encapsulate validation and behavior with the data
* Support natural comparison and equality
* Provide conversion and formatting methods

```ruby
# Good - rich value object
class Money
  include Comparable

  attr_reader :amount, :currency

  def initialize(amount, currency = 'USD')
    raise ArgumentError, "Invalid amount" if amount < 0
    @amount = amount.to_d
    @currency = currency
    freeze
  end

  def +(other)
    ensure_same_currency!(other)
    Money.new(amount + other.amount, currency)
  end

  def *(multiplier)
    Money.new(amount * multiplier, currency)
  end

  def <=>(other)
    ensure_same_currency!(other)
    amount <=> other.amount
  end

  def to_s
    "$%.2f %s" % [amount, currency]
  end

  def zero?
    amount.zero?
  end

  private

  def ensure_same_currency!(other)
    raise ArgumentError, "Currency mismatch" if currency != other.currency
  end
end

price = Money.new(99.99)
tax = price * 0.08
total = price + tax

# Bad - primitive obsession
def calculate_total(price, tax_rate)
  price + (price * tax_rate)
end

total = calculate_total(99.99, 0.08)  # What currency? What precision?
```

## Command Objects For Complex Operations
* Encapsulate complex operations in dedicated command objects
* Provide clear success/failure feedback
* Support validation before execution
* Enable composition of operations

```ruby
# Good - command object pattern
class PublishArticle
  attr_reader :article, :publisher, :errors

  def initialize(article, publisher)
    @article = article
    @publisher = publisher
    @errors = []
  end

  def execute
    return false unless valid?

    article.transaction do
      article.publish!
      create_activity
      notify_subscribers
      schedule_social_posts
    end

    true
  rescue => e
    @errors << e.message
    false
  end

  def valid?
    validate_article_ready
    validate_publisher_authorized
    @errors.empty?
  end

  private

  def validate_article_ready
    @errors << "Article not ready" unless article.ready_to_publish?
  end

  def validate_publisher_authorized
    @errors << "Not authorized" unless publisher.can_publish?(article)
  end

  def create_activity
    Activity.create!(
      actor: publisher,
      action: 'published',
      target: article
    )
  end

  def notify_subscribers
    article.subscribers.each do |subscriber|
      ArticleMailer.published(subscriber, article).deliver_later
    end
  end

  def schedule_social_posts
    SocialPostJob.perform_later(article)
  end
end

# Usage
command = PublishArticle.new(article, current_user)
if command.execute
  redirect_to article, notice: "Published!"
else
  flash.now[:alert] = command.errors.join(", ")
  render :edit
end
```

## Builder Pattern For Complex Construction
* Use builders for objects with many configuration options
* Provide fluent interface for readability
* Validate at build time, not during construction
* Support sensible defaults

```ruby
# Good - builder pattern
class QueryBuilder
  def initialize
    @conditions = {}
    @includes = []
    @order = nil
    @limit = nil
  end

  def where(conditions)
    @conditions.merge!(conditions)
    self
  end

  def includes(*associations)
    @includes.concat(associations)
    self
  end

  def order(clause)
    @order = clause
    self
  end

  def limit(count)
    @limit = count
    self
  end

  def build
    Query.new(
      conditions: @conditions,
      includes: @includes,
      order: @order,
      limit: @limit
    )
  end
end

# Usage - reads like a sentence
query = QueryBuilder.new
  .where(status: 'active')
  .where(category: 'electronics')
  .includes(:reviews, :seller)
  .order(created_at: :desc)
  .limit(20)
  .build

# Bad - constructor with many parameters
query = Query.new(
  { status: 'active', category: 'electronics' },
  [:reviews, :seller],
  { created_at: :desc },
  20,
  nil,  # offset
  false # distinct
)
```

## Null Objects Over Nil Checks
* Replace nil with objects that respond to the same interface
* Eliminate defensive nil checking throughout the codebase
* Provide sensible default behavior

```ruby
# Good - null object pattern
class NullUser
  def name
    "Guest"
  end

  def email
    "no-reply@example.com"
  end

  def premium?
    false
  end

  def can_edit?(resource)
    false
  end

  def avatar_url
    "/images/default-avatar.png"
  end
end

class Session
  def current_user
    @current_user || NullUser.new
  end
end

# Usage - no nil checks needed
session = Session.new
puts "Welcome, #{session.current_user.name}"
if session.current_user.can_edit?(article)
  # Show edit button
end

# Bad - nil checks everywhere
if current_user
  name = current_user.name
else
  name = "Guest"
end

if current_user && current_user.can_edit?(article)
  # Show edit button
end
```

## Method Objects For Complex Algorithms
* Extract complex methods into dedicated objects
* Make steps explicit and testable
* Support configuration and customization
* Enable reuse across different contexts

```ruby
# Good - method object
class TaxCalculator
  attr_reader :order, :address

  def initialize(order, address)
    @order = order
    @address = address
  end

  def calculate
    return 0 if exempt?

    base_tax + luxury_tax + local_surcharge
  end

  private

  def exempt?
    address.tax_exempt? || order.total < minimum_taxable_amount
  end

  def base_tax
    order.taxable_amount * tax_rate
  end

  def luxury_tax
    return 0 unless order.contains_luxury_items?
    order.luxury_amount * luxury_tax_rate
  end

  def local_surcharge
    return 0 unless address.has_local_surcharge?
    order.total * address.surcharge_rate
  end

  def tax_rate
    TaxRateService.for_region(address.region)
  end

  def luxury_tax_rate
    0.10
  end

  def minimum_taxable_amount
    10.00
  end
end

# Usage
tax = TaxCalculator.new(order, shipping_address).calculate
order.update!(tax: tax, total: order.subtotal + tax)

# Bad - complex method in model
class Order
  def calculate_tax
    return 0 if shipping_address.tax_exempt? || total < 10.00

    base = taxable_amount * TaxRateService.for_region(shipping_address.region)

    luxury = 0
    if contains_luxury_items?
      luxury = luxury_amount * 0.10
    end

    surcharge = 0
    if shipping_address.has_local_surcharge?
      surcharge = total * shipping_address.surcharge_rate
    end

    base + luxury + surcharge
  end
end
```

## Domain Concepts Over Primitives
* Wrap primitive values in domain objects
* Make implicit concepts explicit
* Enforce invariants at the type level
* Support rich behavior on domain concepts

```ruby
# Good - domain concepts as objects
class EmailAddress
  attr_reader :value

  def initialize(value)
    @value = value.downcase.strip
    raise ArgumentError, "Invalid email" unless valid?
    freeze
  end

  def valid?
    value.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def domain
    value.split('@').last
  end

  def local_part
    value.split('@').first
  end

  def corporate?
    !domain.include?('gmail') && !domain.include?('yahoo')
  end

  def to_s
    value
  end
end

class User
  def email=(value)
    @email = EmailAddress.new(value)
  end

  def email
    @email
  end
end

user.email = "John@EXAMPLE.com  "
puts user.email.domain  # "example.com"
puts user.email.corporate?  # true

# Bad - primitive strings everywhere
class User
  attr_accessor :email

  def email=(value)
    @email = value.downcase.strip
  end

  def email_domain
    email.split('@').last if email
  end

  def corporate_email?
    return false unless email
    !email.include?('gmail') && !email.include?('yahoo')
  end
end
```

## Immutable Chain Building
* Return new instances from chain methods, not self
* Use `with` pattern for modified copies
* Enable chain forking without affecting originals
* Support functional composition

```ruby
# Good - immutable chaining
class Query
  attr_reader :conditions, :ordering, :limit_value

  def initialize(conditions: {}, ordering: nil, limit_value: nil)
    @conditions = conditions.freeze
    @ordering = ordering
    @limit_value = limit_value
    freeze
  end

  def where(new_conditions)
    with(conditions: conditions.merge(new_conditions))
  end

  def order(field)
    with(ordering: field)
  end

  def limit(count)
    with(limit_value: count)
  end

  private

  def with(attrs)
    self.class.new(
      conditions: conditions,
      ordering: ordering,
      limit_value: limit_value,
      **attrs
    )
  end
end

base = Query.new
active = base.where(status: 'active')
recent = active.order(:created_at)
top_ten = recent.limit(10)

# Original queries unchanged
puts base.conditions  # {}
puts active.conditions  # {status: 'active'}

# Bad - mutable chaining
class Query
  def where(conditions)
    @conditions ||= {}
    @conditions.merge!(conditions)
    self
  end

  def order(field)
    @ordering = field
    self
  end
end

base = Query.new
active = base.where(status: 'active')
recent = active.order(:created_at)
# base is now mutated!
```
