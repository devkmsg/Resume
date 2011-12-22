
desc "Generate resume.html"
task :html do
  `pandoc -t html -o resume.html -c resume.css resume.md`
end

desc "Generate resume.pdf"
task :pdf do
  `markdown2pdf --template=resume-template.tex --xetex resume.md`
end

task :default => [:pdf, :html]
