require 'base64'
require 'pp'

$output = 'AndrewThompsonResume'
$output_path = 'target'
SOURCE = 'resume.md'

task :output_path do
  mkdir_p $output_path
end

desc "Generate resume.pdf"
task :pdf => [:output_path] do
  file = ::File.join($output_path, "#{$output}.pdf")
  sh("pandoc #{SOURCE} -V geometry:margin=.5in -o #{file}")
end

desc "Generate references.pdf"
task :references_pdf => [:output_path, :build_ref] do
  file = ::File.join($output_path, 'AndrewThompsonReferences.pdf')
  sh("pandoc references.md -V geometry:margin=.5in -o #{file}")
end

def sanitize_input(str)
  str.downcase.gsub(/(\.|_)$/, '').gsub(',', '').gsub(' ', '_')
end

desc "Generate reference definition"
task :ref_def, :name, :title, :company, :email, :phone do |t, args|
  data = { name: args[:name],
    title: args[:title],
    company: args[:company],
    email: args[:email],
    phone: args[:phone]
  }
  pp data

  str = "%{name}\\newline
%{title}, %{company}\\newline
%{email}\\newline
%{phone}\\newline" % data

  str = encrypt(str)
  
  filename = [sanitize_input(args[:name]),
    sanitize_input(args[:company]),
    sanitize_input(args[:title])]
  filename = filename.join('_')
  path = File.join(File.dirname(File.expand_path(__FILE__)), 'reference', filename)
  File.open(path, 'w') do |file|
    file.puts str
  end
end

def encrypt(str)
  Base64.strict_encode64(Base64.strict_encode64(str.reverse).reverse)
end

def decrypt(str)
  Base64.decode64(Base64.decode64(str).reverse).reverse
end

desc "Build references"
task :build_ref do
  path = File.join(File.dirname(File.expand_path(__FILE__)))
  references = File.readlines(File.join(path, '.references'))
  pp references 
  cp 'references.md.template', 'references.md'
  File.open(File.join(path, 'references.md'), 'a') do |ref_file|
    references.each do |ref|
      next if ref.start_with? '#'
      ref = ref.chomp
      lines = File.readlines(File.join(path, 'reference', ref))
      line = lines[0].chomp
      line = decrypt(line)
      pp line
      ref_file.puts line
      ref_file.puts
    end
  end
end

task :clean do
  rm_rf $output_path
end

task :gh_pages do
  rm_rf 'gh'
  mkdir_p 'gh'
  sh 'git clone --branch gh-pages https://github.com/devkmsg/Resume gh'
  cp_r 'target/', 'gh'
  cd 'gh'
  sh 'git add .'
  sh 'git commit -m "Updating build artifacts"'
  sh 'git push origin gh-pages --force'
end

task :default => [:clean, :pdf, :references_pdf]
task :publish => [:clean, :pdf, :gh_pages]
