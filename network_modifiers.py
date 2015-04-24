### Classes implementing "network modification" interface, i.e. modify_network_state() ###

from stem import Flag
from stem.exit_policy import ExitPolicy
import pathsim

### Class inserting adversary relays ###
class AdversaryInsertion(object):
    def add_adv_guards(self, num_adv_guards, bandwidth):
        """"Adds adv guards into self.add_relays and self.add_descriptors."""
        #, adv_relays, adv_descriptors
        for i in range(num_adv_guards):
            # create consensus
            num_str = str(i+1)
            fingerprint = '0' * (40-len(num_str)) + num_str
            nickname = 'BadGuyGuard' + num_str
            flags = [Flag.FAST, Flag.GUARD, Flag.RUNNING, Flag.STABLE,
                Flag.VALID]
            self.adv_relays[fingerprint] = pathsim.RouterStatusEntry(fingerprint,
                nickname, flags, bandwidth)

            # create descriptor
            hibernating = False
            family = {}
            address = '10.'+num_str+'.0.0' # avoid /16 conflicts
            exit_policy = ExitPolicy('reject *:*')
            ntor_onion_key = num_str # indicate ntor support w/ val != None
            self.adv_descriptors[fingerprint] = pathsim.ServerDescriptor(fingerprint,
                hibernating, nickname, family, address, exit_policy,
                ntor_onion_key)


    def add_adv_exits(self, num_adv_guards, num_adv_exits, bandwidth):
        """"Adds adv exits into self.add_relays and self.add_descriptors."""
        for i in range(num_adv_exits):
            # create consensus
            num_str = str(i+1)
            fingerprint = 'F' * (40-len(num_str)) + num_str
            nickname = 'BadGuyExit' + num_str
            flags = [Flag.FAST, Flag.EXIT, Flag.RUNNING, Flag.STABLE,
                Flag.VALID]
            self.adv_relays[fingerprint] = pathsim.RouterStatusEntry(fingerprint,
                nickname, flags, bandwidth)

            # create descriptor
            hibernating = False
            family = {}
            address = '10.'+str(num_adv_guards+i+1)+'.0.0' # avoid /16 conflicts
            exit_policy = ExitPolicy('accept *:*')
            ntor_onion_key = num_str # indicate ntor support w/ val != None
            self.adv_descriptors[fingerprint] = pathsim.ServerDescriptor(fingerprint,
                hibernating, nickname, family, address, exit_policy,
                ntor_onion_key)


    def __init__(self, args, testing):
        self.adv_time = args.adv_time
        self.adv_relays = {}
        self.adv_descriptors = {}
        self.add_adv_guards(args.num_adv_guards, args.adv_guard_cons_bw)
        self.add_adv_exits(args.num_adv_guards, args.num_adv_exits,
            args.adv_exit_cons_bw)
        self.testing = testing
        self.first_modification = True


    def modify_network_state(self, network_state):
        """Adds adversarial guards and exits to cons_rel_stats and
        descriptors dicts."""

        # add adversarial descriptors to nsf descriptors
        # only add once because descriptors variable is assumed persistant
        if (self.first_modification == True):
            network_state.descriptors.update(self.adv_descriptors)
            self.first_modification = False

        # if insertion time has been reached, add adversarial relays into
        # consensus and hibernating status list
        if (self.adv_time <= network_state.cons_valid_after):
            # include additional relays in consensus
            if self.testing:
                print('Adding {0} relays to consensus.'.format(\
                    len(self.adv_relays)))
            for fprint, relay in self.adv_relays.items():
                if fprint in network_state.cons_rel_stats:
                    raise ValueError(\
                        'Added relay exists in consensus: {0}:{1}'.\
                            format(relay.nickname, fprint))
                network_state.cons_rel_stats[fprint] = relay
            # include hibernating statuses for added relays
            network_state.hibernating_statuses.extend([(0, fp, False) \
                for fp in self.adv_relays])
######

### Class adjusting Guard flags ###
class RaiseGuardConsBWThreshold(object):
    def __init__(self, args, testing):
        # obtain argument string, assumed in form: full_classname:cons_bw_threshold
        full_classname, class_arg = args.other_network_modifier.split('-')
        # interpret arg as consensus weight limit for Guard flag
        self.guard_bw_threshold = int(class_arg)
        self.testing = testing


    def modify_network_state(self, network_state):
        """Remove Guard flag when relay doesn't meet consensus bandwidth threshold."""

        num_guard_flags = 0
        num_guard_flags_removed = 0
        for fprint, rel_stat in network_state.cons_rel_stats.items():
            if (Flag.GUARD in rel_stat.flags):
                num_guard_flags += 1
                if (rel_stat.bandwidth < self.guard_bw_threshold):
                    num_guard_flags_removed += 1
                    rel_stat.flags = filter(lambda x: x != Flag.GUARD, rel_stat.flags)
        if self.testing:
            print('Removed {} guard flags out of {}'.format(num_guard_flags_removed,
                num_guard_flags))
######
