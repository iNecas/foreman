require 'integration_test_helper'

class OrgAdminIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @org1 = FactoryGirl.create(:organization)
    @org2 = FactoryGirl.create(:organization)
    @org3 = FactoryGirl.create(:organization)
    @loc1 = FactoryGirl.create(:location)
    @loc2 = FactoryGirl.create(:location)
    @loc3 = FactoryGirl.create(:location)
    @user = FactoryGirl.create(:user, :password => 'changeme', :mail => 'test@example.com', :organizations => [], :locations => [])

    # to have real Org admin role
    # TODO would be better as part of test setup, it's slow
    load File.join(Rails.root, '/db/seeds.d/03-permissions.rb')
    load File.join(Rails.root, '/db/seeds.d/03-roles.rb')
    @org_admin = Role.find_by_name('Organization admin')

    @org_admin_of_org1 = clone_role(@org_admin, @org1)
  end

  context "user is org admin of single org" do
    def setup
      @user.organizations << @org1
      @user.locations = [ @loc1, @loc2 ]
      @user.roles << @org_admin_of_org1
      @visible_domain = FactoryGirl.create(:domain, :organizations => [@org1], :locations => [@loc1])
      @invisible_domain_1 = FactoryGirl.create(:domain, :organizations => [@org2], :locations => [@loc1])
      @invisible_domain_2 = FactoryGirl.create(:domain, :organizations => [@org2], :locations => [@loc1])
      # invisible because of location
      @invisible_domain_3 = FactoryGirl.create(:domain, :organizations => [@org1], :locations => [@loc3])
      @invisible_domain_4 = FactoryGirl.create(:domain, :organizations => [@org1], :locations => [])
    end

    def test_org_admins_can_work_with_resources_in_their_organization
      login_user(@user.login, 'changeme')
      visit domains_path
      click_link 'Create Domain'

      assert_form_tab('Locations')
      assert_form_tab('Organizations')

      within('#domain_organization_ids') do
        assert page.has_content? @org1.name
        assert page.has_no_content? @org2.name
        assert page.has_no_content? @org3.name

        # current organization is selected
        within('option[selected="selected"]') do
          assert page.has_content? @org1.name
        end
      end

      within('#domain_location_ids') do
        assert page.has_content? @loc1.name
        assert page.has_content? @loc2.name
        assert page.has_content? @loc3.name
      end

      domain = FactoryGirl.build(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'
      location_selector = page.find('select#domain_location_ids')
      location_selector.select @loc1.name
      location_selector.select @loc2.name
      page.click_button 'Submit'

      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_link?(@visible_domain.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_3.name)
        assert page.has_no_content?(@invisible_domain_4.name)
      end
    end

    def test_org_admin_tries_to_create_domain_when_unselect_the_organization
      login_user(@user.login, 'changeme')
      visit new_domain_path

      domain = FactoryGirl.build(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'
      organization_selector = page.find('select#domain_organization_ids')
      organization_selector.unselect @org1.name

      location_selector = page.find('select#domain_location_ids')
      location_selector.select @loc1.name
      location_selector.select @loc2.name
      page.click_button 'Submit'

      created_domain = Domain.unscoped.find_by_name(domain.name)
      # sets the only organization anyway
      assert_equal [ @org1 ], created_domain.organizations
    end

    # This test would only make sense if we also had 8dcc90bea2, but that was not cherry-picked to 6.3
    #def test_org_admins_can_not_assign_location_which_they_do_not_belong_to
    #  login_user(@user.login, 'changeme')
    #  visit new_domain_path

    #  domain = FactoryGirl.build(:domain)
    #  page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'
    #  organization_selector = page.find('select#domain_organization_ids')
    #  organization_selector.unselect @org1.name

    #  location_selector = page.find('select#domain_location_ids')
    #  # once selection are driven by permissions only, this should not be possible
    #  location_selector.select @loc3.name
    #  page.click_button 'Submit'

    #  # this is partly buggy behavior based on fact user does not belong to location
    #  # but has view + assign locations permission, this test describe this behavior
    #  # which should change once org/loc selection is based on permissions entirely
    #  assert page.has_content?("don't have access to specified locations or organizations")
    #end
  end

  context "user is org admin of two organizations" do
    def setup
      @user.organizations = [ @org1, @org2 ]
      @user.locations = [ @loc1, @loc2 ]
      @org_admin_of_org2 = clone_role(@org_admin, @org2)
      @user.roles = [ @org_admin_of_org1, @org_admin_of_org2 ]
      @visible_domain_1 = FactoryGirl.create(:domain, :organizations => [@org1], :locations => [@loc1])
      @visible_domain_2 = FactoryGirl.create(:domain, :organizations => [@org2], :locations => [@loc1])
      @invisible_domain_1 = FactoryGirl.create(:domain, :organizations => [@org3], :locations => [@loc1])
      # invisible because of location
      @invisible_domain_2 = FactoryGirl.create(:domain, :organizations => [@org1], :locations => [@loc3])
    end

    def test_org_admins_can_work_with_resources_in_their_organization
      login_user(@user.login, 'changeme')
      visit domains_path
      click_link 'Create Domain'

      assert_form_tab('Locations')
      assert_form_tab('Organizations')

      within('#domain_organization_ids') do
        assert page.has_content? @org1.name
        assert page.has_content? @org2.name
        assert page.has_no_content? @org3.name

        # current context is any organization
        assert page.has_no_content?('option[selected="selected"]')
      end

      within('#domain_location_ids') do
        assert page.has_content? @loc1.name
        assert page.has_content? @loc2.name
        assert page.has_content? @loc3.name
      end

      domain = FactoryGirl.build(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'
      organization_selector = page.find('select#domain_organization_ids')
      organization_selector.select @org1.name
      organization_selector.select @org2.name

      location_selector = page.find('select#domain_location_ids')
      location_selector.select @loc1.name
      location_selector.select @loc2.name
      page.click_button 'Submit'

      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_link?(@visible_domain_1.name)
        assert page.has_link?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end

      select_organization(@org1.name)
      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_link?(@visible_domain_1.name)
        assert page.has_no_content?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end

      select_organization(@org2.name)
      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_no_content?(@visible_domain_1.name)
        assert page.has_link?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end
    end


    def test_org_admin_tries_to_create_resource_without_organization_selection
      login_user(@user.login, 'changeme')
      visit new_domain_path

      domain = FactoryGirl.build(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'

      location_selector = page.find('select#domain_location_ids')
      location_selector.select @loc1.name
      page.click_button 'Submit'

      # this does not work since 8130902db6953caca183d32b58e9703c15bb87d3 was not cherry-picked to 6.3, we only verify the page is still create domain
      # assert page.has_content?("Invalid organizations selection, you must select at least one of yours and have 'assign_organizations' permission")
      assert page.has_content?('Create Domain')
    end
  end

  context "user is org admin of two organizations through single role" do
    def setup
      @user.organizations = [ @org1, @org2 ]
      @user.locations = [ @loc1, @loc2 ]
      @org_admin_of_org_1_and_2 = clone_role(@org_admin, @org1, " and #{@org2.name}")
      @org_admin_of_org_1_and_2.organization_ids = [ @org1.id, @org2.id ]
      @org_admin_of_org_1_and_2.save # trigger filter inheritance

      @user.roles = [ @org_admin_of_org_1_and_2 ]
      @visible_domain_1 = FactoryGirl.create(:domain, :organizations => [@org1], :locations => [@loc1])
      @visible_domain_2 = FactoryGirl.create(:domain, :organizations => [@org2], :locations => [@loc1])
      @invisible_domain_1 = FactoryGirl.create(:domain, :organizations => [@org3], :locations => [@loc1])
      # invisible because of location
      @invisible_domain_2 = FactoryGirl.create(:domain, :organizations => [@org1], :locations => [@loc3])
    end

    def test_org_admins_of_two_orgs_can_work_with_resources_in_their_organizations
      login_user(@user.login, 'changeme')
      visit domains_path
      click_link 'Create Domain'

      assert_form_tab('Locations')
      assert_form_tab('Organizations')

      within('#domain_organization_ids') do
        assert page.has_content? @org1.name
        assert page.has_content? @org2.name
        assert page.has_no_content? @org3.name

        # current context is any organization
        assert page.has_no_content?('option[selected="selected"]')
      end

      within('#domain_location_ids') do
        assert page.has_content? @loc1.name
        assert page.has_content? @loc2.name
        assert page.has_content? @loc3.name
      end

      domain = FactoryGirl.build(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'
      organization_selector = page.find('select#domain_organization_ids')
      organization_selector.select @org1.name
      organization_selector.select @org2.name

      location_selector = page.find('select#domain_location_ids')
      location_selector.select @loc1.name
      location_selector.select @loc2.name
      page.click_button 'Submit'

      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_link?(@visible_domain_1.name)
        assert page.has_link?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end

      select_organization(@org1.name)
      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_link?(@visible_domain_1.name)
        assert page.has_no_content?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end

      select_organization(@org2.name)
      within "#domains_list" do
        assert page.has_link?(domain.name)
        assert page.has_no_content?(@visible_domain_1.name)
        assert page.has_link?(@visible_domain_2.name)
        assert page.has_no_content?(@invisible_domain_1.name)
        assert page.has_no_content?(@invisible_domain_2.name)
      end
    end
  end

  context "user is org admin of three organizations through single role but belongs to only two of them" do
    def setup
      @user.organizations = [ @org1, @org3 ]
      @user.locations = [ @loc1, @loc2 ]
      @org_admin_of_org_123 = clone_role(@org_admin, @org1, " and #{@org2.name} and #{@org3.name}")
      @org_admin_of_org_123.organization_ids = [ @org1.id, @org2.id, @org3.id ]
      @org_admin_of_org_123.save # trigger filter inheritance
      @user.roles = [ @org_admin_of_org_123 ]
      @visible_domain_1 = FactoryGirl.create(:domain, :organizations => [@org1], :locations => [@loc1])
      # visible through permissions, can't be switched to though
      @visible_domain_2 = FactoryGirl.create(:domain, :organizations => [@org2], :locations => [@loc1])
      @invisible_domain_1 = FactoryGirl.create(:domain, :organizations => [@org3], :locations => [@loc1])
      # invisible because of location
      @invisible_domain_2 = FactoryGirl.create(:domain, :organizations => [@org1], :locations => [@loc3])
    end

    # this test illustrate the inconsistency results where user can assign resource to org but he/she can't
    # switch to that org context so after assignment, the resource is not visible, assign_organizations defines
    # what organizations can be assigned
    def test_org_admins_can_assign_resources_to_both_orgs_but_cant_switch_to_its_context
      login_user(@user.login, 'changeme')
      visit domains_path
      click_link 'Create Domain'

      assert_form_tab('Locations')
      assert_form_tab('Organizations')

      within('#domain_organization_ids') do
        assert page.has_content? @org1.name
        assert page.has_content? @org2.name
        assert page.has_content? @org3.name

        # current context is any organization
        assert page.has_no_content?('option[selected="selected"]')
      end

      within('#domain_location_ids') do
        assert page.has_content? @loc1.name
        assert page.has_content? @loc2.name
        assert page.has_content? @loc3.name
      end

      domain = FactoryGirl.build(:domain)
      page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'

      location_selector = page.find('select#domain_location_ids')
      location_selector.select @loc1.name
      location_selector.select @loc2.name

      # This part does not work since 8dcc90bea2 was not cherry-picked to 6.3
      # organization_selector = page.find('select#domain_organization_ids')
      # # organization_selector.select @org1.name
      # organization_selector.select @org2.name
      # page.click_button 'Submit'

      # # choosing only org that user does not belong to is forbidden
      # assert page.has_content?("You don't have permission create_domains with attributes that you have specified or you don't have access to specified locations or organizations")

      # with org1 which user belongs to, submit passes but the organization selection is limited to user's list
      organization_selector = page.find('select#domain_organization_ids')
      organization_selector.select @org1.name
      page.click_button 'Submit'

      within "#domains_list" do
        assert page.has_link?(domain.name)
      end

      select_organization(@org3.name)
      within "#domains_list" do
        assert page.has_no_content?(domain.name)
      end

      refute_available_organization(@org2.name)

      select_organization(@org1.name)
      within "#domains_list" do
        assert page.has_link?(domain.name)
      end

      within "#domains_list" do
        page.click_link domain.name
      end
    end
  end

  context "user is org admin of two organizations but is not assigned to any organization" do
    def setup
      @user.organizations = [ ]
      @user.locations = [ @loc1, @loc2 ]
      @org_admin_of_org2 = clone_role(@org_admin, @org2)
      @user.roles = [ @org_admin_of_org1, @org_admin_of_org2 ]
      @invisible_domain_1 = FactoryGirl.create(:domain, :organizations => [@org1], :locations => [@loc1])
    end

    # this test does not work because 8dcc90bea2 was not cherry-picked to 6.3
    # this test illustrate the non-user without any organization assigned, they can't list or create anything
    # but because of restrictions coming both from Taxonomix and Authorizable. Taxonomix prevents listing while
    # Authorizable prevents creation. The information leaks through form, thanks to assign_organizations, names
    # of organizations in form are visible
    #def test_org_admins_can_assign_resources_to_both_orgs_but_cant_switch_to_its_context
    #  login_user(@user.login, 'changeme')
    #  visit domains_path

    #  assert page.has_no_content?(@invisible_domain_1.name)
    #  refute_available_organization(@org1.name)
    #  refute_available_organization(@org2.name)

    #  click_link 'Create Domain'

    #  assert_form_tab('Locations')
    #  assert_form_tab('Organizations')

    #  within('#domain_organization_ids') do
    #    assert page.has_content? @org1.name
    #    assert page.has_content? @org2.name
    #  end

    #  domain = FactoryGirl.build(:domain)
    #  page.fill_in 'domain[name]', :with => domain.name, :id => 'domain_name'

    #  location_selector = page.find('select#domain_location_ids')
    #  location_selector.select @loc1.name
    #  location_selector.select @loc2.name

    #  organization_selector = page.find('select#domain_organization_ids')
    #  organization_selector.select @org1.name
    #  organization_selector.select @org2.name
    #  page.click_button 'Submit'

    #  # choosing only org that user does not belong to is forbidden
    #  assert page.has_content?("You don't have permission create_domains with attributes that you have specified or you don't have access to specified locations or organizations")

    #  # with org1 which user belongs to, submit passes but the organization selection is limited to user's list
    #  organization_selector = page.find('select#domain_organization_ids')
    #  organization_selector.unselect @org1.name
    #  organization_selector.unselect @org2.name
    #  page.click_button 'Submit'

    #  # can't create in any context either
    #  assert page.has_content?("You don't have permission create_domains with attributes that you have specified or you don't have access to specified locations or organizations")
    #end
  end

  def clone_role(original, org, suffix = '')
    new_role = original.clone
    new_role.name = "#{original.name} of #{org.name}#{suffix}"
    new_role.builtin = 0
    new_role.organization_ids = [org.id]
    new_role.save!
    new_role
  end
end
