using Serialization
using TextAnalysis
terms = Serialization.deserialize("terms.jldata") 
termfreq = Serialization.deserialize("termfreq.jldata") 
irs990 = Serialization.deserialize("irs990extract.jldata") 

index = 3131

d1 = StringDocument(irs990[index]["mission"])
c = Corpus([sd])
remove_case!(c)
prepare!(c, strip_punctuation)
stem!(c)
missionWords = split(text(c[1]))

termsIndices = []

for word in missionWords
    for i in eachindex(terms)
        if terms[i] == word
            append!(termsIndices, i)
        end
    end
end

total = 0
println("term\t\tfrequency")

for term in unique(termsIndices)
    freq = termfreq[index, term]
    println(terms[term] * "\t\t" * string(freq))
end