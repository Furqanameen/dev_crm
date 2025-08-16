#!/usr/bin/env ruby

# Script to fix incorrect turbo_data syntax in ERB files
# The incorrect pattern: data: { turbo_data: { turbo_method: :post } }
# Should be: data: { turbo_method: :post }

require 'fileutils'

def fix_turbo_syntax_in_file(file_path)
  return false unless File.exist?(file_path)
  
  content = File.read(file_path)
  original_content = content.dup
  
  # Fix pattern 1: data: { turbo_data: { turbo_method: :METHOD } }
  content.gsub!(/data:\s*\{\s*turbo_data:\s*\{\s*turbo_method:\s*:(\w+)\s*\}\s*\}/, 'data: { turbo_method: :\1 }')
  
  # Fix pattern 2: data: { turbo_data: { turbo_method: :METHOD }, other_option: "value" }
  content.gsub!(/data:\s*\{\s*turbo_data:\s*\{\s*turbo_method:\s*:(\w+)\s*\},\s*(turbo_confirm:\s*[^}]+)\s*\}/) do |match|
    method = $1
    confirm = $2
    "data: { turbo_method: :#{method}, #{confirm} }"
  end
  
  # Fix pattern 3: turbo_data: { turbo_method: :METHOD }, other_data followed by close braces
  content.gsub!(/turbo_data:\s*\{\s*turbo_method:\s*:(\w+)\s*\},\s*(turbo_confirm:\s*[^,}]+)/) do |match|
    method = $1
    confirm = $2
    "turbo_method: :#{method}, #{confirm}"
  end
  
  if content != original_content
    File.write(file_path, content)
    puts "✅ Fixed: #{file_path}"
    return true
  else
    puts "ℹ️  No changes needed: #{file_path}"
    return false
  end
rescue => e
  puts "❌ Error processing #{file_path}: #{e.message}"
  return false
end

# Find all ERB files in the views directory
view_files = Dir.glob("app/views/**/*.erb")

puts "🔍 Searching for files with incorrect turbo_data syntax..."
puts "Found #{view_files.length} ERB files to check"
puts

files_with_issues = []

# First, identify files that have the incorrect pattern
view_files.each do |file_path|
  content = File.read(file_path) rescue ""
  if content.match?(/turbo_data.*turbo_method/)
    files_with_issues << file_path
  end
end

puts "📋 Files with turbo_data syntax issues:"
files_with_issues.each { |file| puts "  - #{file}" }
puts

if files_with_issues.empty?
  puts "🎉 No files found with turbo_data syntax issues!"
  exit 0
end

puts "🔧 Fixing turbo_data syntax issues..."
puts

fixed_files = 0
files_with_issues.each do |file_path|
  if fix_turbo_syntax_in_file(file_path)
    fixed_files += 1
  end
end

puts
puts "🎉 Fixed #{fixed_files} files out of #{files_with_issues.length} files with issues"
puts "✨ All Turbo syntax has been corrected!"
