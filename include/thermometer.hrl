-record(thermometer, {id = undefined, last_temperature = undefined}).

-record(data, {pos = 0, temperature = 0, id = undefined}).

-define(STORE_MAX, 200).
