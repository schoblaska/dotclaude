# Rails Patterns

## Vanilla Rails Architecture
* Use Rails as designed without unnecessary abstraction layers
* Controllers directly interact with rich domain models
* Extract complexity through concerns and POROs, not service objects
* Let each layer handle its natural responsibilities

```ruby
# Good - direct model interaction
class ArticlesController < ApplicationController
  def publish
    @article = Article.find(params[:id])
    
    if @article.publish!
      redirect_to @article, notice: "Article published"
    else
      render :edit, alert: @article.errors.full_messages
    end
  end
end

class Article < ApplicationRecord
  def publish!
    return false unless publishable?
    
    transaction do
      self.published_at = Time.current
      self.status = :published
      save! && notify_subscribers
    end
  end
  
  private
  
  def publishable?
    valid? && draft? && author.can_publish?
  end
  
  def notify_subscribers
    subscribers.find_each { |s| ArticleMailer.published(s, self).deliver_later }
  end
end

# Bad - unnecessary service layer
class PublishArticleService
  def self.call(article, publisher)
    return false unless article.valid?
    return false unless article.draft?
    return false unless publisher.can_publish?
    
    article.published_at = Time.current
    article.status = :published
    
    if article.save
      NotificationService.notify_subscribers(article)
      true
    else
      false
    end
  end
end
```

## Bold Domain Language
* Use expressive, memorable method names that tell a story
* Choose formal, intentional terminology over generic terms
* Methods should read like business narratives
* Inject personality into your domain models

```ruby
# Good - bold, expressive language
class Subscription
  def terminate_with_prejudice!
    transaction do
      cancel_immediately
      revoke_all_access
      erect_tombstone
      incinerate_payment_methods
    end
  end
  
  def grant_clemency(days: 30)
    push_expiration(days.days.from_now)
    dispatch_reprieve_notice
  end
  
  private
  
  def erect_tombstone
    Tombstone.create!(
      subscription: self,
      epitaph: cancellation_reason,
      mourners: affected_users
    )
  end
end

class Document
  def ratify!
    self.ratified_at = Time.current
    seal_with_authority(current_user)
    promulgate_to_stakeholders
    save!
  end
end

# Bad - generic, forgettable naming
class Subscription
  def cancel
    self.status = 'cancelled'
    self.cancelled_at = Time.current
    remove_access
    delete_payment_methods
    save
  end
  
  def extend_trial(days)
    self.expires_at = days.days.from_now
    send_email
    save
  end
end
```

## Rich Domain Models
* Blend persistence and business logic naturally in Active Record models
* Models own their data and the operations on that data
* Use methods that read like natural language
* Handle complex operations without extracting to service objects

```ruby
# Good - rich model handling complex operations
class Order < ApplicationRecord
  has_many :line_items
  belongs_to :customer
  
  def submit!
    transaction do
      validate_inventory!
      calculate_pricing
      charge_payment
      self.submitted_at = Time.current
      save!
      dispatch_to_fulfillment
    end
  end
  
  def calculate_pricing
    self.subtotal = line_items.sum(&:total)
    self.discount = best_available_discount
    self.tax = TaxCalculator.for_address(shipping_address).calculate(taxable_amount)
    self.total = subtotal - discount + tax + shipping_cost
  end
  
  private
  
  def validate_inventory!
    out_of_stock = line_items.select { |item| !item.in_stock?(item.quantity) }
    raise OutOfStockError, out_of_stock if out_of_stock.any?
  end
  
  def charge_payment
    PaymentProcessor.charge(customer.payment_method, total)
  rescue PaymentError => e
    errors.add(:payment, e.message)
    raise ActiveRecord::Rollback
  end
  
  def dispatch_to_fulfillment
    FulfillmentJob.perform_later(self)
  end
end

# Bad - anemic model with service object
class Order < ApplicationRecord
  # Just data, no behavior
end

class OrderSubmissionService
  def initialize(order)
    @order = order
  end
  
  def submit
    return false unless validate_inventory
    
    calculate_pricing
    
    if charge_payment
      @order.submitted_at = Time.current
      @order.save
      dispatch_to_fulfillment
      true
    else
      false
    end
  end
  
  # ... lots of private methods ...
end
```

