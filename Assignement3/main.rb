require './BioRuby.rb'




#-----------------------------------------------------------------

# Starting tasks

$target = "cttctt" # This global variable contains the sequence to search in the exons
$len_target = $target.length() # Global variable with the target's length 

puts "Working on the tasks...\n"

# We create global variables with the objects of opening the files correponding to
#   1) GFF3 with positions refering to genes
#   2) GFF3 with positions refering to chromosomes
#   3) Genes without target in exons
$gff_genes = create_open_file("genes.gff3")
$gff_chr = create_open_file("chromosomes.gff3")
$no_targets = create_open_file("genes_without_target.txt")


# We print the headers of each file
$gff_genes.puts "##gff-version 3"
$gff_chr.puts "##gff-version 3"
$no_targets.puts "Genes without #{$target.upcase} in exons\n\n"


genes_ids = load_from_file("./geneslist.txt") 

#-----------------------------------------------------------------

# Main part of the program to search the targets in the exons

genes_ids.each do |gene|
  
  seq_obj = obtain_gene_info(gene) # Create the Bio:EMBL object from each gene
  
  unless seq_obj.nil?
    target_hash = get_exons_targets(seq_obj) # We get the targets inside exons of the gene
    # Target hash contains as keys: [initial position of target, end position of target]
    # and as values: [ID of the exon, strand]
    
    if target_hash.empty?
      $no_targets.puts gene
      # If the gene has no targets in exons, we add it to the file genes_without_target.txt
      
    else  
      add_features(gene, target_hash, seq_obj) # We create new features and add them to each seq_obj
      chr = get_chromosome(gene, seq_obj) # We return the chromosome number and postions
      convert_to_chr(gene, target_hash, chr) # We convert the positions to the ones that correspond in the chromosome
    
    end
    
  end
  
end

puts "DONE!\n\n"
puts "You can browse the output in the files: "
puts "\t- genes.gff3"
puts "\t- chromosomes.gff3"
puts "\t- genes_without_target.txt"