require 'git'
require 'logger'
require 'pathname'
require 'net/https'

# https://www.mashape.com/vivekn/sentiment-3
sentimentURL = "TODO"

def buildSentimentURL(sentence)
    return sentimentURL
end

def getSentenceSentiment(sentence)
    url = buildSentimentURL(sentence)
    uri = URI(url)
    response = Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        http.request(request) # Net::HTTPResponse object returned, becomes the returned response
    end
    
    response.body 
end

def commitMessage(entry)
    entry.message
end

ARGV.each{|repo|
    fullpath = Pathname.new(repo)
    puts "Analyzing #{fullpath.realpath.to_s}"
    
    git = Git.open(repo, :log => Logger.new(STDOUT))

    # Indexes by user, date, and file
    entriesByUser = {}
    entriesByDate = {}
    entriesByFile = {}

    git.log.each{|entry|
        user = entry.author.name
        date = entry.date.strftime("%m-%d-%y")
        
        if entriesByUser[user] != nil
            entriesByUser[user] = []
        end 
        entriesByUser[user] << entry

        if entriesByDate[date] != nil
            entriesByDate[date] = []
        end
        entriesByDate[date] << entry

        puts entry.to_s
    }
}
