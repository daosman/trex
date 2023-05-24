from trex_stl_lib.api import *

# Wild local MACs
mac_localport0='50:00:00:00:00:01'
mac_localport1='50:00:00:00:00:02'

# testpmd_addr.py: |
# wild second XL710 mac
mac_telco0 = '60:00:00:00:00:01'
# we don’t care of the IP in this phase
ip_telco0  = '10.0.0.1'
# wild first XL710 mac
mac_telco1 = '60:00:00:00:00:02'
ip_telco1 = '10.1.1.1'

class STLS1(object):

    def __init__ (self):
        self.fsize  =64; # the size of the packet
        self.number = 0

    def create_stream (self, direction = 0):

        size = self.fsize - 4; # HW will add 4 bytes ethernet FCS
        dport = 1026 + self.number
        self.number = self.number + 1
        if direction == 0:
            base_pkt =  Ether(dst=mac_telco0,src=mac_localport0)/IP(src="16.0.0.1",dst=ip_telco0)/UDP(dport=15,sport=1026)
        else:
            base_pkt =  Ether(dst=mac_telco1,src=mac_localport1)/IP(src="16.1.0.1",dst=ip_telco1)/UDP(dport=16,sport=1026)
        #pad = max(0, size - len(base_pkt)) * 'x'
        pad = (60 - len(base_pkt)) * 'x'

        return STLStream(
            packet =
            STLPktBuilder(
                pkt = base_pkt / pad
            ),
            mode = STLTXCont())

    def create_stats_stream (self, rate_pps = 1000, pgid = 7, direction = 0):

        size = self.fsize - 4; # HW will add 4 bytes ethernet FCS
        if direction == 0:
            base_pkt =  Ether(dst=mac_telco0,src=mac_localport0)/IP(src="17.0.0.1",dst=ip_telco0)/UDP(dport=dport,sport=1026)
        else:
            base_pkt =  Ether(dst=mac_telco1,src=mac_localport1)/IP(src="17.1.0.1",dst=ip_telco1)/UDP(dport=dport,sport=1026)
        pad = max(0, size - len(base_pkt)) * 'x'

        return STLStream(
            packet =
            STLPktBuilder(
                pkt = base_pkt / pad
            ),
            mode = STLTXCont(pps = rate_pps),
            flow_stats = STLFlowLatencyStats(pg_id = pgid))
        #flow_stats = STLFlowStats(pg_id = pgid))

    def get_streams (self, direction = 0, **kwargs):
        # create multiple streams, one stream per core...
        s = []
        for i in range(14):
            s.append(self.create_stream(direction = direction))
        #if direction == 0:
        #    s.append(self.create_stats_stream(rate_pps=1000, pgid=10, direction = direction))
        #else:
        #    s.append(self.create_stats_stream(rate_pps=1000, pgid=11, direction = direction))

        return s

# dynamic load - used for trex console or simulator
def register():
    return STLS1()

