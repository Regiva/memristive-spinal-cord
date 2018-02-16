l2_neuron_group_params = dict()
inter_model_params = {
    't_ref': 2.,  # Refractory period
    'V_m': -70.0,  #
    'E_L': -70.0,  #
    'E_K': -77.0,  #
    'g_L': 30.0,  #
    'g_Na': 12000.0,  #
    'g_K': 3600.0,  #
    'C_m': 134.0,  # Capacity of membrane (pF)
    'tau_syn_ex': 0.5,  # Time of excitatory action (ms)
    'tau_syn_in': 5.0  # Time of inhibitory action (ms)
}

inter_model_number = 20
inter_model_type = 'hh_cond_exp_traub'

# Polysynaptic circuit
for tier in range(7):
    for exc in range(5):
        l2_neuron_group_params['Tier{}E{}'.format(tier, exc)] = dict(
            model=inter_model_type,
            params=inter_model_params,
            n=inter_model_number,
        )
    l2_neuron_group_params['Tier{}I0'.format(tier)] = dict(
        model=inter_model_type,
        params=inter_model_params,
        n=inter_model_number
    )
    l2_neuron_group_params['Tier{}I1'.format(tier)] = dict(
        model=inter_model_type,
        params=inter_model_params,
        n=inter_model_number
    )

# Pool
for i in range(2):
    l2_neuron_group_params['Pool{}'.format(i)] = dict(
        model=inter_model_type,
        params=inter_model_params,
        n=inter_model_number
    )

# Mediator
l2_neuron_group_params['Mediator'] = dict(
    model=inter_model_type,
    params=inter_model_params,
    n=1
)