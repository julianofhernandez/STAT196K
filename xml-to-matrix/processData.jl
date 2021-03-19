using EzXML
using TextAnalysis
using Dates

# Global variables
dataDir = "ignore_data"


function getFiles(dataDir)
    readdir(dataDir, join=true)
end

function getData(files)
    descriptions = String[]
    filesProcessed = 0
    filesNotProcessed= 0
    for file in files
        filesProcessed += 1
        # description
        description = getDescription(file)
        totalWorkers = getTotalWorkers(file)
        # println(totalWorkers)
        if description == ""
            # println(file * " description not processed")
            filesNotProcessed+=1
        elseif totalWorkers < 0
            # println(file * " workers not processed not processed")
            filesNotProcessed+=1
        else
            push!(descriptions, description)
        end
    end
    #! Need to print int correctly
    println(string(filesNotProcessed) * " out of " * string(filesProcessed) * " were not processed")
    open("myfile.txt", "a") do io
        write(io, string(filesNotProcessed) * " out of " * string(filesProcessed) * " were not processed")
    end
    return descriptions
end

function getDescription(file)
    doc = readxml(file)
    rootElement = root(doc)
    # Get the description
    missionDesc = findfirst("//MissionDesc", rootElement)
    if isnothing(missionDesc)
        missionDesc = findfirst("//PrimaryExemptPurposeTxt", rootElement)
    end

    if isnothing(missionDesc)
        return ""
    else
        return nodecontent(missionDesc)
    end
end

function getTotalWorkers(file)
    doc = readxml(file)
    rootElement = root(doc)
    # Get employees
    totalEmployees = findfirst("//EmployeeCnt", rootElement)
    # Get volunteers
    totalVolunteers = findfirst("//TotalVolunteersCnt", rootElement)

    if isnothing(totalEmployees) & isnothing(totalVolunteers)
        return -1
    elseif isnothing(totalVolunteers)
        totalEmployees = nodecontent(totalEmployees)
        return parse(Int64, totalEmployees)
    elseif isnothing(totalEmployees)
        totalVolunteers = nodecontent(totalVolunteers)
        return parse(Int64, totalVolunteers)
    else
        totalEmployees = nodecontent(totalEmployees)
        totalVolunteers = nodecontent(totalVolunteers)
        totalEmployees = parse(Int64, totalEmployees)
        totalVolunteers = parse(Int64, totalVolunteers)
        return totalEmployees + totalVolunteers
    end
end

function getDocumentTermMatrix(descriptions)
    sdList = StringDocument[]
    for description in descriptions
        sd = StringDocument(description)
        push!(sdList, sd)
    end
    c = Corpus(sdList)
    remove_case!(c)
    prepare!(c, strip_punctuation)
    stem!(c)
    update_lexicon!(c)

    d = DocumentTermMatrix(c)
    dtm(d)
    dtm(d, :dense)
    return d
end

open("myfile.txt", "a") do io
    write(io, Dates.format(now(), "HH:MM"))
end
@time files = getFiles(dataDir)
@time descriptions = getData(files)
@time matrix = getDocumentTermMatrix(descriptions)
println(matrix.terms)
println("Length of DTM")
println(size(matrix.terms))
open("myfile.txt", "a") do io
    write(io, string(size(matrix.terms)))
    write(io, Dates.format(now(), "HH:MM"))
end