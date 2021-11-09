require 'rest-client'
require './web_functions.rb'

class InteractionNetwork

    attr_accessor :input_genes
    @@all_objects= Array.new

    def initialize(params={})
        @input_genes = params.fetch(:input_genes, [])
        @@all_objects < self  
    end

    def interactions(genes_list)
        output= Array.new
        genes_list.ech do |gene|
            interactions = get_interactions(gene, genes_list)
            if interactions !=[] #if there are any interactions add it as geneid, interaction... in an array
                output.push([gene, interactions].flatten)
            end
        end 

        return output
    end

    def get_interactions_array(all_genes, genes)
        only_int= Array.new
        all_genes.each do |int| #takes each netweork array
            only_int.push(int[1..-1]) #to not include the geneid in the network array
        end
        only_int.flatten!.uniq!
        only_int= only_int - (only_int & genes)
        return only_int
      end
end
