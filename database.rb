require "./gene.rb"
require "./seedstock.rb"
require "./cross.rb"

class Database
     attr_accessor :all_genes
     attr_accessor :all_stocks
     attr_accessor :all_crosses
    def initialize

        @all_genes=Hash.new
        load_genes()
        @all_stocks=Hash.new
        load_stocks()
        @all_crosses=Hash.new
        load_crosses()
        
    end
    #For each tsv file we've created diccionaries that will contain the parameters and values of each file

    #Next we define the functions to load our data in each diccionary for the different datasets
    def load_genes
        genedata=IO.readlines("./gene_information.tsv") 
        genedata[1..-1].each do |line|  
            geneid, name, phenotype=line.chomp.split("\t")
            @all_genes[geneid.to_sym]=Gene.new(geneid: geneid,
                                                name: name,
                                                phenotype: phenotype)
        end
    end

    def load_stocks
        stockdata=IO.readlines("./seed_stock_data.tsv") 
        @stockheader=stockdata[0]
        stockdata[1..-1].each do |line|  
            stock, geneid, planted, storage, grams=line.chomp.split("\t")
            @all_stocks[stock.to_sym]=Seedstock.new(geneid: @all_genes[geneid.to_sym], #to link  with the geneid property of the class Gene as they are the same in both files
                                                stock: stock,
                                                planted: planted,
                                                storage: storage,
                                                grams: grams)
        end
    end

    def load_crosses
        crossdata=IO.readlines("./cross_data.tsv") 
        crossdata[1..-1].each do |line|  
            parent1, parent2, f2Wild, f2p1, f2p2, f2p1p2=line.chomp.split("\t")
            @all_crosses[(parent1+"-"+parent2).to_sym]=Cross.new(parent1: @all_stocks[parent1.to_sym],
                                                                    parent2: @all_stocks[parent2.to_sym], #to link  with the stockid property of the class Seedstock as they are the same in both files
                                                                    f2Wild: f2Wild,
                                                                    f2p1: f2p1,
                                                                    f2p2: f2p2,
                                                                    f2p1p2: f2p1p2)
        end
    end


 #This function will create a new file with the updated values
 def newrecord(newdata) 
      out = File.open(newdata, 'w')
      out.puts(@stockheader)
      @all_stocks.values.each do |stock|
        out.puts([stock.stock, stock.geneid.geneid, stock.planted, stock.storage, stock.grams].join("\t"))
        end
    end
    
end




