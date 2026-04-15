#!/bin/sh

#  pythonside.pyt.sh
#  whisk
#
#  Created by Brianna Shen on 2024-08-23.
#

# script.py
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

def analyze(text):
    analyzer = SentimentIntensityAnalyzer()
    return analyzer.polarity_scores(text)

if __name__ == "__main__":
    print(analyze("This is a great day!"))

import Foundation

import math
import re
import string
from itertools import product
import nltk.data
from nltk.util import pairwise

class VaderConstants:
    B_INCR = 0.293
    B_DECR = -0.293
    C_INCR = 0.733
    N_SCALAR = -0.74

    NEGATE = {
        "aint", "arent", "cannot", "cant", "couldnt", "darent", "didnt", "doesnt", "ain't", "aren't", "can't",
        "couldn't", "daren't", "didn't", "doesn't", "dont", "hadnt", "hasnt", "havent", "isnt", "mightnt", "mustnt",
        "neither", "don't", "hadn't", "hasn't", "haven't", "isn't", "mightn't", "mustn't", "neednt", "needn't",
        "never", "none", "nope", "nor", "not", "nothing", "nowhere", "oughtnt", "shant", "shouldnt", "uhuh",
        "wasnt", "werent", "oughtn't", "shan't", "shouldn't", "uh-uh", "wasn't", "weren't", "without", "wont",
        "wouldnt", "won't", "wouldn't", "rarely", "seldom", "despite"
    }

    BOOSTER_DICT = {
        "absolutely": B_INCR, "amazingly": B_INCR, "awfully": B_INCR, "completely": B_INCR, "considerably": B_INCR,
        "decidedly": B_INCR, "deeply": B_INCR, "effing": B_INCR, "enormously": B_INCR, "entirely": B_INCR,
        "especially": B_INCR, "exceptionally": B_INCR, "extremely": B_INCR, "fabulously": B_INCR, "flipping": B_INCR,
        "flippin": B_INCR, "fricking": B_INCR, "frickin": B_INCR, "frigging": B_INCR, "friggin": B_INCR, "fully": B_INCR,
        "fucking": B_INCR, "greatly": B_INCR, "hella": B_INCR, "highly": B_INCR, "hugely": B_INCR, "incredibly": B_INCR,
        "intensely": B_INCR, "majorly": B_INCR, "more": B_INCR, "most": B_INCR, "particularly": B_INCR, "purely": B_INCR,
        "quite": B_INCR, "really": B_INCR, "remarkably": B_INCR, "so": B_INCR, "substantially": B_INCR, "thoroughly": B_INCR,
        "totally": B_INCR, "tremendously": B_INCR, "uber": B_INCR, "unbelievably": B_INCR, "unusually": B_INCR, "utterly": B_INCR,
        "very": B_INCR, "almost": B_DECR, "barely": B_DECR, "hardly": B_DECR, "just enough": B_DECR, "kind of": B_DECR,
        "kinda": B_DECR, "kindof": B_DECR, "kind-of": B_DECR, "less": B_DECR, "little": B_DECR, "marginally": B_DECR,
        "occasionally": B_DECR, "partly": B_DECR, "scarcely": B_DECR, "slightly": B_DECR, "somewhat": B_DECR,
        "sort of": B_DECR, "sorta": B_DECR, "sortof": B_DECR, "sort-of": B_DECR,
    }

    SPECIAL_CASE_IDIOMS = {
        "the shit": 3, "the bomb": 3, "bad ass": 1.5, "yeah right": -2, "cut the mustard": 2, "kiss of death": -1.5,
        "hand to mouth": -2,
    }

    REGEX_REMOVE_PUNCTUATION = re.compile(f"[{re.escape(string.punctuation)}]")
    PUNC_LIST = [".", "!", "?", ",", ";", ":", "-", "'", '"', "!!", "!!!", "??", "???", "?!?", "!?!", "?!?!", "!?!?"]

    def __init__(self):
        pass

    def negated(self, input_words, include_nt=True):
        neg_words = self.NEGATE
        if any(word.lower() in neg_words for word in input_words):
            return True
        if include_nt:
            if any("n't" in word.lower() for word in input_words):
                return True
        for first, second in pairwise(input_words):
            if second.lower() == "least" and first.lower() != "at":
                return True
        return False

    def normalize(self, score, alpha=15):
        norm_score = score / math.sqrt((score * score) + alpha)
        return norm_score

    def scalar_inc_dec(self, word, valence, is_cap_diff):
        scalar = 0.0
        word_lower = word.lower()
        if word_lower in self.BOOSTER_DICT:
            scalar = self.BOOSTER_DICT[word_lower]
            if valence < 0:
                scalar *= -1
            if word.isupper() and is_cap_diff:
                if valence > 0:
                    scalar += self.C_INCR
                else:
                    scalar -= self.C_INCR
        return scalar

class SentiText:
    def __init__(self, text, punc_list, regex_remove_punctuation):
        if not isinstance(text, str):
            text = str(text.encode("utf-8"))
        self.text = text
        self.PUNC_LIST = punc_list
        self.REGEX_REMOVE_PUNCTUATION = regex_remove_punctuation
        self.words_and_emoticons = self._words_and_emoticons()
        self.is_cap_diff = self.allcap_differential(self.words_and_emoticons)

    def _words_plus_punc(self):
        no_punc_text = self.REGEX_REMOVE_PUNCTUATION.sub("", self.text)
        words_only = no_punc_text.split()
        words_only = {w for w in words_only if len(w) > 1}
        punc_before = {"".join(p): p[1] for p in product(self.PUNC_LIST, words_only)}
        punc_after = {"".join(p): p[0] for p in product(words_only, self.PUNC_LIST)}
        words_punc_dict = punc_before
        words_punc_dict.update(punc_after)
        return words_punc_dict

    def _words_and_emoticons(self):
        wes = self.text.split()
        words_punc_dict = self._words_plus_punc()
        wes = [we for we in wes if len(we) > 1]
        for i, we in enumerate(wes):
            if we in words_punc_dict:
                wes[i] = words_punc_dict[we]
        return wes

    def allcap_differential(self, words):
        is_different = False
        allcap_words = 0
        for word in words:
            if word.isupper():
                allcap_words += 1
        cap_differential = len(words) - allcap_words
        if 0 < cap_differential < len(words):
            is_different = True
        return is_different

class SentimentIntensityAnalyzer:
    def __init__(self, lexicon_file="vader_lexicon.txt"):
        self.lexicon = self.make_lex_dict(lexicon_file)
        self.constants = VaderConstants()

    def make_lex_dict(self, lexicon_file):
        lex_dict = {}
        with open(lexicon_file, 'r') as f:
            for line in f:
                word, measure = line.strip().split("\t")[0:2]
                lex_dict[word] = float(measure)
        return lex_dict

    def polarity_scores(self, text):
        sentitext = SentiText(
            text, self.constants.PUNC_LIST, self.constants.REGEX_REMOVE_PUNCTUATION
        )
        sentiments = []
        words_and_emoticons = sentitext.words_and_emoticons
        for item in words_and
