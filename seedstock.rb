class Seedstock

    attr_accessor :stock
    attr_accessor :geneid
    attr_accessor :planted
    attr_accessor :storage
    attr_accessor :grams

    def initialize (params ={})
        @stock = params.fetch(:stock)
        @geneid = params.fetch(:geneid)
        @planted = params.fetch(:planted)
        @storage = params.fetch (:storage)
        @grams = params.fetch(:grams)
        @grams = grams.to_i

    end


    #We define the method that is going to do the calculation with the amount of seed we plant
    def plant(seeds)
        @grams -= seeds
        if @grams <= 0
            @grams=0
            puts "WARNING!The amount of seeds of #{@stock} (locus #{@geneid.geneid}) is #{grams} g"
        else 
            puts "We still have enough seeds of #{@stock} !:)"

    
        end 
    end 


    
end

