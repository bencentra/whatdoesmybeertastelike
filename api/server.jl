using Morsel

include("./markovchain.jl")
using SimpleMarkovChain

app = Morsel.app()

markov = MarkovChain("./reviews.json")

route(app, GET, "/") do req, res
    println(markov.db)
    generateString(markov)
    "asdf\n"
end

start(app, 8808)

