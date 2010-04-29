------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--             Copyright (C) 2010, Free Software Foundation, Inc.           --
------------------------------------------------------------------------------

with Time_Types;
package Timers is

   type Timer_Id is (TIMER_EVT_ETHARPTMR,
                     TIMER_EVT_TCPFASTTMR,
                     TIMER_EVT_TCPSLOWTMR,
                     TIMER_EVT_IPREASSTMR);

   procedure Initialize;
   pragma Export (C, Initialize, "timer_init");

   procedure Set_Interval (TID : Timer_Id; Interval : Time_Types.Interval);
   pragma Export (C, Set_Interval, "timer_set_interval");

   function Timer_Fired (Now : Time_Types.Time; TID : Timer_Id) return Boolean;

   function Next_Deadline return Time_Types.Time;

end Timers;
