# RSpec Patterns

This guide outlines best practices for writing tests in Ruby, with a focus on RSpec. The principles here prioritize clarity, maintainability, and tests that provide meaningful feedback when they fail.

## Core Testing Philosophy

* Good tests tell you something specific when they fail - they pinpoint what broke and why
* Tests should be readable as documentation of intended behavior
* Each test should have one clear reason to fail
* Prefer clarity over cleverness - your future self will thank you
* Fast feedback loops are essential - optimize for speed without sacrificing clarity

## Test Structure

### Keep Tests Small and Focused

* Each test should verify one specific behavior
* If a test needs multiple assertions, they should all relate to the same behavior
* Avoid testing implementation details - focus on observable behavior
* When a test fails, it should be immediately clear what functionality is broken

### Use Consistent Structure

* Follow the Arrange-Act-Assert (AAA) pattern consistently
* Keep each phase visually distinct with whitespace
* Minimize logic in tests - no conditionals, loops, or complex calculations
* If you need helper methods, make them descriptive and single-purpose

```ruby
it "calculates the total with tax" do
  # Arrange
  order = Order.new(subtotal: 100)

  # Act
  total = order.total_with_tax

  # Assert
  expect(total).to eq(110)
end
```

## RSpec Best Practices

### Describe and Context Blocks

* Use `describe` for grouping tests by method or feature
* Use `context` sparingly for different scenarios that share some common starting state
* Avoid deep nesting: Maximum nesting depth should be 2 levels under the top-level RSpec.describe
* Each context should represent a meaningful variation in behavior

```ruby
# Good - flat and readable
RSpec.describe Order do
  describe "#total" do
    it "returns the sum of line items" do
      # test
    end

    context "with a discount code" do
      # setup for discount code

      it "applies the discount to the total" do
        # test
      end
    end
  end
end

# Bad - deeply nested and hard to follow
RSpec.describe Order do
  describe "#total" do
    context "with items" do
      context "with discount" do
        context "when discount is percentage" do
          context "when percentage is valid" do
            # Too deep!
          end
        end
      end
    end
  end
end
```

### Test Descriptions

* Write descriptions that read as complete sentences with the subject
* Be specific about the expected behavior
* Avoid redundant words like "should" - RSpec already implies this
* Make failure messages immediately understandable

```ruby
# Good
it "returns the user's full name" do
  # test
end

it "raises an error when the email is invalid" do
  # test
end

# Bad
it "should work" do
  # test
end

it "handles the thing" do
  # test
end
```

## Test Doubles and Mocking

### Use Test Doubles Judiciously

* Mock external dependencies (APIs, file systems, databases in unit tests)
* Don't mock objects you own unless there's a compelling reason
* Prefer dependency injection over stubbing class methods
* Use verifying doubles when available to catch interface changes

### Prefer Spy-like Patterns Over Traditional Mocks

* Use `allow` with `have_received` to maintain arrange-act-assert pattern
* Instance doubles with `allow` provide both type safety and spy-like behavior
* Verification happens after the action, making tests more readable
* Expectations are explicit and appear where assertions belong

```ruby
# Good - instance double with spy-like verification
it "sends a notification email" do
  mailer = instance_double(Mailer, send_order_confirmation: nil)
  service = OrderService.new(mailer:)

  service.complete_order(order)

  expect(mailer).to have_received(:send_order_confirmation).with(order)
end

# Less ideal - traditional mock with expectations set upfront
it "sends a notification email" do
  mailer = double("mailer")
  expect(mailer).to receive(:send_order_confirmation).with(order)
  service = OrderService.new(mailer:)

  service.complete_order(order)
end
```

### Avoid Over-Mocking

* If you're mocking everything, your design might be too coupled
* Consider using real objects when they're simple and fast
* Use integration tests to verify the actual interaction between components
* Remember: mocks don't prove your code works, only that it calls things

## Factory and Fixture Best Practices

### Keep Factories Simple

* Factories should create valid objects with minimal attributes
* Use traits for variations instead of complex factory logic
* Avoid callbacks in factories unless absolutely necessary
* Don't create associated objects unless the test needs them

