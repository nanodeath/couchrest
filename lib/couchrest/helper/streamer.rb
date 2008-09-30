module CouchRest
  class Streamer
    attr_accessor :db
    def initialize db
      @db = db
    end
    
    # Stream a view, yielding one row at a time. Shells out to <tt>curl</tt> to keep RAM usage low when you have millions of rows.
    def view name, params = nil
      urlst = /^_/.match(name) ? "#{@db.root}/#{name}" : "#{@db.root}/_view/#{name}"
      url = CouchRest.paramify_url urlst, params
      IO.popen("curl --silent #{url}") do |view|
        view.gets # discard header
        while row = parse_line(view.gets)
          yield row
        end
      end
    end
    
    private
    
    def parse_line line
      return nil unless line
      if /(\{.*\}),?/.match(line.chomp)
        JSON.parse($1)
      end
    end
    
  end
end