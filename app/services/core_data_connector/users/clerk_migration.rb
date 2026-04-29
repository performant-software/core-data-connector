if ENV['VITE_AUTH_PROVIDER'] == 'clerk'
  require 'clerk'
end

module CoreDataConnector
  module Users
    class ClerkMigration
      def run
        clerk = Clerk::SDK.new(secret_key: ENV.fetch('CLERK_SECRET_KEY'))

        organization_list = clerk.organizations.list(request: Clerk::Models::Operations::ListOrganizationsRequest.new)
        organizations = organization_list.organizations.data

        org_domains = Hash.new

        organizations.each do |org|
          domain_request = Clerk::Models::Operations::ListOrganizationDomainsRequest.new(organization_id: org.id)
          name = clerk.organization_domains.list(request: domain_request).organization_domains.data.first.name
          org_domains[name] = org.id
        end

        User.where(sso_id: nil).find_each do |user|
          begin
            sleep 2
            list_request = Clerk::Models::Operations::GetUserListRequest.new(email_address: [user.email])
            clerk_users = clerk.users.list(request: list_request)
            clerk_user = clerk_users.user_list.first

            is_new_user = false

            email_domain = user.email.split('@').last

            if clerk_user.nil?
              is_new_user = true
              first_name, last_name = user.split_name

              is_global_admin = email_domain == ENV['CLERK_MIGRATION_GLOBAL_ADMIN_DOMAIN']

              private_metadata = {}

              if is_global_admin
                private_metadata[:is_global_admin] = true
              end

              create_request = Clerk::Models::Operations::CreateUserRequest.new(
                email_address: [user.email],
                first_name: first_name,
                last_name: last_name,
                skip_password_requirement: true,
                private_metadata: private_metadata
              )

              response = clerk.users.create(request: create_request)
              clerk_user = response.user
              puts "#{user.email} created in Clerk"
            end

            org_id = org_domains[email_domain]

            if is_new_user
              needs_membership = true
            else
              membership_request = Clerk::Models::Operations::ListOrganizationMembershipsRequest.new(organization_id: org_id)
              memberships = clerk.organization_memberships.list(request: membership_request)
              needs_membership = !memberships.organization_memberships.data.any? { |m| m.organization.id == org_id }
            end

            if needs_membership
              if org_id
                org_member_request_body = {
                  user_id: clerk_user.id,
                  role: 'org:member'
                }
                clerk.organization_memberships.create(body: org_member_request_body, organization_id: org_id)
                puts "#{user.email} added to organization: #{org_id}"
              else
                org_create_request = Clerk::Models::Operations::CreateOrganizationRequest.new(
                  name: "#{user.name}'s Organization",
                  created_by: clerk_user.id
                )
                clerk.organizations.create(request: org_create_request)
                puts "#{user.email} created a personal organization"
              end
            end

            user.update!(sso_id: clerk_user.id)
          rescue StandardError => e
            puts "Error migrating user #{user.email}: #{e.message}"
          end
        end
      end

      def reset
        # This task exists to make development of the run method easier.
        # It will wipe all users from the Clerk instance and remove their SSO ID.

        clerk = Clerk::SDK.new(secret_key: ENV.fetch('CLERK_SECRET_KEY'))

        request = Clerk::Models::Operations::GetUserListRequest.new(
          limit: 200
        )

        users = clerk.users.list(request: request)

        users.user_list.each do |user|
          sleep 2
          clerk.users.delete(user_id: user.id)
          puts "Deleted user #{user.id} with email #{user.email_addresses.first.email_address}"
        end

        User.update_all(sso_id: nil)
        puts "Cleared sso_id for all users"
      end
    end
  end
end