```ruby
# Good
factory :user do
  email { "user@example.com" }
  name { "Jane Doe" }

  trait :admin do
    role { "admin" }
  end
end

# Bad
factory :user do
  email { "user@example.com" }
  name { "Jane Doe" }
  after(:create) do |user|
    create_list(:post, 5, user: user)
    create(:profile, user: user)
    # Too much automatic setup
  end
end
```

## Integration vs Unit Tests

### Maintain Separate Test Suites

* Unit tests: Fast, isolated, test single components
* Integration tests: Slower, test component interactions
* System tests: Full stack, test user workflows
* Each suite has different purposes - don't try to make one do everything

### Unit Test Guidelines

* Test domain logic in complete isolation
* Mock external dependencies
* Should run in milliseconds
* Focus on edge cases and error conditions

### Integration Test Guidelines

* Test the interaction between real components
* Use the database and real services where practical
* Focus on happy paths and critical user journeys
* Acceptable to be slower but should still be reasonably fast

## Performance and Maintainability

### Keep Tests Fast

* Avoid unnecessary database hits - use `build` instead of `create` when possible
* Don't load more data than the test needs
* Use `let` and `let!` appropriately - lazy vs eager loading
* Consider using database transactions for cleanup

### Make Tests Resilient

* Don't rely on specific IDs or ordering unless testing that behavior
* Avoid time-dependent tests or use time helpers
* Clean up after tests - don't leave state that affects other tests
* Make tests independent - they should pass in any order

```ruby
# Good - time-independent
it "marks the order as expired" do
  travel_to Time.current do
    order = create(:order, expires_at: 1.hour.ago)
    expect(order).to be_expired
  end
end

# Bad - will fail at certain times
it "marks the order as expired" do
  order = create(:order, expires_at: Time.current - 1.hour)
  expect(order).to be_expired
end
```

## Common Anti-Patterns to Avoid

### Mystery Guests

* All test data should be visible in the test
* Avoid relying on fixtures or seeds that aren't obvious
* If using shared contexts, make them explicit

### Excessive DRY

* Some repetition in tests is okay if it improves clarity
* Don't extract everything into helper methods
* Each test should tell its complete story

### Testing Implementation

* Test behavior, not implementation
* Don't test private methods directly
* Focus on inputs and outputs, not internal state
* If you need to test private methods, they might belong in another class

### Unclear Failures

* When a test fails, the reason should be immediately obvious
* Use custom matchers or failure messages when needed
* Avoid generic assertions that don't indicate what went wrong

```ruby
# Good - clear failure message
expect(user.role).to eq("admin"),
  "Expected user to be promoted to admin after three years"

# Bad - unclear what went wrong
expect(result).to be_truthy
```

## Test Organization

### File Structure

* Mirror your application structure in your test directories
* Keep related tests together
* Use consistent naming conventions
* Separate unit, integration, and system tests clearly

### Shared Examples

* Use shared examples for common behavior
* Keep them focused and well-documented
* Don't overuse - sometimes duplication is clearer
* Make sure they're discoverable by other developers

```ruby
# Good - reusable and clear
shared_examples "a searchable model" do
  it "finds records by name" do
    record = create(described_class.name.underscore, name: "Test")
    expect(described_class.search("Test")).to include(record)
  end
end

describe Product do
  it_behaves_like "a searchable model"
end
```

## Running Tests

### Continuous Integration

* Tests should be deterministic - same result every time
* Avoid flaky tests - fix them immediately when found
* Track test suite performance over time
* Run tests in parallel when possible

### Local Development

* Be able to run single tests quickly
* Use guard or similar for automatic test running
* Keep test output clean and informative
* Make it easy for new developers to run tests

## Key Principles Summary

* Tests are documentation - write them for humans
* Each test should have one clear reason to fail
* Fast tests lead to fast feedback loops
* Isolation and integration tests serve different purposes
* Don't mock what you don't own
* Test behavior, not implementation
* Keep test structure consistent and predictable
* Fix flaky tests immediately
* Some repetition is better than unclear abstraction
* When a test fails, it should tell you exactly what's wrong