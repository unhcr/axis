# Module: summarize.py
# Usage: python summarize.py [token] -d [database yml]
# ---------------------------------------------------------------------------
# It takes the narrative texts that satisfy the query and summarizes
# the text into a summary that is 1/4 of the length of the original text
# or has no more sentences than the number of paragraphs in the original text.
# It summarizes the French portion and the English portion of the text
# separately.

import nltk
import csv
from collections import *
from nltk.corpus import stopwords
import string
import networkx as nx
import warnings
import psycopg2
import random
import yaml
import sys
import argparse
import json

# warnings.filterwarnings("ignore")

class Summarizer:

  ID_NAMES = [
      'operation_ids',
      'plan_ids',
      'ppg_ids',
      'goal_ids',
      'output_ids',
      'problem_objective_ids',
      ]

  def __init__(self, db_path = 'config/database.yml', env = 'development', language = 'english',
      args = '{}', max_chars = 500, max_sentences = 150, sample = None):

    self.env = env
    try:
      self.db_config = yaml.load(open(db_path, 'rb'))[self.env]
    except IOError as e:
      print "Unable to open database config file at: %s" % db_path
      exit(1)

    self.language = language
    self.text = ''
    self.sample = sample
    self.args = json.loads(args)
    self.max_chars = max_chars
    self.max_sentences = max_sentences

    self.stopWords = dict()
    self.stopWords['english'] = set(stopwords.words('english'))
    self.stopWords['french'] = set(stopwords.words('french'))

  # Method: summarize
  # Usage: summary = summarize(text)
  # ----------------------------------------------
  # It takes a text and summarizes it using TextRank
  # algorithm. If the text is too long (> 150 sentences),
  # then it randomly picks 150 sentences before running TextRank.
  def summarize(self):

    if not self.text:
      self.text = self.query()

    sent_list = nltk.tokenize.sent_tokenize(self.text)

    # deletes sentences that are only made of punctuations
    sent_list = [sent for sent in sent_list if self.checkValidSent(sent)]

    # makes a list of paragraphs - used to count the number of paragraphs
    pg = self.text.splitlines(0)
    pg = [par for par in pg if par != '']

    # if there are too many sentences, this will pick 150 random sentences
    if len(sent_list) > self.max_sentences:
      sent_list = random.sample(sent_list, self.max_sentences)

    # makes graph to use for pagerank
    text_graph = self.buildGraph(sent_list)

    sent_scores = nx.pagerank(text_graph, weight = 'weight')

    sent_sorted = sorted(sent_scores, key = sent_scores.get, reverse = True)
    summary = ""
    sent_count = 0
    # selects a number of the most salient sentences
    while sent_sorted:
      sent = sent_sorted.pop(0)
      sent_count += 1

      # Break when the summary is more than
      if len(sent) + len(summary) >= self.max_chars:
          break

      summary += sent + ' '

    return summary

  # Method: buildGraph
  # Usage: graph = buildGraph(sentList)
  # -------------------------------------------
  # It takes a list of sentences and builds a graph
  # where each node is a sentence and the weight of an edge
  # is the intersection score of its two endpoints.

  def buildGraph(self, sentList):
    gr = nx.Graph()
    gr.add_nodes_from(sentList)

    for sent1 in sentList:
      for sent2 in sentList:
        if sent1 != sent2:
          gr.add_edge(sent1, sent2, weight=inter_score(sent1, sent2))

    return gr

  # Method: deletePunc
  # Usage: tokens = deletePunc(tokens)
  # ---------------------------------------------------
  # It takes a tokenized text and returns the text with all
  # punctuations stripped.

  def deletePunc(self, tokens):
      return [token for token in tokens if token not in string.punctuation]

  # Method: checkValidSent
  # Usage: if checkValidSent(sent)
  # --------------------------------------
  # It takes a sentence and determines if
  # the sentence has non-punctuation tokens
  # in it.
  def checkValidSent(self, sent):
    tok = nltk.word_tokenize(sent)
    tok = self.deletePunc(tok)
    return tok != []

  # Method: query
  # Usage: query
  # -----------------------------------------------
  # It takes the address of the yml file and queries
  # the database to get the texts needed for the particular
  # query.
  def query(self):

    condition_str = self.query_string()

    database = psycopg2.connect(user = self.db_config['username'],
        password = self.db_config['password'],
        database = self.db_config['database'],
        host = self.db_config['host'])

    cursor = database.cursor()

    query_str = "SELECT usertxt FROM narratives " + condition_str

    cursor.execute(query_str)

    text = ''

    for usertxt in cursor:
      if usertxt[0] is not None:
        partial = usertxt[0]
        partial = partial.replace('\\\\n', '\n')
        partial = partial.replace('\\n', '\n')
        language = self.detectLanguages(nltk.word_tokenize(partial))

        if language == self.language:
          text += '\n' + partial

    database.close()
    return text

  # Method: query_string
  # Usage: querySt = query_string()
  # ----------------------------------------------
  # With the lists of conditions, it makes the condition
  # part of the SQL query string to be used.
  def query_string(self):
    conditions = []

    for id_name in self.ID_NAMES:
      if id_name in self.args and len(self.args[id_name]) > 0:
        singular = id_name[:len(id_name) - 1]
        conditions.append("%s IN ('%s')" % (singular, ("','".join(self.args[id_name]))))

    condition_str = "WHERE (report_type = '%s') AND (year = %s) AND %s" % (self.args['report_type'], self.args['year'], ' AND '.join(conditions))

    return condition_str

  # Method: detectLanguages
  # Usage: if detectLanguages(tokens) == 'english': ...
  # ----------------------------------------------------
  # It takes a tokenized text and determines if the text is
  # in French or English.
  def detectLanguages(self, tokens):
    words = [word.lower() for word in tokens]
    words_set = set(words)
    eng_num = self.stopWords['english'].intersection(words_set)
    fre_num = self.stopWords['french'].intersection(words_set)
    if len(eng_num) > len(fre_num):
        return 'english'
    else:
        return 'french'

  # Method: inter_score
  # Usage: score = inter_score(sent1, sent2)
  # ---------------------------------------------------
  # It takes two sentences and returns the intersection
  # score of the sentences.

  def inter_score(sent1, sent2):
    tok1 = nltk.word_tokenize(sent1)
    tok2 = nltk.word_tokenize(sent2)
    tok1 = deletePunc(tok1)
    tok2 = deletePunc(tok2)
    return float(2 * len([x for x in tok1 if x in tok2]))/(len(tok1) + len(tok2))

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description = 'Summarizer!')
    parser.add_argument('-s', '--sample', help= 'Use sample query', required = False)
    parser.add_argument('-d', '--database', help= 'database yml file path', required = True)
    parser.add_argument('-a', '--args', help= 'json ids for narrative summary')
    parser.add_argument('-l', '--lang',
        help= 'select langauge for summary (french or english)',
        required = False,
        argument_default = 'english')
    parser.add_argument('-e', '--env',
        help = 'database environment',
        required = False,
        argument_default='development')

    args = parser.parse_args()

    summarizer = Summarizer(path = args.database,
        env = args.env,
        language = args.language,
        args = args.args or json_str,
        sample = args.sample)

    summary = summarizer.summarize()

    print "Summary: "
    print summary
