# Rails Guidelines

## Rich Domain Objects Over Service Objects
* Put business logic in models that own the data
* Use methods that read like natural language
* Avoid service objects for model-specific operations
* Models handle their own persistence and validation

```ruby
# Good - domain method
class Item < ActiveRecord::Base
  def activate!
    self.active = true
    self.activated_at = Time.current
    notify_watchers
    save!
  end
end

item.activate!

# Bad - procedural service
class ItemActivationService
  def activate(item)
    item.active = true
    item.activated_at = Time.current
    NotificationService.new(item).notify
    item.save!
  end
end

ItemActivationService.new.activate(item)
```