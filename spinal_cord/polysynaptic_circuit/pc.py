import nest
from spinal_cord.polysynaptic_circuit.tier import Tier
from spinal_cord.pool.pool import Pool


class PolysynapticCircuit:

    def __init__(self):

        self.tiers = [
            Tier(i) for i in range(6)
        ]
        for i in range(len(self.tiers)-1):
            nest.Connect(
                pre=self.tiers[i].e[0],
                post=self.tiers[i+1].e[0],
                syn_spec={
                    'model': 'static_synapse',
                    'delay': 1.,
                    'weight': 60.
                },
                conn_spec={
                    'rule': 'one_to_one'
                }
            )
            nest.Connect(
                pre=self.tiers[i].e[3],
                post=self.tiers[i+1].e[0],
                syn_spec={
                    'model': 'static_synapse',
                    'delay': 1.,
                    'weight': 45.
                },
                conn_spec={
                    'rule': 'one_to_one'
                }
            )
            nest.Connect(
                pre=self.tiers[i+1].e[2],
                post=self.tiers[i].e[2],
                syn_spec={
                    'model': 'static_synapse',
                    'delay': 1.,
                    'weight': 100.
                },
                conn_spec={
                    'rule': 'one_to_one'
                }
            )

    def connect_pool(self, pool: Pool):
        for tier in self.tiers:
            for post in [pool.extens_group_nrn_ids, pool.flex_group_nrn_ids]:
                nest.Connect(
                    pre=tier.e[2],
                    post=post,
                    syn_spec={
                        'model': 'static_synapse',
                        'delay': 1.,
                        'weight': 6.
                    },
                    conn_spec={
                        'rule': 'one_to_one'
                    }
                )