require "./database.rb"

#We create a new object from the class Database
n1= Database.new

#We call the function on the object n1 to make the calculation
n1.all_stocks.values.each do |seed|
    seed.plant(7)
end


#to record the new information in a new file after planting 7 grams of each type
 n1.newrecord("newdata.tsv")

# This function makes the calculation of the chi_square value 
#On the F2 data and sicovers which genes are linked and the value of chi with a p<0.05
n1.all_crosses.values.each {|n1| n1.calc_chi}