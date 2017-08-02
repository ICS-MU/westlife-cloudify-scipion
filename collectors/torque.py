# coding=utf-8

"""
The TorqueCollector parses qstat statistics from Torque.
"""

import re
import subprocess
import sys
import xml.dom.minidom

import diamond.collector


class TorqueCollector(diamond.collector.Collector):
    def _capture_output(self, cmd):
        try:
            return subprocess.check_output(cmd)
        except subprocess.CalledProcessError, err:
            self.log.info('Could not capture output from %s' % (' '.join(cmd), ))
            self.log.exception('Could not get stats')
            return None

    def collect(self):
        # torque.jobs.queued
        value = 0
        try:
            out = self._capture_output(['qstat', '-x'])
            dom = xml.dom.minidom.parseString(out) 
            for n in dom.getElementsByTagName('job_state'):
                if n.firstChild.nodeValue == u'Q':
                    value += 1
        except:
            pass

        self.publish("torque.jobs.queued", value)

        # torque.nodes.*
        free = 0
        busy = 0

        try:
            out = self._capture_output(['pbsnodes', '-x'])
            dom = xml.dom.minidom.parseString(out) 
            for n in dom.getElementsByTagName('state'):
                state = n.firstChild.nodeValue
                if (state == u'free'):
                    free += 1
                elif (state != u'free') and (state != 'down'):
                    busy += 1
        except:
            pass

        self.publish("torque.nodes.free", free)
        self.publish("torque.nodes.busy", busy)
