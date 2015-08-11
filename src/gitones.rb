require 'git'
require 'logger'
require 'indico'
require 'plotly'
require 'pathname'
require 'net/https'

# https://www.mashape.com/vivekn/sentiment-3
sentimentURL = "TODO"
Indico.api_key = File.read("indico.key")
plotly = PlotLy.new('caw4567', File.read("plotly.key")

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

class Commit
    @sentiment = 0.0
    @political = {}

    def initialize(entry)
        @entry = entry
        @sentiment = Indico.sentiment(entry.message)
        @political = Indico.political(entry.message)
    end

    def message
        @entry.message
    end

    def sentiment
        @sentiment
    end

    def political
        @political
    end

    def author
        @entry.author
    end

    def date
        @entry.date
    end
end

ARGV.each{|repo|
    fullpath = Pathname.new(repo)
    puts "Analyzing #{fullpath.realpath.to_s}"
    
    # git = Git.open(repo, :log => Logger.new(STDOUT))
    git = Git.open(repo)

    # Indexes by user, date, and file
    entriesByUser = {}
    entriesByDate = {}
    entriesByFile = {}

    numEntries = git.log.size
    for index in 0..(numEntries - 1)
        entry = git.log[index]

        commit = Commit.new(entry)
        puts commit.message
        puts commit.sentiment
        puts commit.political
        
        user = commit.author.name
        date = commit.date.strftime("%m-%d-%y")
        diffStats = git.diff(entry, git.log[index + 1]).stats
        touchedFiles = diffStats[:files]
        
        if entriesByUser[user] == nil
            entriesByUser[user] = []
        end 
        entriesByUser[user] << commit

        if entriesByDate[date] == nil
            entriesByDate[date] = []
        end
        entriesByDate[date] << commit

        touchedFiles.each{|fileName, value|
            if entriesByFile[fileName] == nil
                entriesByFile[fileName] = []
            end
            entriesByFile[fileName] << commit
        }
    end

    # puts "Indexes..."
    # puts entriesByUser.to_s
    # puts entriesByDate.to_s
    # puts entriesByFile.to_s
}
