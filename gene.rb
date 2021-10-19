class Gene
    #We create a Gene class with its properties and attr_accesor as getters and setters
    attr_accessor :geneid  
    attr_accessor :genename
    attr_accessor :phenotype

    def initialize (params = {})
        @geneid = params.fetch(:geneid)
        @genename = params.fetch(:name)
        @phenotype= params.fetch(:phenotype)
    end
end