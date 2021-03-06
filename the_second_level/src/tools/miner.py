import os
import logging
from the_second_level.src.paths import raw_data_path, spiketimes_path


class Miner:

    @staticmethod
    def gather_voltage(name: str):
        neurons = []
        values = dict()
        logging.warning('Searching for {}'.format(name))
        for datafile in os.listdir(raw_data_path):
            if name in datafile and '.dat' in datafile:
                logging.warning('Gathering data from {}'.format(datafile))
                with open(os.path.join(raw_data_path, datafile)) as data:
                    for line in data:
                        gid, time, value = line.split()
                        if gid not in neurons:
                            neurons.append(gid)
                        if float(time) not in values.keys():
                            values[float(time)] = 0.
                        values[float(time)] += float(value)
        for time in values.keys():
            values[float(time)] /= float(len(neurons))
        return values

    @staticmethod
    def gather_spikes(name: str):
        values = dict()
        logging.warning('Searching for {}'.format(name))
        for datafile in os.listdir(raw_data_path):
            if name in datafile and '.gdf' in datafile:
                logging.warning('Gathering data from {}'.format(datafile))
                with open(os.path.join(raw_data_path, datafile)) as data:
                    for line in data:
                        gid, time = line.split()
                        if int(gid) not in values.keys():
                            values[int(gid)] = []
                        values[int(gid)].append(float(time))
        return values

    @staticmethod
    def has_spikes(name: str) -> bool:
        logging.warning('Check {} for spikes'.format(name))
        for datafile in os.listdir(raw_data_path):
            if name in datafile and '.gdf' in datafile:
                with open(os.path.join(raw_data_path, datafile)) as data:
                    for line in data:
                        if line != '':
                            logging.warning('{}: spikes found'.format(name))
                            return True
        logging.warning('{}: spikes not found'.format(name))
        return False

    @staticmethod
    def gather_spiketimes(name: str):
        logging.warning('Gathering spikes for {}'.format(name))
        for datafile in os.listdir(raw_data_path):
            if name in datafile \
                and '.gdf' in datafile \
                and os.path.getsize(os.path.join(raw_data_path, datafile)) > 0:
                with open(spiketimes_path, 'a') as spikes:
                    with open(os.path.join(raw_data_path, datafile)) as data:
                        spikes.write('{}\n'.format(name))
                        for line in data:
                            spikes.write('{}'.format(line))