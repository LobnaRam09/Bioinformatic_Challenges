require './a3.rb'


# Script to develop the program
puts "Loading..."

get_embl("./ArabidopsisSubNetwork_GeneList.txt")

scan_exons(@genes)

puts "Searching for the repeats and adding features"

gff3_genes(@bioseq)

puts "Getting GFF3 file with gene coordinates"

gff3_chromosomes(@bioseq)

puts "Getting GFF3 file with chromosomes coordinates"

noreps_report(@genes,@bioseq)

puts "Created report with genes that don't have CTTCTT repeat (#{@count} genes)"