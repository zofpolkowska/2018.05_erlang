-define(DEVICE_ID, 16#80).
-define(DEVICE_WRITE, 16#40).
-define(TEMP_REG, 16#00).
-define(HUMI_REG, 16#01).
-define(DIVIDER, 65536).

-record(state, {slot, mode}).
