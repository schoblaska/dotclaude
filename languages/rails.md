# Rails Guidelines

## Rich Domain Models
* Put business logic in models that own the data
* Use methods that read like natural language
* Avoid service objects for model-specific operations
* Models handle their own persistence and validation

```ruby
# Good - rich domain model
class Article < ApplicationRecord
  def publish!
    self.published_at = Time.current
    self.status = 'published'
    notify_subscribers
    save!
  end

  def archive!
    update!(archived: true, archived_at: Time.current)
  end

  private

  def notify_subscribers
    # Side effect handled by model
    subscribers.each { |s| ArticleMailer.published(s, self).deliver_later }
  end
end

article.publish!

# Bad - anemic model with service
class PublishArticleService
  def call(article)
    article.published_at = Time.current
    article.status = 'published'
    article.save!
    NotificationService.new.notify_about(article)
  end
end
```

## Callbacks Within Boundaries
* Use callbacks for object-internal transformations
* Use explicit method calls for external side effects
* Keep cascade depth visible and testable

```ruby
# Good - callbacks for internal state, explicit for external
class Comment < ApplicationRecord
  belongs_to :article, counter_cache: true
  belongs_to :user

  before_save :extract_mentions
  after_destroy :cleanup_associations

  def publish!
    transaction do
      save!
      notify_mentioned_users
      update_user_stats
    end
  end

  private

  def extract_mentions
    # Internal data transformation - good for callback
    self.mentioned_user_ids = body.scan(/@(\w+)/).map { |u| User.find_by(username: u) }
  end

  def cleanup_associations
    # Cleaning up owned data - stays within boundary
    notifications.destroy_all
  end

  def notify_mentioned_users
    # External effect - explicit call
    mentioned_users.find_each do |user|
      CommentMailer.mentioned(user, self).deliver_later
    end
  end

  def update_user_stats
    # External effect - explicit call
    user.increment!(:comments_count)
  end
end

# Usage makes side effects visible
@comment = Comment.new(comment_params)
@comment.publish! # Clear that this does more than save
```

## Query Objects As Scopes
* Use scopes for reusable query logic
* Chain scopes for composable queries
* Controllers compose scopes for their needs

```ruby
# Good - reusable scopes, controller composes
class Post < ApplicationRecord
  scope :published, -> { where(status: 'published') }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_author, ->(author) { where(author: author) }
end

class HomepageController < ApplicationController
  def index
    @posts = Post.published.featured.recent.limit(5)
    @events = Event.upcoming.featured.limit(3)
  end
end

class PostsController < ApplicationController
  def index
    @posts = Post.published.recent
    @posts = @posts.by_author(params[:author]) if params[:author]
  end
end

# Bad - model knows about UI contexts
class Post < ApplicationRecord
  def self.for_homepage
    published.featured.recent.limit(5)
  end

  def self.for_sidebar
    published.popular.limit(10)
  end
end
```

## Domain Objects Beyond ActiveRecord
* Create Plain Old Ruby Objects for complex domain logic
* Use POROs for calculations, workflows, and transient state
* Give objects expressive interfaces that model the domain

```ruby
# Good - PORO for complex domain logic
class PricingCalculator
  def initialize(order)
    @order = order
    @rules = load_pricing_rules
  end
  
  def subtotal
    @order.line_items.sum(&:total)
  end
  
  def discount
    @rules.map { |rule| rule.apply(@order) }.sum
  end
  
  def tax
    TaxCalculator.new(@order.shipping_address).calculate(taxable_amount)
  end
  
  def total
    subtotal - discount + tax + shipping
  end
  
  private
  
  def taxable_amount
    subtotal - discount
  end
end

# Usage - clean interface
calculator = PricingCalculator.new(order)
order.update!(
  subtotal: calculator.subtotal,
  discount: calculator.discount,
  tax: calculator.tax,
  total: calculator.total
)

# Bad - shoving everything into ActiveRecord
class Order < ApplicationRecord
  def calculate_total
    # 200 lines of pricing logic mixed with persistence
  end
end

# Also bad - procedural service class
class PricingService
  def self.calculate(order)
    subtotal = 0
    order.line_items.each do |item|
      subtotal += item.quantity * item.price
    end
    
    discount = 0
    if order.coupon_code
      discount = CouponService.calculate_discount(order.coupon_code, subtotal)
    end
    
    tax = TaxService.calculate_tax(subtotal - discount, order.shipping_address)
    shipping = ShippingService.calculate_shipping(order)
    
    total = subtotal - discount + tax + shipping
    
    order.update!(
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total
    )
  end
end
# Procedural, not object-oriented
```

## Concerns For Shared Behavior
* Extract shared behavior into concerns
* Use for cross-cutting functionality
* Keep concerns focused on single responsibility

```ruby
# Good - focused concern
module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where.not(published_at: nil) }
    scope :draft, -> { where(published_at: nil) }
  end

  def published?
    published_at.present?
  end

  def publish!
    update!(published_at: Time.current) unless published?
  end

  def unpublish!
    update!(published_at: nil) if published?
  end
end

class Article < ApplicationRecord
  include Publishable
end

class Page < ApplicationRecord
  include Publishable
end
```

## Database-Backed Enums
* Use Rails enums for status fields
* Get free scopes and predicates
* Keep status logic in the model

```ruby
# Good - leveraging Rails enums
class Order < ApplicationRecord
  enum status: {
    pending: 0,
    processing: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4
  }

  def cancel!
    return if delivered? || cancelled?

    cancelled!
    refund_payment
  end

  def can_ship?
    processing? && inventory_available?
  end
end

# Automatic scopes and predicates
Order.pending
Order.shipped
order.pending?
order.shipped!

# Bad - string statuses with manual checks
class Order < ApplicationRecord
  STATUSES = %w[pending processing shipped delivered cancelled]

  def pending?
    status == 'pending'
  end

  def self.pending
    where(status: 'pending')
  end
end
```

## Vanilla Validations
* Use built-in Rails validations
* Custom validators for domain rules
* Keep validation close to data

```ruby
# Good - Rails validations with custom validators
class Account < ApplicationRecord
  RESERVED_SUBDOMAINS = %w[www app api admin]

  validates :email, presence: true, uniqueness: true
  validates :subdomain, presence: true, format: /\A[a-z0-9-]+\z/
  validate :subdomain_not_reserved

  private

  def subdomain_not_reserved
    return unless RESERVED_SUBDOMAINS.include?(subdomain)

    errors.add(:subdomain, 'is reserved')
  end
end

# Bad - validation in controller
class AccountsController < ApplicationController
  def create
    if params[:subdomain].match?(/[^a-z0-9-]/)
      flash[:error] = 'Invalid subdomain'
      render :new
      return
    end

    @account = Account.new(account_params)
    # Validation should be in model
  end
end
```