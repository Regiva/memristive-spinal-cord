import nest
import os
from the_second_level.src.paths import raw_data_path


def add_spike_detector(name):
    return nest.Create(
        model='spike_detector',
        n=1,
        params={
            'label': os.path.join(raw_data_path, name),
            'withgid': False,
            'to_file': True,
            'to_memory': False})
