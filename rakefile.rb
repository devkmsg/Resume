
desc "Generate resume.html"
task :html do
  `pandoc -t html -o resume.html -c resume.css resume.md`
end

desc "Generate resume.pdf"
task :pdf do
  `markdown2pdf --template=resume-template.tex --xetex resume.md`
end

desc "Generate resume.docx"
task :docx do
  `pandoc resume.md -o resume.docx --template=resume-template.tex`
end

desc "Generate resume.doc"
task :doc do
  `pandoc resume.md -s -t rtf -o resume.doc`
end

task :clean do
  `del resume.html resume.pdf resume.docx`
end

task :default => [:pdf, :html, :docx]
