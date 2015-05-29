# Simple Markov Chain creator
# heavily inspired by https://github.com/TehMillhouse/PyMarkovChain
module SimpleMarkovChain

import JSON

export MarkovChain, generateDatabase, generateString

type MarkovChain
    source_file_path    ::String
    #TODO: might be useful to make this a tuple at some point
    db                  ::Dict{Any,Any}

    function MarkovChain(source_file_path, parse_dataset::Function)
        this = new(source_file_path, Dict{Any,Any}())
        # do initial generation
        generateDatabase(this, parse_dataset(this.source_file_path))

        function updateCallback(filename, events, status)
            generateDatabase(this, parse_dataset(this.source_file_path))
        end

        @async begin
            while true
                wf = watch_file(updateCallback, source_file_path)
                wait(wf)
            end
        end

        this
    end
end

type MarkovLink
    total_count ::Int64
    next_words ::Dict{String, Int64}

    MarkovLink() = new(0, Dict{String, Int64}())
end

function generateDatabase(mc::MarkovChain, textsample; sentence_sep=r"\.|\?|!|\n", n_gram_size=2)
    sentences = split(textsample, sentence_sep)
    db = deepcopy(mc.db)

    for sentence in sentences
        words = split(strip(sentence),r"\s")
        if length(words) == 0
            continue
        end

        #first word follows a sentence end
        #nullstr indicated beginning of sentence
        db[[""]] = MarkovLink()
        start_link = db[[""]]
        if ! haskey(start_link.next_words, words[1])
            start_link.next_words[words[1]] = 0
        end
        start_link.total_count += 1
        start_link.next_words[words[1]] = 1

        for n_size in 1:n_gram_size
            if n_size > length(words)
                continue
            end

            for i in 1 : length(words)
                n_gram_index = i + n_size - 1
                n_index = i + n_size
                if n_index > length(words)
                    continue
                end

                n_gram = words[ i : n_gram_index ]
                next_word = words[ n_index ]

                if ! haskey(db, n_gram)
                    db[n_gram] = MarkovLink()
                end
                link = db[n_gram]
                link.total_count += 1

                if ! haskey(link.next_words, next_word)
                    link.next_words[next_word] = 0
                end

                link.next_words[next_word] += 1
            end

            # take care of the end of sentence stuff
            end_tuple = words[ end - (n_size - 1) : end]
            if ! haskey(db, end_tuple)
                db[end_tuple] = MarkovLink()
            end
            end_link = db[end_tuple]
            end_link.total_count += 1

            if ! haskey(end_link.next_words, end_tuple)
                end_link.next_words[""] = 0
            end
            end_link.next_words[""] += 1
        end
    end

    mc.db = db
end

function generateString(mc::MarkovChain, seed="")
    
end

function _accumulateString(mc::MarkovChain)
    
end

function _nextWord(mc::MarkovChain, last_words::Array{String,1})
    db = mc.db
    if last_words != [""]:
        while ! haskey(db, last_words) && length(last_words) > 0
            last_words = last_words[2:end]
        end
    end
    if length(last_words) == 0
        # bailing early with empty string
        return ""
    end

    next_words = db[last_words]
    sample = rand()
    # since rounding errors might make us miss out on some words
    maxprob = 0.0
    maxprobword = ""
    for next_link in next_words
        # remember which word had the highest probability
        # this is the word we'll default to if we can't find anythin else
        if next_link > maxprob
            maxprob = probmap[candidate]
            maxprobword = candidate
        if sample > probmap[candidate]
            sample -= probmap[candidate]
        else
            return candidate
        end
    end
    # getting here means we haven't found a matching word. :(
    maxprobword
end

end

