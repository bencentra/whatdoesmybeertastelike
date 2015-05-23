using Morsel

include("./markovchain.jl")
using SimpleMarkovChain

app = Morsel.app()

function review_parse(source_file_path)
    reviews = JSON.parsefile(source_file_path)
    review_descs = [r["desc"] for r in reviews]
    join(review_descs, " ")
end

markov = MarkovChain("./reviews.json", review_parse)

route(app, GET, "/") do req, res
    println(markov.db)
    generateString(markov)
    "asdf\n"
end

start(app, 8808)

