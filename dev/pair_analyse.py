﻿#/usr/bin/env python2.7
"""
(see TODOS) 

INFO:

    Take TSV input for two languages

        lemmaa  lemmab
        lemmad  lemmae

    Run through two analysers and return output where the input lemma
    matches the output lemma

        addálas addálas+A+Sg+Nom <--
        addálas addálas+A+Attr <--
        addálas addit+V+TV+Der/las+A+Sg+Nom
        addálas addit+V+TV+Der/las+A+Attr+Attr

        antelias    antelias+A+Sg+Nom <--

    Then match the POSes from both the left and right, and if matching,
    return

        addálas_A_antelias

    Potential errors are prepended to each line:
    
        ? no analysis on right - 
        ? no analysis on left - 
        ? pos mismatch ([Adv] | [A]) - 

    For no analysis on right/left, attempt to show the opposite side's
    POS if available


EXAMPLE USAGE: 

    cat sme-fin-splitted.tsv | \
    grep -v 'ei SSS' | \
    python ../dev/pair_analyse.py \
           ~/gtsvn/gt/sme/bin/sme-norm.fst \
           ~/gtsvn/langs/fin/src/analyser-gt-norm.xfst

TODOS:

    TODO: have not completely implemented format_of_csv.txt notes.

    TODO: phrases with notes in parens:
            syöttää (pesäpallossa)
            (kankaan) leveys

          Should be able to get an analysis by stripping word in parens

    TODO: multiword phrases with no parens, which result in no analysis
          on right, but analysis on the left

            vuohčču_N_kapea vetinen jänkä

          Only way to get analysis from these would be to run through
          CG, and find the head, however that may be a bit much work?

"""

import sys, os

xfst_test = """
addálas addálas+A+Sg+Nom
addálas addálas+A+Attr
addálas addit+V+TV+Der/las+A+Sg+Nom
addálas addit+V+TV+Der/las+A+Attr+Attr

addálas addálas +?

addálas addálas+A+Sg+Nom
addálas addálas+A+Attr
addálas addit+V+TV+Der/las+A+Sg+Nom
addálas addit+V+TV+Der/las+A+Attr+Attr
"""

def Popen(cmd, data=False, ret_err=False, ret_proc=False):
    """
        Wrapper around subprocess Popen to save some time.
        Expects command and data, ideally data is already single unicode
        string.
    """
    import subprocess as sp
    PIPE = sp.PIPE
    proc = sp.Popen(cmd.split(' '), shell=False, 
                    stdout=PIPE, stderr=PIPE, stdin=PIPE)
    if data:
        if type(data) == str:
            try:
                data = data.encode('utf-8')
            except UnicodeDecodeError:
                pass
            except Exception, e:
                print >> STDERR, "omg, str"
                print >> STDERR, Exception, e
                sys.exit(2)
        if type(data) == unicode:
            try:
                data = str(data)
            except Exception, e:
                print >> STDERR, "omg, unicode"
                print >> STDERR, Exception, e
                sys.exit(2)
        kwargs = {'input': data}
    else:
        kwargs = {}

    output, err = proc.communicate(**kwargs)
    
    try:
        if err:
            raise Exception(cmd + err)
    except:
        pass

    if ret_err:
        return output, err
    else:
        return output

class Analyzer(object):

    lookup_tool = "/Users/pyry/bin/lookup"

    def parse_xfst(self, result):
        return map(
            self.parse_xfst_chunk,
            result.split('\n\n')
        )

    def parse_xfst_chunk(self, analysis_chunk):
        """
        addálas addálas+A+Sg+Nom
        addálas addálas+A+Attr
        addálas addit+V+TV+Der/las+A+Sg+Nom
        addálas addit+V+TV+Der/las+A+Attr+Attr

        ->

        {'lemma': 'addálas'
         'analyses': [
            {'lemma': 'addálas',
             'tag': 'A+Sg+Nom'
            },
            {'lemma': 'addálas',
             'tag': 'A+Sg+Attr'
            },
         ]
        }
        """

        analysis = {
            'lemma': False,
            'analyses': []
        }

        in_lemma = False
        for line in analysis_chunk.splitlines():
            _l = line.strip()
            if _l:
                _l = _l.split()
                if len(_l) == 2:
                    in_lemma, tag = _l
                    out_lemma, _, _tag = tag.partition('+')
                # unknown +?
                else:
                    in_lemma = _l[0]
                    tag = False
            else:
                continue

            if tag:
                if not analysis['lemma']:
                    analysis['lemma'] = in_lemma
                analysis['analyses'].append({
                    'lemma': out_lemma,
                    'tag': _tag
                })
            else:
                if not analysis['lemma']:
                    analysis['lemma'] = in_lemma
                analysis['analyses'] = False

        return analysis

    def getResult(self, _id, clean, matchOnly):
        _result = self.results.get(_id)

        if clean:
            _out = _result.get('out')
            if _out:
                _analyses = _out.get('analyses')

                if _analyses:
                    for a in _analyses:
                        if a:
                            a['tag'] = self.cleanTag(a.get('tag'))

                    _out['analyses'] = _analyses
                    _result['out'] = _out

        if matchOnly:
            _in = _result.get('in')
            def matchingLemmas(a):
                if a['lemma'] == _in:
                    return True
                else:
                    return False
            _out = _result.get('out')
            if _out:
                _analyses = _out.get('analyses')
                if _analyses:
                    _result['out']['analyses'] = filter(matchingLemmas, _analyses)

        return _result



    def incrementId(self):
        _id = '%s-%d' % (self.name, self.id_counter)
        self.id_counter += 1
        return _id

    def prepare(self, word):
        _id = self.incrementId()
        self.results[_id] = {
            'in': word,
            'out': False
        }
        return _id

    def lookup(self, _input):
        cmd = self.lookup_tool + " -flags mbTT -utf8 -d " + self.path

        try:
            lookups = Popen(cmd, _input)
        except OSError:
            print >> STDERR, "Problem in command: %s" % cmd
            sys.exit(2)
        
        lookups = lookups.decode('utf-8')
        return lookups
        
    def run(self):
        lookups = []
        for k, item in self.results.iteritems():
            lookups.append(item.get('in'))

        lookups = '\n'.join(lookups).encode('utf-8')
        result = self.lookup(lookups)
        _res = self.parse_xfst(result)

        for res_dict, result in zip(self.results.items(), _res):
            k, d = res_dict
            d['out'] = result
            self.results[k] = d.copy()

    def __init__(self, path, name='L', tag_cleaner=lambda x: x):
        from collections import OrderedDict
        self.results = OrderedDict()
        self.name = name
        self.path = path
        self.id_counter = 0
        self.cleanTag = tag_cleaner