## Concerns For Domain Traits
* Use concerns to represent cohesive domain traits or "acts as" semantics
* Place model-wide concerns in `app/models/concerns/`
* Place model-specific concerns in `app/models/<model_name>/`
* Never use concerns as arbitrary code containers

```ruby
# Good - concern representing a genuine trait
# app/models/concerns/reviewable.rb
module Reviewable
  extend ActiveSupport::Concern
  
  included do
    has_many :reviews, as: :reviewable
    
    scope :highly_rated, -> { where("average_rating >= ?", 4.0) }
    scope :needs_moderation, -> { where(moderation_status: :pending) }
  end
  
  def approve!
    self.moderation_status = :approved
    self.approved_at = Time.current
    save! && notify_approval
  end
  
  def calculate_average_rating
    reviews.average(:rating) || 0
  end
  
  def reviewable_by?(user)
    user != author && user.has_purchased?(self)
  end
end

# app/models/user/authenticatable.rb
module User::Authenticatable
  extend ActiveSupport::Concern
  
  included do
    has_secure_password
    
    before_save :downcase_email
    after_update :revoke_sessions_if_password_changed
  end
  
  def authenticate_with_token(token)
    BCrypt::Password.new(remember_digest).is_password?(token)
  end
  
  def initiate_password_reset
    generate_reset_token
    dispatch_reset_instructions
  end
end

# Bad - concern as junk drawer
module UserStuff
  extend ActiveSupport::Concern
  
  def calculate_age
    ((Time.current - birthdate.to_time) / 1.year).floor
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def has_orders?
    orders.any?
  end
  
  # Random unrelated methods dumped together
end
```

## Database-Backed Enums
* Use Rails enums for status fields with rich behavior
* Get free scopes and predicates that read naturally
* Combine with state-specific logic in the model

```ruby
# Good - rich enum usage
class Shipment < ApplicationRecord
  enum status: {
    pending: 0,
    processing: 1,
    shipped: 2,
    in_transit: 3,
    delivered: 4,
    returned: 5,
    lost: 6
  }
  
  def advance_status!
    return false if delivered? || returned? || lost?
    
    next_status = self.class.statuses.keys[self.class.statuses[status] + 1]
    update!(
      status: next_status,
      "#{next_status}_at": Time.current
    )
    
    dispatch_status_notification
  end
  
  def mark_as_lost!
    return false unless can_be_lost?
    
    transaction do
      lost!
      initiate_insurance_claim
      notify_customer_of_loss
    end
  end
  
  private
  
  def can_be_lost?
    shipped? || in_transit?
  end
end

# Automatic scopes and predicates
Shipment.delivered
Shipment.in_transit
shipment.pending?
shipment.delivered!
```

## Query Objects As Scopes
* Use scopes for reusable, chainable query logic
* Compose scopes in controllers for specific needs
* Keep scopes focused on single responsibilities

```ruby
# Good - composable scopes
class Article < ApplicationRecord
  scope :published, -> { where.not(published_at: nil) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { where("created_at > ?", 2.weeks.ago) }
  scope :by_author, ->(author) { where(author: author) }
  scope :tagged_with, ->(tag) { joins(:tags).where(tags: { name: tag }) }
  scope :popular, -> { where("views_count > ?", 1000) }
  
  scope :for_homepage, -> { published.featured.recent.limit(5) }
end

class ArticlesController < ApplicationController
  def index
    @articles = Article.published.recent
    @articles = @articles.by_author(params[:author]) if params[:author]
    @articles = @articles.tagged_with(params[:tag]) if params[:tag]
    @articles = @articles.page(params[:page])
  end
end
```

## Models Enforce Invariants
* Models are responsible for their own consistency
* Use Active Record validations for data integrity
* Custom validators for domain-specific rules

