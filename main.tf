terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5.0.0"
    }
  }
}

# Provider Configuration
provider "github" {
  token = "placeholder" # Autograding system will replace this with the actual token
}

# Adding SoftServedata as Collaborator
resource "github_repository_collaborator" "collaborator" {
  repository = "github-terraform-task-Abra7am"
  username   = "softservedata"
  permission = "push"
}

# Setting Default Branch to 'develop'
resource "github_branch_default" "develop_default" {
  repository = "github-terraform-task-Abra7am"
  branch     = "develop"
}

# Protect 'main' Branch
resource "github_branch_protection" "main_protection" {
  repository_id = "github-terraform-task-Abra7am"
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
  repository_id = "github-terraform-task-Abra7am"
  pattern       = "develop"

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    require_code_owner_reviews      = false
    required_approving_review_count = 2
  }
}

# Add CODEOWNERS File
resource "github_repository_file" "codeowners" {
  repository     = "github-terraform-task-Abra7am"
  file           = ".github/CODEOWNERS"
  content        = "* @softservedata"
  commit_message = "Add CODEOWNERS file"
}

# Add Pull Request Template
resource "github_repository_file" "pr_template" {
  repository     = "github-terraform-task-Abra7am"
  file           = ".github/pull_request_template.md"
  content        = <<EOF
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
  repository = "github-terraform-task-Abra7am"
  title      = "DEPLOY_KEY"
  key        = file("deploy_key.pub")
  read_only  = false
}

# Add Webhook for Discord Notifications
resource "github_repository_webhook" "discord_webhook" {
  repository = "github-terraform-task-Abra7am"
  events     = ["pull_request"]
  configuration {
    url          = "https://discord.com/api/webhooks/your-webhook-url"
    content_type = "json"
  }
}

# Add Personal Access Token (PAT) as GitHub Actions Secret
resource "github_actions_secret" "pat" {
  repository      = "github-terraform-task-Abra7am"
  secret_name     = "PAT"
  plaintext_value = "placeholder" # Autograding system will replace this with the actual token
}
