terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5.0.0"
    }
  }
}

provider "github" {
  token = "placeholder" #! As autograding provides TOKEN , I used placeholder here. otherwise I'd use env variable to securely run the process!
}

# Collaborator Configuration
resource "github_repository_collaborator" "collaborator" {
  repository = "github-terraform-task-Abra7am"
  username   = "softservedata"
  permission = "push"
}

# Default Branch Configuration
resource "github_branch_default" "develop_default" {
  repository = "github-terraform-task-Abra7am"
  branch     = "develop"
}

# Branch Protection for 'main'
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

# Branch Protection for 'develop'
resource "github_branch_protection" "develop_protection" {
  repository_id = "github-terraform-task-Abra7am"
  pattern       = "develop"

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    required_approving_review_count = 2
  }
}

# CODEOWNERS for 'main' Branch
resource "github_repository_file" "codeowners" {
  repository     = "github-terraform-task-Abra7am"
  file           = ".github/CODEOWNERS"
  content        = "* @softservedata"
  commit_message = "Add CODEOWNERS file"
}

# Pull Request Template
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

# Deploy Key
resource "github_repository_deploy_key" "deploy_key" {
  repository = "github-terraform-task-Abra7am"
  title      = "DEPLOY_KEY"
  key        = file("deploy_key.pub")
  read_only  = false
}

# Webhook for Discord Notifications
resource "github_repository_webhook" "discord_webhook" {
  repository = "github-terraform-task-Abra7am"
  events     = ["pull_request"]
  configuration {
    url          = "https://discord.com/api/webhooks/1317118903465545760/z17XkRsumqlrxUgKYQUNKEwWxC__tqC1KB2mi09KZwwFxZNxqzBAXh4N4AF5LWvM4Dap"
    content_type = "json"
  }
}

# GitHub Actions Secret for PAT
resource "github_actions_secret" "pat" {
  repository      = "github-terraform-task-Abra7am"
  secret_name     = "PAT"
  plaintext_value = "placeholder" #! As autograding provides TOKEN , I used placeholder here. otherwise I'd use env variable to securely run the process!
}
