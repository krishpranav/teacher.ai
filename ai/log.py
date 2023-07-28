'''
@filename: log.py
@author: krisna pranav
@copyright: 2023 Krisna Pranav MIT License
'''

import logging

def get_logging(logger_name):
    logger = logging.getLogger(logger_name)
    logger.setLevel(logging.DEBUG)
    
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG)
    logger.addHandler(console_handler)
    return logger