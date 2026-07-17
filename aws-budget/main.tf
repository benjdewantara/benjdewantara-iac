provider "aws" {
  profile = var.aws_profile_a
}

resource "aws_budgets_budget" "this" {
  budget_type = "COST"
  time_unit   = "MONTHLY"

  limit_amount = "111"
  limit_unit   = "USD"

  # planned_limit {
  #   amount     = "11"
  #   start_time = "2026-01-01_00:00"
  #   unit       = "USD"
  # }

  cost_types {
    include_credit = false
    include_refund = false
  }

  # auto_adjust_data {
  #   # auto_adjust_type = "FORECAST"
  #   # historical_options {
  #   #   budget_adjustment_period = 1
  #   # }
  # }
}
