using Serialization
using TextAnalysis
using MultivariateStats
using Plots
using Distributions
using Clustering
terms = Serialization.deserialize("terms.jldata")
termfreq = Serialization.deserialize("termfreq.jldata")
irs990 = Serialization.deserialize("irs990extract.jldata")

# Section 1
# Question 1
function termsThatAppearXTimes(termfreq, x)
    termAppearances = 0
    for i in 1:size(termfreq, 2)
        term = termfreq[:, i]
        if size(term.nzval,1) == 1
            termAppearances += 1
        end
    end
    return termAppearances
end

println("Total number terms that appear once is: " * string(termsThatAppearXTimes(termfreq, 1)))

# Question 2
function howManyTermsAppear(termfreq, moreThanX)
    totalTerms = 0
    for i in 1:size(termfreq, 2)
        col = termfreq[:, i]
        if size(col.nzval,1) > moreThanX
            totalTerms += 1
        end
    end
    return totalTerms
end

println("There are " * string(howManyTermsAppear(termfreq, 5)) * " terms that appear more than five times")

# Question 3
function termFrequencyMeasure(termfreq, termIndex)
    term = termfreq[:, termIndex]
    total = 0
    for i in term.nzval
        total += i
    end
    return total
end

function mostCommonTerms(termfreq, topX)
    termfreqTemp = termfreq
    # get the first topX values from termfreq
    topXTerms = collect(1:topX)
    for j in 1:topX
        # loop through every element to find the highest and remove it
        mostFreq = 1
        for termIndex in 1:size(termfreqTemp, 2)
            term = termfreqTemp[:, termIndex]
            if termFrequencyMeasure(termfreqTemp, termIndex) > termFrequencyMeasure(termfreqTemp, mostFreq)
                mostFreq = termIndex
            end
        end
        println(termFrequencyMeasure(termfreqTemp, mostFreq))
        # put it into our high values
        topXTerms[j] = mostFreq
        # Set the winning value to zero
        termfreqTemp[:,mostFreq] .= 0
    end
    return topXTerms
end
topTerms = mostCommonTerms(termfreq, 20)
# print the top terms
for term in topTerms
    println(terms[term])
end

# Question 4
function lookupTerm(terms, termString)
    for i in 1:size(terms,1)
        if terms[i] == termString
            return i
        end
    end
end

sacramentoIndex = lookupTerm(terms, "sacramento")
sacDocs = size(termfreq[:, sacramentoIndex].nzind,1)
println("'Sacramento' shows up in " * string(sacDocs) * " documents")

# Question 5
sacramentoIndex = lookupTerm(terms, "sacramento")
irsIndex = termfreq[:, sacramentoIndex].nzind[1]
println("Element #" * string(irsIndex) *"'s mission contains the word \"sacramento\", it is for the " * irs990[irsIndex]["name"])

# Question 6
function findCompaniesWorthMoreThan(irs990, cutoff)
    count = 0
    for company in irs990
        if parse(Int64, company["revenue"]) > cutoff
            count+=1
        end
    end
    return count
end

revenueAbove=100000000
println(string(findCompaniesWorthMoreThan(irs990, revenueAbove))*" non-profits have revenue above \$"*string(revenueAbove))


# Section 2
# Question 1
function findTopXCompanies(irs990, topX)
    topXCompanies = irs990[1:topX]
    topXCompaniesIndices = collect(1:topX)
    min = minCompany(topXCompanies)
    for companyIndex in topX+1:size(irs990,1)
        company = irs990[companyIndex]
        if parse(Int64, company["revenue"]) > min
            for i in 1:topX
                if parse(Int64, topXCompanies[i]["revenue"]) == min
                    topXCompanies[i] = company
                    topXCompaniesIndices[i] = companyIndex
                    min = minCompany(topXCompanies)
                    break
                end
            end
        end
    end
    return (topXCompanies, topXCompaniesIndices)
end

function minCompany(companyList)
    min = parse(Int64, companyList[1]["revenue"])
    for company in companyList
        if parse(Int64, company["revenue"]) < min
            min = parse(Int64, company["revenue"])
        end
    end
    return min
end

function maxCompany(companyList)
    max = parse(Int64, companyList[1]["revenue"])
    for company in companyList
        if parse(Int64, company["revenue"]) > max
            max = parse(Int64, company["revenue"])
        end
    end
    return max
end

subset = findTopXCompanies(irs990, 10000)
function findLargestCompany(irs990temp)
    largest = maxCompany(irs990temp)
    largestCompany = irs990temp[1]
    for company in irs990temp
        if parse(Int64, company["revenue"]) == largest
            largestCompany = company
        end
    end
    return largestCompany
end
println("largest company is " * string(findLargestCompany(irs990)["name"]))

# Question 3
termfreq = Serialization.deserialize("termfreq.jldata")
termfreqsubset = termfreq[subset[2],:]
function removeTermsThatAppearLessThanX(termfreqtemp, lessThanX)
    keepTerms = []
    matrixSize = size(termfreqtemp,2)
    for i in 1:size(termfreqtemp,2)
        term = termfreqtemp[:, i]
        if size(term.nzval,1) >= 2
            push!(keepTerms,i)
        end
    end
    return keepTerms
    # return termfreqtemp[1:end, keepTerms]
end

termfreqsubset = removeTermsThatAppearLessThanX(termfreqsubset, 2)
println("I found " * string(size(termfreqsubset,2)) * " words with 2 or more occurrences")

# Part 3
# Question 1
# convert to a dense matrix
termfreqsubset = collect(termfreqsubset)
# Transform the data
termfreqsubset_trans = transpose(termfreqsubset)
# Create PCA1
pca1 = fit(PCA, termfreqsubset_trans, maxoutdim = 10)

# Question 2


# Question 3
# create projection of absolute values
proj = projection(pca1)
absProj = abs.(proj)
firstPCProj = absProj[1:end, 1]
termIndicies = sortperm(firstPCProj)
# Most used words
terms[termfreqsubset[termIndicies]]

# Section 4
# Question 1
clusteringMatrix = transform(pca1,termfreqsubset_trans)
k2 = Clustering.kmeans(clusteringMatrix, 2)
grp1 = k2.assignments .== 1
grp2 = k2.assignments .== 2
grp3 = k2.assignments .== 3

println("Size of group 1 is " *string(size(clusteringMatrix[:,grp1])[2]))
println("Size of group 2 is " *string(size(clusteringMatrix[:,grp2])[2]))
println("Size of group 3 is " *string(size(clusteringMatrix[:,grp3])[2]))

# Question 2
function close_centroids(knn_model)
    groups = knn_model.assignments
    k = length(unique(groups))
    n = length(groups)
    result = fill(0, k)
    for ki in 1:k
        cost_i = fill(Inf, n)
        group_i = ki .== groups 
        cost_i[group_i] = knn_model.costs[group_i]
        result[ki] = argmin(cost_i)
    end
    result
end

cc = close_centroids(k2)
# get 3 closest irs filings
closestFilings = irs990[subset[2][cc]]

# Question 3
group1 = irs990[subset[2][grp1]]
group2 = irs990[subset[2][grp2]]
group3 = irs990[subset[2][grp3]]