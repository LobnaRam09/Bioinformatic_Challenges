class Cross

    attr_accessor :parent1
    attr_accessor :parent2
    attr_accessor :f2Wild
    attr_accessor :f2p1
    attr_accessor :f2p2
    attr_accessor :f2p1p2

    def initialize (params={})
        @parent1 = params.fetch(:parent1)
        @parent2 = params.fetch(:parent2)
        @f2Wild = params.fetch(:f2Wild)
        @f2p1 = params.fetch(:f2p1)
        @f2p2 = params.fetch(:f2p2)
        @f2p1p2 = params.fetch(:f2p1p2)
    end

    #We define the function to calculate the chisqaure and do the comparisong for each cross and if the condition is fulfilled
    def calc_chi
        total = @f2Wild.to_f + @f2p1.to_f + @f2p2.to_f + @f2p1p2.to_f
    
        #Calculate the expected observations in each cross
        exp_f2Wild = 9.0/16.0*total.to_f 
        exp_f2p1 = 3.0/16.0*total.to_f
        exp_f2p2 = 3.0/16.0*total.to_f
        exp_f2p1p2 = 1.0/16.0*total.to_f
        
        #Calculate the chivalue with the formula
        chi_square_value = ((@f2Wild.to_f - exp_f2Wild)**2/exp_f2Wild)+
                            ((@f2p1.to_f - exp_f2p1)**2/exp_f2p1)+
                            ((@f2p2.to_f - exp_f2p2)**2/exp_f2p2)+
                            ((@f2p1p2.to_f - exp_f2p1p2)**2/exp_f2p1p2) 
        
        
       if chi_square_value > 7.815 # Threshold for chi_square with a p value < 0.05
                puts "Recording: #{@parent1.stock} is genetically linked to #{@parent2.stock} with chisquare score #{chi_square_value}"
                # The @Partent1 and @Parent2 are linked to the gene name from gene_information by the stock property in seed_stock_data
         
        end
        
    
    end
end