def main(left, right):

    def tag_clean_left(analysis):
        " Strip Hum/Ani/Plant, etc "
        remove = [
            'Ani', 'Body', 'Build', 'Clth', 'Edu', 'Event', 'Fem',
            'Food', 'Group', 'Hum', 'Mal', 'Measr', 'Obj', 'Org',
            'Plant', 'Plc', 'Route', 'Sur', 'Time', 'Txt', 'Veh',
            'Wpn', 'Wthr',
            'v1', 'v2', 'v3',
        ]
        tags = analysis.split('+')
        _tags = filter(lambda x: True if x not in remove else False ,tags)
        _tags = '+'.join(_tags)
        return _tags.split('+')[0]

    def tag_clean_right(analysis):
        " Switch Verb to V "
        analysis = analysis.replace('Verb+', 'V+')
        return analysis.split('+')[0]

    left_analyser = Analyzer(left,
                             'L',
                             tag_clean_left)

    right_analyser = Analyzer(right,
                              'R',
                              tag_clean_right)

    # Collect lemmas
    _input = []
    for line in sys.stdin.readlines():
        _l = line.strip().decode('utf-8')
        chunk = []
        if _l:
            _s = _l.split('\t')
            if len(_s) == 2:
                left, right = _s
            else:
                _fmt = "* Funky input line %s" % _l
                print >> sys.stdout, _fmt.encode('utf-8')
                continue
            for _r in right.split('& '):
                analysis = [
                    left,
                    _r,
                    left_analyser.prepare(left),
                    right_analyser.prepare(_r),
                ]
                chunk.append(analysis)
            _input.append(chunk)

    # Analyze
    left_analyser.run()
    right_analyser.run()

    parts = "%(left)s\t%(rights)s\t%(left_pos)\t%(right_pos)s"

    # Insert analyses
    for chunk in _input:

        left_lemma = ''
        right_lemmas = []
        left_pos = '?'
        right_poses_all = []

        for left, right, left_id, right_id in chunk:
            left_lemma = left
            right_lemmas.append(right)
            # False if nothing.
            left_analysis = left_analyser.getResult(left_id,
                                                    clean=True,
                                                    matchOnly=True)
            right_analysis = right_analyser.getResult(right_id,
                                                      clean=True,
                                                      matchOnly=True)

            left_has = left_analysis.get('out').get('analyses')
            right_has = right_analysis.get('out').get('analyses')

            if left_has:
                left_tags = list(set([a.get('tag') for a in left_has]))
                left_pos = '|'.join(left_tags)
            else:
                left_tags = False
                left_pos = '+?'

            if right_has:
                right_tags = list(set([a.get('tag') for a in right_has]))
                right_poses_all.append('& '.join(right_tags))
            else:
                right_tags = False
                right_poses_all.append('+?')

            _err = ""

        if len(right_poses_all) > 0:
            right_pos_ = list(set(right_poses_all))
            if '+?' in right_pos_ and len(right_pos_) > 1:
            	right_pos_ = [a for a in right_pos_ if a != '+?']
            right_pos_ = '& '.join(right_pos_)
        else:
        	right_pos_ = '+?'

        _fmt = left_lemma + '\t' + '& '.join(right_lemmas) + '\t' + left_pos + '\t' + right_pos_
        print >> sys.stdout, _fmt.encode('utf-8')


if __name__ == "__main__":

    try:
        left_xfst, right_xfst = sys.argv[1::]
    except:
        left_xfst = "~/gtsvn/gt/sme/bin/sme-norm.fst"
        right_xfst = "~/gtsvn/langs/fin/src/analyser-gt-norm.xfst"

    main(left_xfst, right_xfst)
