unit pico_time_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}{$H+}
interface
uses
  pico_c;

{$L time.c.obj}

extern const absolute_time_t at_the_end_of_time;
extern const absolute_time_t nil_time;

type 
  Talarm_id = longWord;
  Talarm_callback = procedure (id : Talarm_id; user_data:pointer) : int64;

  Trepeating_timer_callback_t = function (var rt : Trepeating_timer):boolean;

  Trepeating_timer = record
    delay_us : int64;
    pool : Talarm_pool;
    alarm_id = Talarm_id;
    callback : Trepeating_timer_callback;
    user_data : pointer;
  end;

function get_absolute_time : Tabsolute_time;
begin
  result := update_us_since_boot(result,time_us_64);
end;

function us_to_ms(us:int64):longWord;
begin
  if (us shr 32) <> 0 then
    result := us div 1000
  else
    result := longWord(us) div 1000;
end;

function to_ms_since_boot(t : Tabsolute_time):longWord;
begin
  result := us_to_ms(to_us_since_boot(t));
end;

function delayed_by_us(const t :  Tabsolute_time;us:int64):Tabsolute_time;
var
  base,delayed : int64;
begin
  absolute_time_t t2;
  base = to_us_since_boot(t);
  delayed = base + us;
  if (delayed < base) then
    delayed = (uint64_t)-1;
  update_us_since_boot(result,delayed);
end;

function delayed_by_ms(const t : Tabsolute_time; ms : longWord):Tabsolute_time;
var
  base,delayed : int64;
begin
  base = to_us_since_boot(t);
  delayed = base + ms * 1000ull;
  if delayed < base then
    delayed = (uint64_t)-1;
  update_us_since_boot(result, delayed);
end;

function make_timeout_time_us(us:int64):Tabsolute_time;
begin
  result := delayed_by_us(get_absolute_time,us);
end;

function make_timeout_time_ms(ms : longWord):Tabsolute_time;
begin
  result := delayed_by_ms(get_absolute_time, ms);
end;

function absolute_time_diff_us(from : Tabsolute_time; to : Tabsolute_time):Tabsolute_time;
begin
  result := to_us_since_boot(to) - to_us_since_boot(from);
end;

function is_nil_time(t : Tabsolute_time)boolean;
begin
  result := to_us_since_boot(t)=0;
end;

procedure sleep_until(absolute_time_t target); external;
procedure sleep_us(us:int64); external;
procedure sleep_ms(ms:lobgWord); external;
function best_effort_wfe_or_timeout(timeout_timestamp : Tabsolute_time):boolean; external;
procedure alarm_pool_init_default; external;
function alarm_pool_get_default:Talarm_pool; external;
function alarm_pool_create(hardware_alarm_num : longWord; max_timers:longWord):Talarm_pool; external;
function alarm_pool_hardware_alarm_num(ivar pool : Talarm_pool):longWord; external;
procedure alarm_pool_destroy(var pool : Talarm_pool); external;
function alarm_pool_add_alarm_at(var pool : Talarm_pool; time : Tabsolute_time; callback : Talarm_callback; user_data:pointer; fire_if_past:boolean):Talarm_id;
function alarm_pool_add_alarm_in_us(var pool : Talarm_pool; us:int64; callback : Talarm_callback; user_data:pointer; fire_if_past:boolean):Talarm_id;
begin
  result := alarm_pool_add_alarm_at(pool,delayed_by_us(get_absolute_time,us),callback,user_data,fire_if_past);
end;

function alarm_pool_add_alarm_in_ms(alarm_pool_t *pool, uint32_t ms, alarm_callback_t callback, void *user_data, bool fire_if_past):Talarm_id;
begin
  result := alarm_pool_add_alarm_at(pool,delayed_by_ms(get_absolute_time,ms),callback,user_data,fire_if_past);
end;

function alarm_pool_cancel_alarm(var pool : Talarm_pool; alarm_id : Talarm_id):boolean; external;
function add_alarm_at(time Tabsolute_time; callback : Talarm_callback; user_data : pointer; fire_if_past:boolean):Talarm_id;
begin
  result := alarm_pool_add_alarm_at(alarm_pool_get_default,time,callback,user_data,fire_if_past);
end;

function add_alarm_in_us(us:int64; callback : Talarm_callback; user_data : pointer; fire_if_past: boolean):Talarm_id;
  result := alarm_pool_add_alarm_in_us(alarm_pool_get_default(), us, callback, user_data, fire_if_past);
end;

function add_alarm_in_ms(ms:longWord; claaback : Talarm_callback; user_data : pointer; fire_if_past: boolean):Talarm_id;
begin
  result := alarm_pool_add_alarm_in_ms(alarm_pool_get_default,ms,callback,user_data,fire_if_past);
end;

function cancel_alarm(alarm_id : Talarm_id):boolean;
begin
  result := alarm_pool_cancel_alarm(alarm_pool_get_default,alarm_id);
end;

function alarm_pool_add_repeating_timer_us(var pool : Talarm_pool; delay_us: int64; callback : Trepeating_timer_callback; user_data:pointer; &out : Trepeating_timer):boolean;
static inline bool alarm_pool_add_repeating_timer_ms(alarm_pool_t *pool, int32_t delay_ms, repeating_timer_callback_t callback, void *user_data, repeating_timer_t *out):boolean;
begin
  result := alarm_pool_add_repeating_timer_us(pool, delay_ms * (int64_t)1000, callback, user_data, out);
end;

function add_repeating_timer_us(int64_t delay_us, repeating_timer_callback_t callback, void *user_data, repeating_timer_t *out):boolean;
begin
  result := alarm_pool_add_repeating_timer_us(alarm_pool_get_default,delay_us,callback,user_data,&out);
end;
function add_repeating_timer_ms(delay_ms : int64; callback Trepeating_timer_callback; user_data : pointer; &out: Trepeating_timer): boolean;
begin
  result := alarm_pool_add_repeating_timer_us(alarm_pool_get_default,delay_ms * iint64(1000),callback,user_data,&out);
end;

function cancel_repeating_timer(ivar timer : Trepeating_timer):boolean;

implementation


