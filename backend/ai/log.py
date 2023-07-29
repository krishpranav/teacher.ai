'''
@filename: log.py
@author: krisna pranav
@copyright: 2023 Krisna Pranav MIT License
'''

import logging

# basic formatter
formatter = '%(asctime)s - %(funcName)s - %(filename)s - %(levelname)s - %(message)s'


def get_logger(logger_name):
    logger = logging.getLogger(logger_name)
    logger.setLevel(logging.DEBUG)

    # console_handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG)
    
    ch_format = logging.Formatter(formatter)
    
    console_handler.setFormatter(ch_format)

    logger.addHandler(console_handler)

    return logger