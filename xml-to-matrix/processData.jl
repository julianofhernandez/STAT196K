using EzXML
using TextAnalysis

# Global variables
dataDir = "ignore_2019"


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
        if description == ""
            println(file + " description not processed")
            filesNotProcessed+=1
        else if totalWorkers < 0
            println(file + " workers not processed not processed")
            filesNotProcessed+=1
        else
            push!(descriptions, description)
        end
    end
    println(filesNotProcessed * " out of " * filesProcessed * " were not processed")
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
end

files = getFiles(dataDir)
descriptions = getDescriptions(files)
getDocumentTermMatrix(descriptions)