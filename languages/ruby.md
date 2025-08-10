# Ruby Guidelines

## Rich Domain Objects Over Service Objects
Encapsulate behavior and data together in domain models rather than separating logic into procedural service classes.

* Put business logic directly in the models that own the data
* Use model methods that read like natural language about the domain
* Avoid creating service objects for operations that belong to a specific model
* Let models know how to save themselves, validate themselves, and perform their business operations

Good example:
```ruby
class Article < ApplicationRecord
  def publish!
    self.published_at = Time.current
    self.status = 'published'
    notify_subscribers
    save!
  end

  def unpublish!
    self.published_at = nil
    self.status = 'draft'
    save!
  end

  private

  def notify_subscribers
    # notification logic here
  end
end

# Usage
article.publish!
```

Bad example:
```ruby
class ArticlePublishingService
  def initialize(article)
    @article = article
  end

  def publish
    @article.published_at = Time.current
    @article.status = 'published'
    NotificationService.new(@article).send_notifications
    @article.save!
  end
end

# Usage
ArticlePublishingService.new(article).publish
```

## Chainable Fluent Interfaces
Design classes and methods to support expressive chaining, returning self or meaningful objects that allow continued operations.

* Return self from mutating methods to enable chaining
* Design APIs that read naturally when chained together
* Use Ruby's enumerable chains for data transformation
* Create query objects that can be progressively refined

Good example:
```ruby
class QueryBuilder
  def where(conditions)
    @conditions = (@conditions || {}).merge(conditions)
    self
  end

  def order(field)
    @order = field
    self
  end

  def limit(count)
    @limit = count
    self
  end
end

# Usage
users = User.active
  .where(role: 'admin')
  .order(:created_at)
  .limit(10)

# Enumerable chains
result = orders
  .select(&:paid?)
  .sum(&:total)
```

Bad example:
```ruby
class QueryBuilder
  def add_where_condition(conditions)
    @conditions = (@conditions || {}).merge(conditions)
    nil
  end

  def set_order(field)
    @order = field
    return
  end
end

# Usage
query = QueryBuilder.new
query.add_where_condition(role: 'admin')
query.set_order(:created_at)
query.set_limit(10)
users = query.execute

# Procedural transformation
paid_orders = []
orders.each { |o| paid_orders << o if o.paid? }
totals = []
paid_orders.each { |o| totals << o.total }
result = 0
totals.each { |t| result += t }
```