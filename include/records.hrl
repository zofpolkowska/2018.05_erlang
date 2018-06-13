-record(device, {id, type, sample}).
-record(metric, {sample, timestamp}).
-record(state, {metrics}).

-define(TIMEOUT, 60000).
-define(CACHE, 100).
