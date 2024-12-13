provider "github" {
  token = env.TERRAFOM_TASK_TOKEN #! To run Terraform securly, I stored my TOKEN in secrets and utilized it with ENV.
}

# GitHub Repository Configuration
resource "github_repository" "repo" {
  name        = "github-terraform-task-Abra7am" #! My TASK repo!
  description = "Repository managed by Terraform"
  private     = true
}

# Adding SoftServedata as Collaborator 
resource "github_repository_collaborator" "collaborator" {
  repository = github_repository.repo.name
  username   = "softservedata"
  permission = "push"
}

# Setting Default Branch to 'develop'
resource "github_branch_default" "develop_default" {
  repository = github_repository.repo.name
  branch     = "develop"
}

# Protect 'main' Branch
resource "github_branch_protection" "main_protection" {
  repository_id = github_repository.repo.node_id
  pattern       = "main"

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }

  enforce_admins = true
}

# Protect 'develop' Branch
resource "github_branch_protection" "develop_protection" {
  repository_id = github_repository.repo.node_id
  pattern       = "develop"

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    require_code_owner_reviews      = false
    required_approving_review_count = 2
  }
}

# Add CODEOWNERS File
resource "github_repository_file" "codeowners" {
  repository    = github_repository.repo.name
  file          = ".github/CODEOWNERS"
  content       = "* @softservedata"
  commit_message = "Add CODEOWNERS file"
}

# Add Pull Request Template
resource "github_repository_file" "pr_template" {
  repository    = github_repository.repo.name
  file          = ".github/pull_request_template.md"
  content       = <<EOF
Describe your changes
Issue ticket number and link

Checklist before requesting a review:
- [ ] I have performed a self-review of my code
- [ ] If it is a core feature, I have added thorough tests
- [ ] Do we need to implement analytics?
- [ ] Will this be part of a product update? If yes, please write one phrase about this update
EOF
  commit_message = "Add pull request template"
}

# Add Deploy Key
resource "github_repository_deploy_key" "deploy_key" {
  repository    = github_repository.repo.name
  title         = "DEPLOY_KEY"
  key           = file("deploy_key.pub")
  read_only     = true
}

# Add Webhook for Discord Notifications
resource "github_repository_webhook" "discord_webhook" {
  repository = github_repository.repo.name
  events     = ["pull_request"]
  configuration {
    url          = "https://discord.com/api/webhooks/1317118903465545760/z17XkRsumqlrxUgKYQUNKEwWxC__tqC1KB2mi09KZwwFxZNxqzBAXh4N4AF5LWvM4Dap" 
    content_type = "json"
  }
}

# Add Personal Access Token (PAT) as GitHub Actions Secret
resource "github_actions_secret" "pat" {
  repository    = github_repository.repo.name
  secret_name   = "PAT"
  plaintext_value = env.TERRAFOM_TASK_TOKEN #! I used the same variable for both secrets and ENV!
}
