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