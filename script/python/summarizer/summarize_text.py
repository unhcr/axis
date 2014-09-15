from summarize import Summarizer

import psycopg2
import yaml
from datetime import date, datetime, timedelta

class TestSummarizer:

  def setup(self):

    db_config = yaml.load(open('config/database.yml', 'rb'))['test']

    self.database = psycopg2.connect(user = db_config['username'],
        password = db_config['password'],
        database = db_config['database'],
        host = db_config['host'])

    cursor = self.database.cursor()

    # Load up database with sample data
    add_narrative = ("INSERT INTO narratives "
                     "(id, operation_id, plan_id, goal_id, ppg_id, problem_objective_id, output_id, usertxt, createusr, report_type, year, created_at, updated_at) "
                     "VALUES (%(id)s, %(operation_id)s, %(plan_id)s, %(goal_id)s, %(ppg_id)s, %(problem_objective_id)s, %(output_id)s, %(usertxt)s, %(createusr)s, %(report_type)s, %(year)s, %(created_at)s, %(updated_at)s)")

    data_narrative = {
      'id': 1234,
      'operation_id': 'BEN',
      'plan_id': 'ABC',
      'ppg_id': 'DEF',
      'goal_id': 'EFG',
      'problem_objective_id': 'FGH',
      'output_id': 'GHI',
      'usertxt': 'the quick brown fox.',
      'createusr': 'rudolph',
      'report_type': 'Mid Year Report',
      'year': 2013,
      'created_at': datetime.now(),
      'updated_at': datetime.now()
    }

    cursor.execute(add_narrative, data_narrative)

    self.database.commit()
    cursor.close()

  def teardown(self):
    cursor = self.database.cursor()
    cursor.execute('DELETE FROM narratives')

    self.database.commit()

    cursor.close()
    self.database.close()


  def test_setup(self):
    s = Summarizer(env = 'test')

    assert s.env == 'test'
    assert s.language == 'english'

  def test_query_string(self):

    args = '{"output_ids": [], \
      "ppg_ids": ["LRZQ", "LTFL", "LP61"], \
      "problem_objective_ids": ["c70f5d80-a7cd-4d68-a085-aa04702c0fea"], \
      "goal_ids": ["EM"], \
      "operation_ids": ["BEN", "7VC"], \
      "report_type": "Mid Year Report",  \
      "year": 2013 }'

    s = Summarizer(env = 'test', args = args)

    assert len(s.args['operation_ids']) == 2
    assert len(s.args['output_ids']) == 0
    assert len(s.args['ppg_ids']) == 3
    assert int(s.args['year']) == 2013
    assert s.args['report_type'] == 'Mid Year Report'

    query_string = s.query_string()

    assert s.args['report_type'] in query_string
    assert str(s.args['year']) in query_string
    assert s.args['goal_ids'][0] in query_string
    assert s.args['operation_ids'][1] in query_string


  def test_query(self):
    args = '{"output_ids": [], \
      "ppg_ids": ["DEF", "LTFL", "LP61"], \
      "problem_objective_ids": ["FGH"], \
      "goal_ids": ["EFG"], \
      "operation_ids": ["BEN", "7VC"], \
      "report_type": "Mid Year Report",  \
      "year": 2013 }'

    s = Summarizer(env = 'test', args = args)

    text = s.query()

    assert text.strip() == 'the quick brown fox.'

  def test_summarize(self):
    print 'summary'
