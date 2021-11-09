require 'rest-client'
require 'json' 
def fetch(url, headers = {accept: "*/*"}, user = "", pass="")

    response= RestClient::Request.execute({
        method: :get,
        url: url.to_s,
        user: user,
        password: pass,
        headers: headers
    })
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

    def get_protID(geneid)
    $stderr.puts "calling http://togows.org/entry/ebi-uniprot/#{geneid}/accessions.json"
    if res = fetch("http://togows.org/entry/ebi-uniprot/#{geneid}/accessions.json")
        body = res.body  #get the body from of the response
        data= JSON.parse(res.body)
        return body
    else
       return Array.new
    end
    end


    def get_KEGG(geneid)
        $stderr.puts "calling http://togows.org/entry/kegg-genes/ath:#{geneid}/pathways.json"
        KEGG_list= Array.new
        if res = fetch("http://togows.org/entry/kegg-genes/ath:#{geneid}/pathways.json")
            body = res.body  #get the body from of the response
            data= JSON.parse(res.body)
            KEGG_list.push(data[0].to_a)
            unless data[0].empty? #if the condition is false it will do what's in the if clause
                if data[0].length !=0
                    KEGG_list= data[0].to_a
                    
                end
                
            end
            return KEGG_list

         else #next
           return Array.new 
            #abort "COULDN'T RETRIEVE GENE ID" #Esto es lo que yo creo que hay que poner
         
        end   
    end 



    #Now we want to make a funcion for the GO annotation 
    def get_GO(geneid)
        $stderr.puts "calling http://togows.org/entry/ebi-uniprot/#{geneid}/dr.json"
        GO_list= Array.new
        if res = fetch("http://togows.org/entry/ebi-uniprot/#{geneid}/dr.json")
            body = res.body  #get the body from of the response
            data= JSON.parse(res.body)
            if data[0]["GO"] #To select just the data from the GO array
                data[0]["GO"].each do |go|
                    if go[1] =~/P:/ #inspect each element of the GO array and match with P element which contains the biological process data
                    GO_list.push(go[0..1])
                    end
                end
                return GO_list
            end
        
         else #next
            return Array.new 
            
        end
    end


    #To get the gene interactions

    def get_interactions (geneid, allgenes)
        $stderr.puts "calling http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{geneid}?species:3702?format=tab25"
        interactions_list= Array.new
        if res = fetch("http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{geneid}?species:3702?format=tab25") #This way we can filter by specie in this case Arabidopsis Thaliana
            body = res.body
            data = body.split("\n").to_a # Split the rows into arrays


            (0..data.length-1).each do |i|
             data[i]=data[i].split("\t") #to create an array's element per each tab separated value

             intact_score=data[i][14].split(":")[1]
             if intact_score.to_f < 0.485
                next #if the interaction score in under the cutoff it jumps to the next interaction discarting this
             end

             data[i]= data[i][4..5] #Columns with the locus name
             (0..data[i].length-1).each do |j|
                interactions_list.push(data[i][j].scan(/A[Tt]\d[Gg]\d\d\d\d\d/)) #to fing the AGI code in the text, and retrieve and add it to the array
             end
            end
        
            interactions_list = interactions_list.flatten.uniq  #merges all arrays into one and returns array top unique elements so I dont have repeated values.
            interactions_list.map!(&:upcase) #Make all data uppercase to compare it
            interactions_list = interactions_list - [geneid.upcase] #To exclude my own genes as an interaction
            #puts "interactions_list created"
            
            return interactions_list


        end
    end






