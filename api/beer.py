from pymarkovchain import MarkovChain
import json


class BeerMarkov():

    def __init__(self, reviews_file, markov_dir):
        self._reviews_file = reviews_file
        self._markov_dir = markov_dir
        self._markov = MarkovChain(markov_dir + '/beer_desc')
        self._name_markov = MarkovChain(markov_dir + '/beer_name')

    def refresh_database(self):
        with open(self._reviews_file, 'r') as review_data:
            reviews = json.load(review_data)

        reviews_string = [r['desc'] for r in reviews]
        names_string = [r['name'] for r in reviews]

        new_markov = MarkovChain(self._markov_dir + '/beer_desc')
        new_markov.generateDatabase(' '.join(reviews_string))

        new_name_markov = MarkovChain(self._markov_dir + '/beer_name')
        new_name_markov.generateDatabase('.'.join(names_string))

        self._markov = new_markov
        self._name_markov = new_name_markov

    def get_review(self):
        return  self._markov.generateString() + '. ' + \
            self._markov.generateString()
