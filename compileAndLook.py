#!/usr/bin/env python3
# _*_ coding: utf-8 _*_

"""
author : xiaohai
email : xiaohaijin@outlook.com
"""


import subprocess


def main():
    subprocess.call(('make', 'clean'))
    subprocess.call(('xelatex', '-shell-escape', 'ComputerVision.tex'))
    subprocess.call(('bibtex', '-shell-escape', 'ComputerVision.aux'))
    subprocess.call(('xelatex', '-shell-escape', 'ComputerVision.tex'))
    subprocess.call(('xelatex', '-shell-escape', 'ComputerVision.tex'))
    subprocess.call(('evince',  'ComputerVision.pdf'))

if __name__ == '__main__':
    main()
