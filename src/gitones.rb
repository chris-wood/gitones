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

    numEntries = git.log.size
    for index in 0..(numEntries - 1)
        entry = git.log[index]
        
        user = entry.author.name
        date = entry.date.strftime("%m-%d-%y")
        diffStats = git.diff(entry, git.log[index + 1]).stats
        touchedFiles = diffStats[:files]
        
        if entriesByUser[user] == nil
            entriesByUser[user] = []
        end 
        entriesByUser[user] << entry

        if entriesByDate[date] == nil
            entriesByDate[date] = []
        end
        entriesByDate[date] << entry

        touchedFiles.each{|fileName, value|
            if entriesByFile[fileName] == nil
                entriesByFile[fileName] = []
            end
            entriesByFile[fileName] << entry
        }

        # puts entry.to_s
    end

    puts "Indexes..."
    puts entriesByUser.to_s
    puts entriesByDate.to_s
    puts entriesByFile.to_s
}
