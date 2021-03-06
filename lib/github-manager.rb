require 'rubygems'
require 'github_api'
require 'logger'

$logger = Logger.new("github-manager.log")

class GithubManager
  attr_reader :client

  def initialize(organization, login, pass)
    @org    = organization
    @login  = login
    @client = Github.new(:login => login, :password => pass, :org => @org)
  end
  
  def create_repo(repo_name, description)
    @client.repos.create_repo({
      :org         => @org,
      :name        => repo_name,
      :description => description, 
      :private     => true,
    })
  end

  def delete_repo(repo_name)
    raise "Not yet implemented"
  end

  # type:
  #   all, owner, public, private, member. Default: all.
  def list_repos(type)
    @client.repos.list_repos({:org => @org, :type => type})
  end

  def create_team(team_name, repo_name, users)
    team = @client.orgs.create_team(@org, {
      :name => team_name,
      :permission => "push",
      :repo_names => ["#{@org}/#{repo_name}"]
    })
    users.each { |user|
      if valid_user?(user)
        @client.orgs.add_member(team.id, user)
      else
        $logger.warn("User: #{user} from Group: #{team_name} is invalid.")
      end
    }
  end

  def add_team_to_repo(team_id, repo_name)
    @client.orgs.add_team_repo(team_id, @org, repo_name)
  end

  def delete_team(team_name)
    team = @client.orgs.get_team(team_name)
    @client.orgs.delete_team(team.id)
  end

  def valid_user?(user_name)
    begin
      user = @client.users.get_user(user_name)
    rescue
      user = nil
    end
    user != nil
  end

end
