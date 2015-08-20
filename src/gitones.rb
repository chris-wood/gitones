require 'git'
require 'logger'
require 'indico'
require 'plotly'
require 'pathname'
require 'net/https'

# https://www.mashape.com/vivekn/sentiment-3
sentimentURL = "TODO"
Indico.api_key = File.read("indico.key")

def buildSentimentURL(sentence)
    return sentimentURL
end

def gnuplot(commands)
    IO.popen("gnuplot", "w") {|io| io.puts commands}
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

def generateGnuLineGraph(data, value)


    commands =
      %Q(
         set terminal png
         set output "curves.png"
         plot [-10:10] sin(x),atan(x),cos(atan(x))
        )
    gnuplot(commands)

    # set multiplot
    # plot 'file.csv' using 1:2 with lines
    # plot 'file.csv' using 1:3 with lines
    # unset multiplot
end

def generatePlotlyLineGraph(data, value)
    # for each key in data, compute the average value (by calling value method -- commit.send(value))
    # 0

    plotly = PlotLy.new('caw4567', File.read("plotly.key"))
    data = {
      x: ['2013-10-04 22:23:00', '2013-11-04 22:23:00', '2013-12-04 22:23:00'],
      y: [1, 3, 6]
    }

    args = {
      filename: 'ruby_test_time_series',
      fileopt: 'overwrite',
      style: { type: 'scatter' },
      layout: {
        title: 'Ruby API Time Series Demo'
      },
      world_readable: true
    }

    plotly.plot(data, args) do |response|
      puts response['url']
    end
end

class Commit

    attr_accessor :sentiment # double
    attr_accessor :political # hash

    attr_accessor :stats # hash as below
    # {:total=>{:insertions=>0, :deletions=>13, :lines=>13, :files=>1},
    # :files=>{"src/gitones.rb"=>{:insertions=>0, :deletions=>13}}}

    def initialize(entry, stats)
        @entry = entry
        @stats = stats
        # @sentiment = Indico.sentiment(entry.message)
        @sentiment = 0.5
        # @political = Indico.political(entry.message)
        @political = {"Libertarian" => 0.5}
    end

    def message
        @entry.message
    end

    def author
        @entry.author
    end

    def date
        @entry.date
    end

    def additions
        @stats[:total][:insertions]
    end

    def deletions
        @stats[:total][:deletions]
    end

    def numberOfLinesChanged
        @stats[:total][:lines]
    end

    def numberOfFilesTouched
        @stats[:total][:files]
    end

    def howLibertarian
        return @political["Libertarian"]
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

        user = entry.author.name
        date = entry.date.strftime("%-m-%-d-%Y") # - means no padding
        diff = git.diff(entry, git.log[index + 1])
        diffStats = diff.stats
        touchedFiles = diffStats[:files]

        commit = Commit.new(entry, diffStats)
        # puts commit.message
        # puts commit.sentiment
        # puts commit.political

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

    # prepare the overall plot data
    fout = File.open("overall.csv", "w")
    entriesByDate.each{|data, commits|
        add = commits[0].stats[:total][:insertions]
        del = commits[0].stats[:total][:deletions]
        lines = commits[0].stats[:total][:lines]
        files = commits[0].stats[:total][:files]
        sentiment = commits[0].sentiment
        lib = commits[0].howLibertarian

        csvcontents = [date.to_s, add, del, lines, files, sentiment, lib]
        csvline = csvcontents.join(",")

        puts date
        fout.puts(csvline)
    }
    fout.close

    # prepare the per-file plot data
    entriesByFile.each{|file, commits|

        # TODO: canonical the file

        fout = File.open(file.to_s + ".csv")

        commits.each{|commit|
            add = commits[0].stats[:total][:insertions]
            del = commits[0].stats[:total][:deletions]
            lines = commits[0].stats[:total][:lines]
            files = commits[0].stats[:total][:files]
            sentiment = commits[0].sentiment
            lib = commits[0].howLibertarian

            csvcontents = [date.to_s, add, del, lines, files, sentiment, lib]
            csvline = csvcontents.join(",")

            puts date
            fout.puts(csvline)
        }

        fout.close
    }

    # prepare the per-user plot data
    entriesByFile.each{|user, commits|
        fout = File.open(user.to_s + ".csv")

        commits.each{|commit|
            add = commits[0].stats[:total][:insertions]
            del = commits[0].stats[:total][:deletions]
            lines = commits[0].stats[:total][:lines]
            files = commits[0].stats[:total][:files]
            sentiment = commits[0].sentiment
            lib = commits[0].howLibertarian

            csvcontents = [date.to_s, add, del, lines, files, sentiment, lib]
            csvline = csvcontents.join(",")

            puts date
            fout.puts(csvline)
        }

        fout.close
    }
}
