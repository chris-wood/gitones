require 'git'
require 'logger'
require 'pathname'

ARGV.each{|repo|
    
    fullpath = Pathname.new(repo)
    puts "Analyzing #{fullpath.realpath.to_s}"
    
    git = Git.open(repo, :log => Logger.new(STDOUT))

    puts git.log
}
