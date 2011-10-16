module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'

    when /^the login\s+page$/
      '/en/login'

    when /^the logout\s+page$/
      '/en/logout'
      
    when /^the account\s+page$/
      '/en/account'
      
    when /^the edit page for the "([^\/]+)\/(\d+\.\d+)" expense created on (\d{4}-\d{2}-\d{2}) for user (\S+)$/
      expense = Expense.find(:first, :conditions => { :label => $1, :amount => $2, :spent_on => $3, :user_id => User.find_by_username($4).id })
      raise "No such expense" unless expense
      "/en/expenses/#{expense.id}/edit"
      
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym, :locale => 'en')
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
