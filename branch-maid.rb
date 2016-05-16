#!/usr/bin/env ruby

require 'json'
require 'logger'
require 'net/http'
require 'optparse'
require 'uri'

def https_request(uri, request)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(request)
    end
end

def http_get(api_url, endpoint, token)
    uri = URI.join(api_url, endpoint)
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "token #{token}"
    https_request(uri, request)
end

def parse_options
    options = {
        dry_run: false,
        github_api: 'https://api.github.com/',
        log_level: Logger::WARN
    }

    option_parser = OptionParser.new do |parser|
        parser.banner = 'Usage: branch-maid.rb [options]'
        parser.on('-g', '--github-api URL', 'Default is https://api.github.com') do |url|
            url << '/' unless url.end_with?('/')
            options[:github_api] = url
        end
        parser.on('-n', '--dry-run') do
            options[:dry_run] = true
        end
        parser.on('-t', '--token TOKEN', 'Github API token') do |token|
            options[:token] = token
        end
        parser.on('-v', '--verbose') do
            options[:log_level] = Logger::INFO
        end
    end

    begin
        option_parser.parse!
        mandatory = [:token]
        missing = mandatory.select { |param| options[param].nil? }
        unless missing.empty?
            puts "Required options: #{missing.join(', ')}"
            puts option_parser
            exit
        end
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
        puts $ERROR_INFO.to_s
        puts option_parser
        exit
    end

    options
end

def pull_requests(github_api, owner, repo, branch, token, logger)
    response = http_get(
        github_api,
        "repos/#{owner}/#{repo}/pulls?state=closed&sort=updated&direction=desc&head=#{owner}:#{branch}",
        token).body
    logger.debug("PR details for #{branch}: #{response}")
    JSON.parse(response)
end

def merged?(response)
    return false if response.empty?
    return true if response[0]['merged_at']
    false
end

def main
    logger = Logger.new(STDOUT)
    remote = `git remote get-url origin`
    owner = %r{(?<=:)(.*)(?=\/)}.match(remote)
    repo = %r{(?<=\/)(.*)(?=\.git$)}.match(remote)
    branches = `git branch | grep -v '*'`.split
    options = parse_options
    logger.level = options[:log_level]

    merged_branches = []
    branches.each do |branch|
        response = pull_requests(options[:github_api], owner, repo, branch, options[:token], logger)
        merged = merged?(response)
        if merged
            merged_branches.push(branch)
            logger.info("#{branch}: merged")
        elsif response.empty?
            logger.info("#{branch}: no closed pull request found")
        else
            logger.info("#{branch}: not merged")
        end
    end

    merged_branches.each do |branch|
        if options[:dry_run]
            puts branch
        else
            puts `git branch -D #{branch}`
        end
    end

    puts "\nRerun without '-n' or '--dry-run' to delete the above branches" if options[:dry_run]
end

main if __FILE__ == $PROGRAM_NAME
