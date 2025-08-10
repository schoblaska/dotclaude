# PR Feedback

Incorporate pull request review feedback systematically and collaboratively.

## Usage
Use this command when you're on a branch with an open PR that has review feedback to address. Claude will automatically detect the PR associated with your current branch.

## Process

1. **Auto-detect and fetch PR**
   - Get current branch name
   - Find associated PR on GitHub
   - Retrieve the pull request details
   - Read ALL review comments - both top-level reviews and individual line comments
   - Fetch the PR diff to understand the changes

2. **Create comprehensive TODO list**
   - Create a TODO list item for EACH review comment and thread
   - Include redundant/overlapping items - enumerate everything explicitly
   - Organize items in logical order for processing

3. **Process feedback iteratively**
   - Work through items one-by-one
   - For each item:
     - Mark as in_progress
     - Discuss the feedback with user
     - Collaborate on the correction (Claude drives implementation, human + feedback navigate)
     - Make the changes
     - Create a commit for the fix
     - Mark as completed
   - When multiple items can be addressed with one change, confirm with user first

4. **Verify completion**
   - Ensure all TODO items are addressed
   - Run any relevant tests or checks
   - Prepare summary of changes made

## Example
```
/pr-feedback
```

This will find the PR for your current branch and guide you through addressing all feedback systematically.