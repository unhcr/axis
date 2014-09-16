from summarize import Summarizer

import psycopg2
import yaml
from datetime import date, datetime, timedelta
import subprocess

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

    data_narrative_2 = {
      'id': 1235,
      'operation_id': 'LISA',
      'plan_id': 'ABC',
      'ppg_id': 'DEF',
      'goal_id': 'EFG',
      'problem_objective_id': 'FGH',
      'output_id': 'GHI',
      'usertxt': 'the second quick brown fox.',
      'createusr': 'rudolph',
      'report_type': 'Mid Year Report',
      'year': 2013,
      'created_at': datetime.now(),
      'updated_at': datetime.now()
    }

    data_narrative_3 = {
      'id': 1236,
      'operation_id': 'JEFF',
      'plan_id': 'ABC',
      'ppg_id': 'DEF',
      'goal_id': 'EFG',
      'problem_objective_id': 'FGH',
      'output_id': 'GHI',
      'usertxt': u'Modern humans (Homo sapiens or Homo sapiens sapiens) are the only extant members of the hominin clade, a branch of great apes characterized by erect posture and bipedal locomotion; manual dexterity and increased tool use; and a general trend toward larger, more complex brains and societies.[3][4] Early hominids, such as the australopithecines who had more apelike brains and skulls, are less often thought of or referred to as "human" than hominids of the genus Homo[5] some of whom used fire, occupied much of Eurasia, and gave rise to [6][7] anatomically modern Homo sapiens in Africa about 200,000 years ago where they began to exhibit evidence of behavioral modernity around 50,000 years ago and migrated out in successive waves to occupy[8] all but the smallest, driest, and coldest lands. In the last 100 years, this has extended to permanently manned bases in Antarctica, on offshore platforms, and orbiting the Earth. The spread of humans and their large and increasing population has had a destructive impact on large areas of the environment and millions of native species worldwide. Advantages that explain this evolutionary success include a relatively larger brain with a particularly well-developed neocortex, prefrontal cortex and temporal lobes, which enable high levels of abstract reasoning, language, problem solving, sociality, and culture through social learning. Humans use tools to a much higher degree than any other animal, are the only extant species known to build fires and cook their food, as well as the only extant species to clothe themselves and create and use numerous other technologies and arts. \
\
      Humans are uniquely adept at utilizing systems of symbolic communication such as language and art for self-expression, the exchange of ideas, and organization. Humans create complex social structures composed of many cooperating and competing groups, from families and kinship networks to states. Social interactions between humans have established an extremely wide variety of values,[9] social norms, and rituals, which together form the basis of human society. The human desire to understand and influence their environment, and explain and manipulate phenomena, has been the foundation for the development of science, philosophy, mythology, and religion. The scientific study of humans is the discipline of anthropology. \
\
Humans began to practice sedentary agriculture about 12,000 years ago, domesticating plants and animals, thus allowing for the growth of civilization. Humans subsequently established various forms of government, religion, and culture around the world, unifying people within a region and leading to the development of states and empires. The rapid advancement of scientific and medical understanding in the 19th and 20th centuries led to the development of fuel-driven technologies and improved health, causing the human population to rise exponentially. By 2012 the global human population was estimated to be around 7 billion.\
\
      ',
      'createusr': 'rudolph',
      'report_type': 'Mid Year Report',
      'year': 2013,
      'created_at': datetime.now(),
      'updated_at': datetime.now()
    }

    cursor.execute(add_narrative, data_narrative)
    cursor.execute(add_narrative, data_narrative_2)
    cursor.execute(add_narrative, data_narrative_3)

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

  def test_summarize_simple(self):
    args = '{"output_ids": [], \
      "ppg_ids": ["DEF", "LTFL", "LP61"], \
      "problem_objective_ids": ["FGH"], \
      "goal_ids": ["EFG"], \
      "operation_ids": ["BEN", "7VC"], \
      "report_type": "Mid Year Report",  \
      "year": 2013 }'

    s = Summarizer(env = 'test', args = args)

    summary = s.summarize()

    assert summary.strip() == 'the quick brown fox.'

  def test_summarize_multipe(self):
    args = '{"output_ids": [], \
      "ppg_ids": ["DEF", "LTFL", "LP61"], \
      "problem_objective_ids": ["FGH"], \
      "goal_ids": ["EFG"], \
      "operation_ids": ["BEN", "LISA"], \
      "report_type": "Mid Year Report",  \
      "year": 2013 }'

    s = Summarizer(env = 'test', args = args)

    summary = s.summarize()
    assert summary.strip() == 'the quick brown fox. the second quick brown fox.'

  def test_summarize_large(self):
    args = '{"output_ids": [], \
      "ppg_ids": ["DEF", "LTFL", "LP61"], \
      "problem_objective_ids": ["FGH"], \
      "goal_ids": ["EFG"], \
      "operation_ids": ["BEN", "LISA", "JEFF"], \
      "report_type": "Mid Year Report",  \
      "year": 2013 }'

    max_chars = 500

    s = Summarizer(env = 'test', args = args, max_chars = max_chars)

    summary = s.summarize()
    assert len(summary) <= max_chars

  def test_summarize_command_line(self):
    args = '{"output_ids": [], \
      "ppg_ids": ["DEF", "LTFL", "LP61"], \
      "problem_objective_ids": ["FGH"], \
      "goal_ids": ["EFG"], \
      "operation_ids": ["BEN", "LISA"], \
      "report_type": "Mid Year Report",  \
      "year": 2013 }'

    cmd = [
        'python',
        'script/python/summarizer/summarize.py',
        '-a',
        args,
        '-e',
        'test',
        '-d',
        'config/database.yml',
        ]

    out = subprocess.check_output(cmd)

    assert out.strip() == 'the quick brown fox. the second quick brown fox.'
