require 'bio'
require 'stringio'


#1. Create a BLAST factory

factory_pep = Bio::Blast.local('blastx', 'Databases/PEP')
# blastx uses a nucleotide sequence as input, and compares them with a protein databases
# Filter option for blastall -F (T or F)

factory_tair = Bio::Blast.local('tblastn', 'Databases/TAIR')
# Tblastn compares a proteic sequence with a nucleotide database
$stderr.puts "Searching ... "

# 2. Load fasta files
pep_file = Bio::FlatFile.auto('../Databases/pep.fa') #shorter proteome with less entries
tair_file = Bio::FlatFile.auto('../Databases/TAIR10_cds_20101214_updated.fa') #larger one


out_file = File.new('orthologs.txt', 'w')
out_file.puts "PEP_id\tTAIR_id\tPEP>TAIR_evalue\tTAIR>PEP_evalue\t"

$E_VAL = 10**-6

# We create a hash to store the sequences and make them accesible by its id.
tair_hash = Hash.new
tair_file.each do |seq_tair|
  tair_hash[(seq_tair.entry_id).to_s] = (seq_tair.seq).to_s
end


# We need a counter to know how many orthologues have been found
count = 1


pep_file.each do |seq_pep| # We iterate over each sequence in the pep file which is shorter

  pep_id = (seq_pep.entry_id).to_s # We store the ID to later know if it is a reciprocal best hit
  report_tair = factory_tair.query(seq_pep)

  if report_tair.hits[0] # Only if there have been hits continue.

    tair_id = (report_tair.hits[0].definition.match(/(\w+\.\w+)|/)).to_s 

    if (report_tair.hits[0].evalue <= $E_VAL)  

      report_pep = factory_pep.query(">#{tair_id}\n#{tair_hash[tair_id]}")
     

      if report_pep.hits[0] 

        match = (report_pep.hits[0].definition.match(/(\w+\.\w+)|/)).to_s 

        if (report_pep.hits[0].evalue <= $E_VAL)  

          if pep_id == match 

            out_file.puts "#{pep_id.entry_id}\t#{tair_id.entry_id}\t#{pep_id.evalue}\t#{tair_id.evalue}"
            #puts "#{pep_id}\t\t#{tair_id}"

            count += 1

          end

        end

      end

    end

  end


end

# Print in the file the number of orthologues
out_file.puts "\n\nNumber of orthologues found: #{count}"


puts "DONE!\n\n"
puts "You can find the output in the file ortologues.txt"
