require "net/http"
require "pdf-reader"
require "colorize"

def collect_urls(file)
  reader = PDF::Reader.new(file)
  links = Array.new
  reader.pages.each do |page|
    links << URI.extract(page.text, ["http", "https"])
  end
  links.flatten
end

def url_status(url_string)
  url = URI.parse(url_string)
  request = Net::HTTP.new(url.host, url.port)
  request.use_ssl = (url.scheme == "https") 
  path = url.path unless url.path.nil?
  result = request.request_head(path || "/")
  case result.code
  when "200" then return "200 - OK", "green", nil
  when "301" then return "301 - Moved Permanently", "yellow", result["location"]
  when "404" then return "404 - Not Found", "red", nil
  when "500" then return "500 -Internal Server Error", "red", nil
  end
end

def successful_links(successes_array)
  puts ("#" * 40) + (" " * 5) + "SUCCESSFULLY CONNECTED" + (" " * 5) + ("#" * 40)
  successes_array.each {|success| puts success[0].green}
end

def redirected_links(redirect_hash)
  puts ("#" * 40) + (" " * 5) + "REDIRECT OPPORTUNITIES" + (" " * 5) + ("#" * 40)
  redirect_hash.each do |indirect, direct|
    printf("%-10s%-100s\n", "Replace:", indirect.yellow) 
    printf("%-10s%-100s\n", "With:", direct.green)
  end
end

def problematic_links(problems_array)
  puts ("#" * 40) + (" " * 5) + "PROBLEMATIC LINKS" + (" " * 5) + ("#" * 40)
  problems_array.each {|problem| printf("%-100s| %s\n", problem[0].red, problem[1].red)}
end

def unsupported_links(edgecases_array)
  puts ("#" * 40) + (" " * 5) + "UNSUPPORTED LINKS" + (" " * 5) + ("#" * 40)
  edgecases_array.each {|edgecase| puts edgecase.magenta}
end

def which_reports?
  valid_reports = ["successes", "redirects", "problems", "exceptions"]
  puts "Please select from the following reports (seperate with commas and spaces, as shown): successes, redirects, problems, exceptions"
  user_answer = gets.chomp.split(", ")
  error = false
  user_answer.each do |report_type|
    if !valid_reports.include?(report_type)
      puts "#{report_type} is not a valid report.  As an example, here's how to get the problems and exceptions reports:  >>> problems, exceptions"
      error = true
    end
  end
  error ? user_answer = which_reports? : user_answer
end

def check_document(document)
  puts "One moment please...".green
  redirects = Hash.new
  successes, problems, edgecases = Array.new(3) {[]}
  urls = collect_urls(document)
  urls.each do |url|
    begin
      message, color, redirect = url_status(url)
      case color 
      when "green" then successes << [url, message]
      when "red" then problems << [url, message]
      when "yellow" then redirects[url] = redirect
      end
    rescue
      edgecases << url unless url.nil?
    end
  end
  reports = which_reports?
  successful_links(successes) unless !reports.include?("successes")
  redirected_links(redirects) unless !reports.include?("redirects")
  problematic_links(problems) unless !reports.include?("problems")
  unsupported_links(edgecases) unless !reports.include?("exceptions")
end

printf "Please enter a PDF filename to check its hyperlinks (no need to include the extension): "
filename = gets.chomp
check_document(filename + ".pdf")