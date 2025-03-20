output "main_role_arn" {
    value = aws_iam_role.main.arn
}

output "data" {
    value = {
        main = {
            org_id = data.aws_organizations_organization.main.id
        }
        other = {
            org_id = data.aws_organizations_organization.other.id
        }
    }
}