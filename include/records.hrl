-record(device, {id, type, sample}).
-record(metric, {sample, timestamp}).
-record(params, {size, cache}).

-define(TIMEOUT, 60000).
-define(CACHE, 100).
