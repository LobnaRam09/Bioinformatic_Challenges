## Assignment 3
require 'bio'
require 'rest-client'

def fetch(url, headers = {accept: "*/*"}, user = "", pass="")
    response = RestClient::Request.execute({
      method: :get,
      url: url.to_s,
      user: user,
      password: pass,
      headers: headers})
    return response
    
    rescue RestClient::ExceptionWithResponse => e
      $stderr.puts e.inspect
      response = false
      return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    rescue RestClient::Exception => e
      $stderr.puts e.inspect
      response = false
      return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    rescue Exception => e
      $stderr.puts e.inspect
      response = false
      return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
end

def get_embl(file) #To access to the database and get the EMBL entry
  @genes=Hash.new # a hash to save the AGI Loci ids and their EMBL entries from the web
    File.open(file).each do |gene_id|
      gene_id.strip!
      response = fetch("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene_id}")
      if response
        embl=Bio::EMBL.new(response.body)
        @genes[gene_id]=embl
      end
    end
  return @genes
end


def scan_exons(genes) #Function to scan th sequence over every exon from the EMBL entry previously obtained 

  rep_forw=(Bio::Sequence::NA.new("CTTCTT")).to_re # pattern searched for on the + strand
  rep_rev=(Bio::Sequence::NA.new("AAGAAG")).to_re # pattern searched for on the - strand
  @bioseq=Hash.new # hash to save the AGI Loci ids and their sequence
  
  genes.each do |gene_id,embl| 
    all_pos=[] # an array to store all the added positions on each gene
    bio_seq=embl.to_biosequence
    embl.features do |feature|
      next unless feature.feature == "exon" #to loop over every exon
      
      feature.locations.each do |location|
        
        exon_seq=embl.seq[location.from..location.to]
        next if exon_seq.nil?
        if location.strand == 1 #to search for the squence for the forward strain
          if exon_seq.match(rep_forw)
            pos_forw = [exon_seq.match(rep_forw).begin(0)+1,exon_seq.match(rep_forw).end(0)].join('..') #to get the psoition of the CTTCTT matched in the exon
            bio_seq.features << add_features("#{pos_forw}",location.strand) unless all_pos.include?(pos_forw) # to not add same feature more than once
            @bioseq[gene_id]=bio_seq
            all_pos << pos_forw 
          end
        elsif location.strand == -1 # scanning the reverse strand of the exon 
          if exon_seq.match(rep_rev)
            pos_rev = [exon_seq.match(rep_rev).begin(0),exon_seq.match(rep_rev).end(0)-1].join('..')#to get the CTTCTT sequence position in the reverse sequence
            bio_seq.features << add_features("complement(#{pos_rev})",location.strand) unless all_pos.include?(pos_rev)
            @bioseq[gene_id]=bio_seq
            all_pos << pos_rev
          end
        end
      end
    end
  end
end


def add_features(pos,strand) # method previously to add new features to the sequence entries
  ft=Bio::Feature.new('myrepeat',pos) # unique feature type and its location
  ft.append(Bio::Feature::Qualifier.new('nucleotide_motif','cttctt'))
  ft.append(Bio::Feature::Qualifier.new('function','insertion site'))
  if strand == 1
		ft.append(Bio::Feature::Qualifier.new('strand', '+'))
  elsif strand == -1
		ft.append(Bio::Feature::Qualifier.new('strand', '-'))
  end
end

def gff3_genes(bioseq,source="BioRuby",type="direct_repeat",score=".",phase=".")
  # function that takes the @bioseq variable to create the gff3 report
  File.open('genes_report.gff3', 'w+') do |i|
    i.puts("##gff-version 3")
    @bioseq.each do |gene_id,bio_seq|
      counts=0 # a counter to differentiate the repeats found in one gene
      bio_seq.features.each do |feature|
        next unless feature.feature == 'myrepeat' # select the features added before
        counts+=1
        pos=feature.locations.first # get the first location object
        strand=feature.assoc['strand'] # get the strand qualifier
        attributes="ID=CTTCTT_insertional_repeat_#{gene_id}_#{counts};" # add a different attribute for each feature
        i.puts("#{gene_id}\t#{source}\t#{type}\t#{pos.from}\t#{pos.to}\t#{score}\t#{strand}\t#{phase}\t#{attributes}")
      end
    end
  end
end

def gff3_chromosomes(bioseq,source="BioRuby",type="direct_repeat",score=".",phase=".")
  
  File.open('chromosomes_report.gff3', 'w+') do |j|
   j.puts("##gff-version 3")
  
    @bioseq.each do |gene_id,bio_seq|
      chr_coords=bio_seq.primary_accession.split(":")[3] # select the beginning position of the chromosome
      seqid=bio_seq.primary_accession.split(":")[2] # select the chromosome number
      counts=0
      bio_seq.features.each do |feature|
        next unless feature.feature == 'myrepeat'
        counts+=1
        pos=feature.locations.first
        strand=feature.assoc['strand']
        attributes="ID=CTTCTT_insertional_repeat_#{gene_id}_#{counts};"
        first=chr_coords.to_i+pos.from 
        last=chr_coords.to_i+pos.to
        j.puts("#{seqid}\t#{source}\t#{type}\t#{first}\t#{last}\t#{score}\t#{strand}\t#{phase}\t#{attributes}")
      end
    end
  end
end

def noreps_report(genes,bioseq) # create a report of the loci for which no repeats have been found
  @count=0 # to count the genes that dont have the seq
  File.open('genes_without_target.txt', 'w+') do |k|
    k.puts("The following loci don't have any CTTCTT repeats:")
    genes.each do |l,m|
      unless bioseq.keys.include?(l) # the gene ids that are not in the @bioseq variable dont have the repetition seq
        @count+=1
        k.puts("\t#{@count} : #{l}")
      end
    end
  end
  return @count
end
