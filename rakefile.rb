$files = []
$output = 'AndrewThompsonResume'
SOURCE = 'resume.md'

desc "Generate resume.html"
task :html do
  file = $output + '.html'
  $files << file
  sh("pandoc -t html -o #{file} -c resume.css #{SOURCE}") 
end

desc "Generate resume.pdf"
task :pdf do
  file = $output + '.pdf'
  $files << file
  sh("pandoc #{SOURCE} -V geometry:margin=.5in -o #{file}")
end

desc "Generate resume.docx"
task :docx do
  file = 'resume.docx'
  file = $output + '.docx'
  $files << file
  sh("pandoc #{SOURCE} -o #{file} --template=resume-template.tex")
end

desc "Generate resume.doc"
task :doc do
  file = $output + '.doc'
  $files << file
  sh("pandoc #{SOURCE} -o #{file}")
end

task :clean do
  files = [
    '.html',
    '.pdf',
    '.docx',
    '.doc'
  ]
  files = files.map {|f| $output + f}
  files.each do |file|
    rm file if File.exists? file
  end 
end

task :default => [:clean, :pdf, :html, :docx, :doc]
