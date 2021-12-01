require 'bio'
require 'rest-client'
require 'net/http' 

gene_file = File.new("./geneslist.txt","r")

genes_list=Array.new 
gene_file.each do |agi| # iterate over the elements of gene_file
  genes_list.push(agi.strip) #add AGI codes to a list
end
# puts genes_list

def gene_db(geneid)
    address = URI("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{geneid}")
    
    response =  Net::HTTP.get_response(address)

    record = response.body

    entry = Bio::EMBL.new(record) 
    
    bioseq = entry.to_biosequence
    
    return bioseq
    
    
    # puts bioseq
end

gene_db(genes_list)

# search = Bio::Sequence::NA.new("CTTCTT")



