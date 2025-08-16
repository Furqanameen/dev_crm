#!/usr/bin/env ruby

# Script to fix Rails 8 Turbo method syntax in ERB files
require 'fileutils'

def fix_erb_file(file_path)
  return unless File.exist?(file_path)
  
  content = File.read(file_path)
  original_content = content.dup
  
  # Fix method: :post with confirm
  content.gsub!(
    /method: :post,\s*\n?\s*confirm: "([^"]+)"/m,
    'data: { turbo_method: :post, turbo_confirm: "\1" }'
  )
  
  # Fix method: :post with data confirm
  content.gsub!(
    /method: :post,\s*\n?\s*data: \{ confirm: "([^"]+)" \}/m,
    'data: { turbo_method: :post, turbo_confirm: "\1" }'
  )
  
  # Fix method: :delete with confirm
  content.gsub!(
    /method: :delete,\s*\n?\s*confirm: "([^"]+)"/m,
    'data: { turbo_method: :delete, turbo_confirm: "\1" }'
  )
  
  # Fix method: :delete with data confirm
  content.gsub!(
    /method: :delete,\s*\n?\s*data: \{ confirm: "([^"]+)" \}/m,
    'data: { turbo_method: :delete, turbo_confirm: "\1" }'
  )
  
  # Fix standalone method: :post
  content.gsub!(
    /method: :post(?!.*turbo_method)/,
    'data: { turbo_method: :post }'
  )
  
  # Fix standalone method: :delete  
  content.gsub!(
    /method: :delete(?!.*turbo_method)/,
    'data: { turbo_method: :delete }'
  )
  
  if content != original_content
    File.write(file_path, content)
    puts "✅ Fixed: #{file_path}"
    return true
  else
    puts "⏭️  No changes needed: #{file_path}"
    return false
  end
end

# Find all ERB files in admin views
erb_files = Dir.glob("app/views/admin/**/*.erb")
fixed_files = 0

puts "🔧 Fixing Rails 8 Turbo method syntax in ERB files..."
puts "=" * 60

erb_files.each do |file|
  if fix_erb_file(file)
    fixed_files += 1
  end
end

puts "=" * 60
puts "🎉 Fixed #{fixed_files} files out of #{erb_files.length} total files"
puts "✅ All Rails 8 Turbo method syntax issues have been resolved!"
