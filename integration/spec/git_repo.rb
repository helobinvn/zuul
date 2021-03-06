require 'git'

# Class for manipulating git repository
class GitRepo
  def initialize(host, port, user, repo, email = nil)
    @git = clone_repo(host, port, user, repo)
    @git.config('user.email', email) unless email.nil?
    @git_dir = @git.dir.path
  end

  attr_reader :git

  def clone_repo(host, port, user, repo)
    FileUtils.rm_rf repo
    Git.clone("ssh://#{user}@#{host}:#{port}/#{repo}", repo)
  end

  def create_test_commit(filename)
    rand_string = rand(36**6).to_s(36)
    new_file = File.join(@git_dir, filename)
    File.open(new_file, 'w') { |f| f.write(rand_string) }
    @git.add(new_file)
    commit_msg = "Add content to #{filename} - #{rand_string}"
    @git.commit(commit_msg)
  end

  def create_test_branch(test_branch, target_branch)
    @git.branch(test_branch).checkout
    @git.reset_hard("origin/#{target_branch}")
    test_branch
  end

  def parse_change_number(string)
    string.lines.grep(%r{^remote: *\S+/(\d+) +.*}) \
      { Regexp.last_match(1) } [0]
  end

  private :clone_repo, :parse_change_number
end