```ruby
# Good - comprehensive domain validations
class Reservation < ApplicationRecord
  validate :start_before_end
  validate :no_double_booking
  validate :within_business_hours
  validate :minimum_duration
  
  before_validation :calculate_total_price
  
  private
  
  def start_before_end
    return unless start_time && end_time
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end
  
  def no_double_booking
    overlapping = Reservation
      .where(resource: resource)
      .where.not(id: id)
      .where("start_time < ? AND end_time > ?", end_time, start_time)
    
    errors.add(:base, "Resource is already booked") if overlapping.exists?
  end
  
  def within_business_hours
    errors.add(:start_time, "must be during business hours") unless resource.available_at?(start_time)
  end
  
  def minimum_duration
    return unless start_time && end_time
    
    duration = (end_time - start_time) / 1.hour
    errors.add(:base, "Minimum booking is 2 hours") if duration < 2
  end
  
  def calculate_total_price
    self.total_price = resource.hourly_rate * duration_in_hours
  end
end
```

## Callbacks Within Boundaries
* Use callbacks for internal state management
* Use explicit method calls for external side effects
* Keep callback chains shallow and visible

```ruby
# Good - callbacks for internal, explicit for external
class User < ApplicationRecord
  before_save :normalize_email
  before_create :generate_confirmation_token
  after_update :track_email_change, if: :saved_change_to_email?
  
  def confirm!
    transaction do
      self.confirmed_at = Time.current
      self.confirmation_token = nil
      save!
      
      # External effects - explicit
      grant_initial_credits
      subscribe_to_newsletter if opted_in?
      WelcomeMailer.confirmed(self).deliver_later
    end
  end
  
  private
  
  # Internal state - callbacks
  def normalize_email
    self.email = email.downcase.strip
  end
  
  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
  end
  
  def track_email_change
    self.email_change_history ||= []
    self.email_change_history << {
      from: email_before_last_save,
      to: email,
      changed_at: Time.current
    }
  end
  
  # External effects - explicit calls
  def grant_initial_credits
    credits.create!(amount: 100, reason: "Welcome bonus")
  end
  
  def subscribe_to_newsletter
    NewsletterSubscription.create!(email: email, user: self)
  end
end
```

## Domain Objects Beyond ActiveRecord
* Create POROs for complex calculations and workflows
* Use value objects for domain concepts
* Keep ActiveRecord for persistence, POROs for algorithms

```ruby
# Good - PORO for complex domain logic
class PriceQuote
  attr_reader :items, :customer, :valid_until
  
  def initialize(items:, customer:)
    @items = items
    @customer = customer
    @valid_until = 7.days.from_now
  end
  
  def total
    subtotal - discount + tax
  end
  
  def accept!
    Order.create!(
      customer: customer,
      line_items: items.map { |i| LineItem.from_quote_item(i) },
      total: total,
      quoted_price: total,
      accepted_at: Time.current
    )
  end
  
  private
  
  def subtotal
    @subtotal ||= items.sum { |item| item.quantity * item.unit_price }
  end
  
  def discount
    @discount ||= DiscountCalculator.new(customer, subtotal).calculate
  end
  
  def tax
    @tax ||= customer.tax_rate * (subtotal - discount)
  end
end

# Usage
quote = PriceQuote.new(items: cart_items, customer: current_user)
if params[:accept]
  order = quote.accept!
  redirect_to order
else
  render :show, locals: { quote: quote }
end
```

## Domain Cohesion Over Layer Separation
* Let each layer handle what it naturally owns
* Views make presentation decisions
* Controllers orchestrate requests
* Models enforce business rules

```ruby
# Good - each layer handles its concerns
class InvoicesController < ApplicationController
  def create
    @invoice = current_account.invoices.build(invoice_params)
    
    if @invoice.save
      @invoice.dispatch! if params[:send_now]
      redirect_to @invoice
    else
      render :new
    end
  end
end

class Invoice < ApplicationRecord
  def dispatch!
    return false if dispatched?
    
    transaction do
      generate_pdf
      self.dispatched_at = Time.current
      save!
      InvoiceMailer.dispatch(self).deliver_later
    end
  end
  
  def overdue?
    !paid? && due_date < Date.current
  end
  
  def payable?
    !paid? && !cancelled?
  end
end

# View handles presentation
# app/views/invoices/_invoice.html.erb
<div class="invoice <%= 'overdue' if invoice.overdue? %>">
  <% if invoice.payable? %>
    <%= button_to "Pay Now", pay_invoice_path(invoice), 
                  class: invoice.overdue? ? "btn-urgent" : "btn-primary" %>
  <% end %>
</div>
```