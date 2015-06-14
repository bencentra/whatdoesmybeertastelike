from flask import Flask, g, current_app
import requests
import json
from celery import Celery
from celery.task import periodic_task
from celery.task.schedules import crontab
from beer import BeerMarkov
import subprocess


app = Flask(__name__)
app.config.from_pyfile('settings.py')
app.config.from_pyfile('secrets.py')


beer_markov = BeerMarkov(app.config['REVIEWS_FILE'], app.config['MARKOV_DIR'])


@app.route('/review', methods=['GET'])
def beer():
    return beer_markov.get_review()

celery = Celery(app.name, broker=app.config['CELERY_BROKER_URL'])
celery.conf.update(app.config)


@periodic_task(run_every=crontab(hour='*', minute='*/30', day_of_week='*'))
def update_reviews():
    with app.app_context():
        apikey_param = {'apikey': app.config['BEER_REVIEW_API_KEY']}
        data = requests.get(app.config['BEER_REVIEW_URL'],
                            params=apikey_param).json()

        review_flat = [ d['review'] for d in data['results']['collection1'] ]

        with open(app.config['REVIEWS_FILE'], 'r') as existing_reviews_file:
            reviews_parsed = json.load(existing_reviews_file)

        for r in review_flat:
            # the reviews currently have their data in newline separated fields
            # *desc captures all the description lines into a one element array
            name, brewery, info, rating, breakdown, *desc, user = \
                r['text'].split('\n')
            reviews_parsed.append({
                'name': name,
                'brewery': brewery,
                'info': info,
                'breakdown': breakdown,
                'desc': desc[0],
                'user': user
            })

        with open(app.config['REVIEWS_FILE'], 'w') as reviews_file:
            # will keep the pretty printing for debugging
            reviews_file.write(
                    json.dumps(reviews_parsed, existing_reviews_file,
                               sort_keys=True, indent=4))
        # This is super dirty but I think it'll work well enough
        subprocess.check_output(['uwsgi', '--reload', '/tmp/uwsgi.pid'])


if __name__ == '__main__':
    app.run(host='localhost', port=8808, debug=True)

