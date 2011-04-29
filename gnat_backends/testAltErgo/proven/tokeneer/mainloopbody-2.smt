(benchmark mainloopbody.2.1
  :logic AUFNIRA
  :extrasorts 
  ( clock__timet
    latch__statetype
    latch__outtype
    door__statetype
    alarm__outtype
    keystore__state__type
    admin__t
    admintoken__statetype
    enclave__statetype
    real___type
  )
  :extrafuns 
  ( (admin__archivelog Int )
    (admin__nullop Int )
    (admin__opandnullt__base__first Int )
    (admin__opandnullt__base__last Int )
    (admin__opandnullt__first Int )
    (admin__opandnullt__last Int )
    (admin__opandnullt__size Int )
    (admin__overridelock Int )
    (admin__shutdownop Int )
    (admin__updateconfigdata Int )
    (admintoken__state admintoken__statetype )
    (admintoken__state__1 admintoken__statetype )
    (admintoken__state__1___init admintoken__statetype )
    (admintoken__state__1___loopinit admintoken__statetype )
    (admintoken__state__3 admintoken__statetype )
    (admintoken__state__3___init admintoken__statetype )
    (admintoken__state__3___loopinit admintoken__statetype )
    (admintoken__state___init admintoken__statetype )
    (admintoken__state___loopinit admintoken__statetype )
    (alarm__output alarm__outtype )
    (alarm__output__2 alarm__outtype )
    (alarm__output__2___init alarm__outtype )
    (alarm__output__2___loopinit alarm__outtype )
    (alarm__output__4 alarm__outtype )
    (alarm__output__4___init alarm__outtype )
    (alarm__output__4___loopinit alarm__outtype )
    (alarm__output___init alarm__outtype )
    (alarm__output___loopinit alarm__outtype )
    (alarmtypes__alarming Int )
    (alarmtypes__silent Int )
    (alarmtypes__statust__base__first Int )
    (alarmtypes__statust__base__last Int )
    (alarmtypes__statust__first Int )
    (alarmtypes__statust__last Int )
    (alarmtypes__statust__size Int )
    (bit___false Int )
    (bit___true Int )
    (clock__currenttime clock__timet )
    (clock__currenttime__1 clock__timet )
    (clock__currenttime__1___init clock__timet )
    (clock__currenttime__1___loopinit clock__timet )
    (clock__currenttime___init clock__timet )
    (clock__currenttime___loopinit clock__timet )
    (door__closed Int )
    (door__open Int )
    (door__state door__statetype )
    (door__state__1 door__statetype )
    (door__state__1___init door__statetype )
    (door__state__1___loopinit door__statetype )
    (door__state__3 door__statetype )
    (door__state__3___init door__statetype )
    (door__state__3___loopinit door__statetype )
    (door__state___init door__statetype )
    (door__state___loopinit door__statetype )
    (door__t__base__first Int )
    (door__t__base__last Int )
    (door__t__first Int )
    (door__t__last Int )
    (door__t__size Int )
    (enclave__state enclave__statetype )
    (enclave__state__3 enclave__statetype )
    (enclave__state__3___init enclave__statetype )
    (enclave__state__3___loopinit enclave__statetype )
    (enclave__state___init enclave__statetype )
    (enclave__state___loopinit enclave__statetype )
    (keystore__state keystore__state__type )
    (keystore__state__3 keystore__state__type )
    (keystore__state__3___init keystore__state__type )
    (keystore__state__3___loopinit keystore__state__type )
    (keystore__state___init keystore__state__type )
    (keystore__state___loopinit keystore__state__type )
    (latch__output latch__outtype )
    (latch__output__2 latch__outtype )
    (latch__output__2___init latch__outtype )
    (latch__output__2___loopinit latch__outtype )
    (latch__output__4 latch__outtype )
    (latch__output__4___init latch__outtype )
    (latch__output__4___loopinit latch__outtype )
    (latch__output___init latch__outtype )
    (latch__output___loopinit latch__outtype )
    (latch__state latch__statetype )
    (latch__state__1 latch__statetype )
    (latch__state__1___init latch__statetype )
    (latch__state__1___loopinit latch__statetype )
    (latch__state__3 latch__statetype )
    (latch__state__3___init latch__statetype )
    (latch__state__3___loopinit latch__statetype )
    (latch__state___init latch__statetype )
    (latch__state___loopinit latch__statetype )
    (privtypes__auditmanager Int )
    (privtypes__guard Int )
    (privtypes__privileget__base__first Int )
    (privtypes__privileget__base__last Int )
    (privtypes__privileget__first Int )
    (privtypes__privileget__last Int )
    (privtypes__privileget__size Int )
    (privtypes__securityofficer Int )
    (privtypes__useronly Int )
    (theadmin admin__t )
    (theadmin__3 admin__t )
    (theadmin__3___init admin__t )
    (theadmin__3___loopinit admin__t )
    (theadmin___init admin__t )
    (theadmin___loopinit admin__t )
    (admin__opandnullt___bit_eq Int Int Int )
    (admin__opandnullt__pos Int Int )
    (admin__opandnullt__pred Int Int )
    (admin__opandnullt__succ Int Int )
    (admin__opandnullt__val Int Int )
    (admin__prf_rolepresent admin__t Int )
    (admin__t___bit_eq admin__t admin__t Int )
    (admin__thecurrentop admin__t Int )
    (admintoken__statetype___bit_eq
      admintoken__statetype
      admintoken__statetype
      Int
    )
    (admintoken__theauthcertrole admintoken__statetype Int )
    (alarm__outtype___bit_eq alarm__outtype alarm__outtype Int )
    (alarmtypes__statust___bit_eq Int Int Int )
    (alarmtypes__statust__pos Int Int )
    (alarmtypes__statust__pred Int Int )
    (alarmtypes__statust__succ Int Int )
    (alarmtypes__statust__val Int Int )
    (bit___and Int Int Int )
    (bit___iff Int Int Int )
    (bit___not Int Int )
    (bit___or Int Int Int )
    (bit___type___bit_eq Int Int Int )
    (bit__and Int Int Int )
    (bit__not Int Int Int )
    (bit__or Int Int Int )
    (bit__xor Int Int Int )
    (character__pos Int Int )
    (character__val Int Int )
    (clock__thecurrenttime clock__timet clock__timet )
    (clock__timet___bit_eq clock__timet clock__timet Int )
    (door__prf_alarmtimeout door__statetype clock__timet )
    (door__statetype___bit_eq
      door__statetype
      door__statetype
      Int
    )
    (door__t___bit_eq Int Int Int )
    (door__t__pos Int Int )
    (door__t__pred Int Int )
    (door__t__succ Int Int )
    (door__t__val Int Int )
    (door__thecurrentdoor door__statetype Int )
    (door__thedooralarm door__statetype Int )
    (enclave__statetype___bit_eq
      enclave__statetype
      enclave__statetype
      Int
    )
    (int___abs Int Int )
    (int___div Int Int Int )
    (int___exp Int Int Int )
    (int___mod Int Int Int )
    (int___rem Int Int Int )
    (int___times Int Int Int )
    (int___to_real Int real___type )
    (integer___bit_eq Int Int Int )
    (integer___bit_le Int Int Int )
    (keystore__state__type___bit_eq
      keystore__state__type
      keystore__state__type
      Int
    )
    (latch__outtype___bit_eq latch__outtype latch__outtype Int )
    (latch__prf_latchtimeout latch__statetype clock__timet )
    (latch__statetype___bit_eq
      latch__statetype
      latch__statetype
      Int
    )
    (privtypes__privileget___bit_eq Int Int Int )
    (privtypes__privileget__pos Int Int )
    (privtypes__privileget__pred Int Int )
    (privtypes__privileget__succ Int Int )
    (privtypes__privileget__val Int Int )
    (real___abs real___type real___type )
    (real___bit_eq real___type real___type Int )
    (real___div real___type real___type real___type )
    (real___exp real___type Int real___type )
    (real___minus real___type real___type real___type )
    (real___plus real___type real___type real___type )
    (real___times real___type real___type real___type )
    (real___uminus real___type real___type )
    (round__ real___type Int )
  )
  :extrapreds 
  ( (systemfault)
    (systemfault__1)
    (systemfault__1___init)
    (systemfault__1___loopinit)
    (systemfault__2)
    (systemfault__2___init)
    (systemfault__2___loopinit)
    (systemfault__4)
    (systemfault__4___init)
    (systemfault__4___loopinit)
    (systemfault___init)
    (systemfault___loopinit)
    (userentry__prf_userentryunlockdoor)
    (admin__isdoingop admin__t )
    (admin__ispresent admin__t )
    (admin__opandnullt__LE Int Int )
    (admin__opandnullt__LT Int Int )
    (admin__opandnullt___member Int )
    (admintoken__prf_authcertvalid admintoken__statetype )
    (admintoken__prf_isgood admintoken__statetype )
    (alarm__prf_isalarming alarm__outtype )
    (alarmtypes__statust__LE Int Int )
    (alarmtypes__statust__LT Int Int )
    (alarmtypes__statust___member Int )
    (bit___type___member Int )
    (clock__greaterthanorequal clock__timet clock__timet )
    (door__t__LE Int Int )
    (door__t__LT Int Int )
    (door__t___member Int )
    (enclave__enrolmentisinprogress enclave__statetype )
    (enclave__prf_statusisenclavequiescent enclave__statetype )
    (enclave__prf_statusisgotadmintoken enclave__statetype )
    (enclave__prf_statusisshutdown enclave__statetype )
    (enclave__prf_statusiswaitingfinishadminop
      enclave__statetype
    )
    (enclave__prf_statusiswaitingremoveadmintokenfail
      enclave__statetype
    )
    (enclave__prf_statusiswaitingstartadminop
      enclave__statetype
    )
    (int___odd Int )
    (keystore__privatekeypresent keystore__state__type )
    (latch__islocked latch__statetype )
    (latch__prf_islocked latch__outtype )
    (privtypes__privileget__LE Int Int )
    (privtypes__privileget__LT Int Int )
    (privtypes__privileget___member Int )
    (real___le real___type real___type )
    (real___lt real___type real___type )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (alarmtypes__statust___member ?i )
      (= (alarmtypes__statust__pos ?i ) ?i )
    )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (alarmtypes__statust___member ?i )
      (= (alarmtypes__statust__val ?i ) ?i )
    )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (alarmtypes__statust___member ?i )
      (implies
        (< ?i 1 )
        (= (alarmtypes__statust__succ ?i ) (+ ?i 1 ) )
      )
    )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (alarmtypes__statust___member ?i )
      (implies
        (< 0 ?i )
        (= (alarmtypes__statust__pred ?i ) (- ?i 1 ) )
      )
    )
  )
  :assumption
  (= alarmtypes__alarming 0 )
  :assumption
  (= alarmtypes__silent 1 )
  :assumption
  (forall
      (?i Int )
    (implies
      (privtypes__privileget___member ?i )
      (= (privtypes__privileget__pos ?i ) ?i )
    )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (privtypes__privileget___member ?i )
      (= (privtypes__privileget__val ?i ) ?i )
    )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (privtypes__privileget___member ?i )
      (implies
        (< ?i 3 )
        (= (privtypes__privileget__succ ?i ) (+ ?i 1 ) )
      )
    )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (privtypes__privileget___member ?i )
      (implies
        (< 0 ?i )
        (= (privtypes__privileget__pred ?i ) (- ?i 1 ) )
      )
    )
  )
  :assumption
  (= privtypes__useronly 0 )
  :assumption
  (= privtypes__guard 1 )
  :assumption
  (= privtypes__auditmanager 2 )
  :assumption
  (= privtypes__securityofficer 3 )
  :assumption
  (forall
      (?i Int )
    (implies (door__t___member ?i ) (= (door__t__pos ?i ) ?i ) )
  )
  :assumption
  (forall
      (?i Int )
    (implies (door__t___member ?i ) (= (door__t__val ?i ) ?i ) )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (door__t___member ?i )
      (implies (< ?i 1 ) (= (door__t__succ ?i ) (+ ?i 1 ) ) )
    )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (door__t___member ?i )
      (implies (< 0 ?i ) (= (door__t__pred ?i ) (- ?i 1 ) ) )
    )
  )
  :assumption
  (= door__open 0 )
  :assumption
  (= door__closed 1 )
  :assumption
  (forall
      (?i Int )
    (implies
      (admin__opandnullt___member ?i )
      (= (admin__opandnullt__pos ?i ) ?i )
    )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (admin__opandnullt___member ?i )
      (= (admin__opandnullt__val ?i ) ?i )
    )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (admin__opandnullt___member ?i )
      (implies
        (< ?i 4 )
        (= (admin__opandnullt__succ ?i ) (+ ?i 1 ) )
      )
    )
  )
  :assumption
  (forall
      (?i Int )
    (implies
      (admin__opandnullt___member ?i )
      (implies
        (< 0 ?i )
        (= (admin__opandnullt__pred ?i ) (- ?i 1 ) )
      )
    )
  )
  :assumption
  (= admin__nullop 0 )
  :assumption
  (= admin__archivelog 1 )
  :assumption
  (= admin__updateconfigdata 2 )
  :assumption
  (= admin__overridelock 3 )
  :assumption
  (= admin__shutdownop 4 )
  :assumption
  (<= 0 alarmtypes__statust__size )
  :assumption
  (= alarmtypes__statust__first alarmtypes__alarming )
  :assumption
  (= alarmtypes__statust__last alarmtypes__silent )
  :assumption
  (= alarmtypes__statust__base__first alarmtypes__alarming )
  :assumption
  (= alarmtypes__statust__base__last alarmtypes__silent )
  :assumption
  (<= 0 privtypes__privileget__size )
  :assumption
  (= privtypes__privileget__first privtypes__useronly )
  :assumption
  (= privtypes__privileget__last privtypes__securityofficer )
  :assumption
  (= privtypes__privileget__base__first privtypes__useronly )
  :assumption
  (=
    privtypes__privileget__base__last
    privtypes__securityofficer
  )
  :assumption
  (<= 0 door__t__size )
  :assumption
  (= door__t__first door__open )
  :assumption
  (= door__t__last door__closed )
  :assumption
  (= door__t__base__first door__open )
  :assumption
  (= door__t__base__last door__closed )
  :assumption
  (<= 0 admin__opandnullt__size )
  :assumption
  (= admin__opandnullt__first admin__nullop )
  :assumption
  (= admin__opandnullt__last admin__shutdownop )
  :assumption
  (= admin__opandnullt__base__first admin__nullop )
  :assumption
  (= admin__opandnullt__base__last admin__shutdownop )
  :assumption
  (forall
      (?X Int )
    (implies (<= 0 ?X ) (= (bit__and ?X ?X ) ?X ) )
  )
  :assumption
  (forall
      (?X Int )
    (implies (<= 0 ?X ) (= (bit__or ?X ?X ) ?X ) )
  )
  :assumption
  (forall
      (?X Int )
    (implies (<= 0 ?X ) (= (bit__xor ?X ?X ) 0 ) )
  )
  :assumption
  (forall
      (?X Int )
    (implies (<= 0 ?X ) (= (bit__and ?X 0 ) 0 ) )
  )
  :assumption
  (forall
      (?X Int )
    (implies (<= 0 ?X ) (= (bit__or ?X 0 ) ?X ) )
  )
  :assumption
  (forall
      (?X Int )
    (implies (<= 0 ?X ) (= (bit__xor ?X 0 ) ?X ) )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= 0 (bit__and ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= 0 (bit__or ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= 0 (bit__xor ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= ?X (bit__or ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= ?Y (bit__or ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= (- ?X ?Y ) (bit__xor ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= (- ?Y ?X ) (bit__xor ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= (bit__and ?X ?Y ) ?X )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= (bit__and ?X ?Y ) ?Y )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= (bit__or ?X ?Y ) (+ ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= (bit__xor ?X ?Y ) (+ ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?N Int ) (?X Int ) (?Y Int )
    (implies
      (and
        (<= 0 ?X )
        (<= 0 ?Y )
        (<= 0 ?N )
        (<= ?X (- (int___exp 2 ?N ) 1 ) )
        (<= ?Y (- (int___exp 2 ?N ) 1 ) )
      )
      (<= (bit__or ?X ?Y ) (- (int___exp 2 ?N ) 1 ) )
    )
  )
  :assumption
  (forall
      (?N Int ) (?X Int ) (?Y Int )
    (implies
      (and
        (<= 0 ?X )
        (<= 0 ?Y )
        (<= 0 ?N )
        (<= ?X (- (int___exp 2 ?N ) 1 ) )
        (<= ?Y (- (int___exp 2 ?N ) 1 ) )
      )
      (<= (bit__xor ?X ?Y ) (- (int___exp 2 ?N ) 1 ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= (bit__and ?X ?Y ) (bit__or ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (<= 0 ?Y ) )
      (<= (bit__xor ?X ?Y ) (bit__or ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int )
    (implies (<= 0 ?X ) (= (int___abs ?X ) ?X ) )
  )
  :assumption
  (forall
      (?X Int )
    (implies (< ?X 0 ) (= (int___abs ?X ) (~ ?X ) ) )
  )
  :assumption
  (forall
      (?U real___type )
    (implies
      (real___le (int___to_real 0 ) ?U )
      (= (real___abs ?U ) ?U )
    )
  )
  :assumption
  (forall
      (?U real___type )
    (implies
      (real___lt ?U (int___to_real 0 ) )
      (= (real___abs ?U ) (real___uminus ?U ) )
    )
  )
  :assumption
  (forall
      (?X Int )
    (iff (int___odd ?X ) (= (int___mod (int___abs ?X ) 2 ) 1 ) )
  )
  :assumption
  (= 256 256 )
  :assumption
  (= 65536 65536 )
  :assumption
  (= 4294967296 4294967296 )
  :assumption
  (= 18446744073709551616 18446744073709551616 )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies (< 0 ?Y ) (<= 0 (int___mod ?X ?Y ) ) )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies (< 0 ?Y ) (< (int___mod ?X ?Y ) ?Y ) )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies (< ?Y 0 ) (<= (int___mod ?X ?Y ) 0 ) )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies (< ?Y 0 ) (< ?Y (int___mod ?X ?Y ) ) )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (< 0 ?Y ) )
      (< (- ?X ?Y ) (* ?Y (int___div ?X ?Y ) ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (< 0 ?Y ) )
      (<= (* ?Y (int___div ?X ?Y ) ) ?X )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= ?X 0 ) (< 0 ?Y ) )
      (<= ?X (* ?Y (int___div ?X ?Y ) ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= ?X 0 ) (< 0 ?Y ) )
      (< (* ?Y (int___div ?X ?Y ) ) (+ ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (< ?Y 0 ) )
      (<= (* ?Y (int___div ?X ?Y ) ) ?X )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (< ?Y 0 ) )
      (< (+ ?X ?Y ) (* ?Y (int___div ?X ?Y ) ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= ?X 0 ) (< ?Y 0 ) )
      (< (* ?Y (int___div ?X ?Y ) ) (- ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= ?X 0 ) (< ?Y 0 ) )
      (<= ?X (* ?Y (int___div ?X ?Y ) ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (= (+ (* ?Y (int___div ?X ?Y ) ) (int___rem ?X ?Y ) ) ?X )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (= (int___rem ?X ?Y ) 0 )
      (= (int___mod ?X ?Y ) 0 )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (< 0 ?Y ) )
      (= (int___mod ?X ?Y ) (int___rem ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= ?X 0 ) (< 0 ?Y ) (not (= (int___rem ?X ?Y ) 0 ) ) )
      (= (int___mod ?X ?Y ) (+ (int___rem ?X ?Y ) ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (< ?Y 0 ) (not (= (int___rem ?X ?Y ) 0 ) ) )
      (= (int___mod ?X ?Y ) (+ (int___rem ?X ?Y ) ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= ?X 0 ) (< ?Y 0 ) )
      (= (int___mod ?X ?Y ) (int___rem ?X ?Y ) )
    )
  )
  :assumption
  (forall
      (?X Int ) (?Y Int )
    (implies
      (and (<= 0 ?X ) (< ?X ?Y ) )
      (= (int___mod ?X ?Y ) ?X )
    )
  )
  :assumption
  (admin__opandnullt___member admin__archivelog )
  :assumption
  (admin__opandnullt___member admin__nullop )
  :assumption
  (admin__opandnullt___member admin__opandnullt__base__first )
  :assumption
  (admin__opandnullt___member admin__opandnullt__base__last )
  :assumption
  (admin__opandnullt___member admin__opandnullt__first )
  :assumption
  (admin__opandnullt___member admin__opandnullt__last )
  :assumption
  (admin__opandnullt___member admin__overridelock )
  :assumption
  (admin__opandnullt___member admin__shutdownop )
  :assumption
  (admin__opandnullt___member admin__updateconfigdata )
  :assumption
  (alarmtypes__statust___member alarmtypes__alarming )
  :assumption
  (alarmtypes__statust___member alarmtypes__silent )
  :assumption
  (alarmtypes__statust___member
    alarmtypes__statust__base__first
  )
  :assumption
  (alarmtypes__statust___member
    alarmtypes__statust__base__last
  )
  :assumption
  (alarmtypes__statust___member alarmtypes__statust__first )
  :assumption
  (alarmtypes__statust___member alarmtypes__statust__last )
  :assumption
  (door__t___member door__closed )
  :assumption
  (door__t___member door__open )
  :assumption
  (door__t___member door__t__base__first )
  :assumption
  (door__t___member door__t__base__last )
  :assumption
  (door__t___member door__t__first )
  :assumption
  (door__t___member door__t__last )
  :assumption
  (privtypes__privileget___member privtypes__auditmanager )
  :assumption
  (privtypes__privileget___member privtypes__guard )
  :assumption
  (privtypes__privileget___member
    privtypes__privileget__base__first
  )
  :assumption
  (privtypes__privileget___member
    privtypes__privileget__base__last
  )
  :assumption
  (privtypes__privileget___member
    privtypes__privileget__first
  )
  :assumption
  (privtypes__privileget___member
    privtypes__privileget__last
  )
  :assumption
  (privtypes__privileget___member privtypes__securityofficer )
  :assumption
  (privtypes__privileget___member privtypes__useronly )
  :assumption
  (forall
      (?x0 Int )
    (implies
      (admin__opandnullt___member ?x0 )
      (admin__opandnullt___member (admin__opandnullt__pred ?x0 ) )
    )
  )
  :assumption
  (forall
      (?x0 Int )
    (implies
      (admin__opandnullt___member ?x0 )
      (admin__opandnullt___member (admin__opandnullt__succ ?x0 ) )
    )
  )
  :assumption
  (forall
      (?x0 Int )
    (admin__opandnullt___member (admin__opandnullt__val ?x0 ) )
  )
  :assumption
  (forall
      (?x0 admin__t )
    (privtypes__privileget___member
      (admin__prf_rolepresent ?x0 )
    )
  )
  :assumption
  (forall
      (?x0 admin__t )
    (admin__opandnullt___member (admin__thecurrentop ?x0 ) )
  )
  :assumption
  (forall
      (?x0 admintoken__statetype )
    (privtypes__privileget___member
      (admintoken__theauthcertrole ?x0 )
    )
  )
  :assumption
  (forall
      (?x0 Int )
    (implies
      (alarmtypes__statust___member ?x0 )
      (alarmtypes__statust___member
        (alarmtypes__statust__pred ?x0 )
      )
    )
  )
  :assumption
  (forall
      (?x0 Int )
    (implies
      (alarmtypes__statust___member ?x0 )
      (alarmtypes__statust___member
        (alarmtypes__statust__succ ?x0 )
      )
    )
  )
  :assumption
  (forall
      (?x0 Int )
    (alarmtypes__statust___member
      (alarmtypes__statust__val ?x0 )
    )
  )
  :assumption
  (forall
      (?x0 Int )
    (implies
      (door__t___member ?x0 )
      (door__t___member (door__t__pred ?x0 ) )
    )
  )
  :assumption
  (forall
      (?x0 Int )
    (implies
      (door__t___member ?x0 )
      (door__t___member (door__t__succ ?x0 ) )
    )
  )
  :assumption
  (forall
      (?x0 Int )
    (door__t___member (door__t__val ?x0 ) )
  )
  :assumption
  (forall
      (?x0 door__statetype )
    (door__t___member (door__thecurrentdoor ?x0 ) )
  )
  :assumption
  (forall
      (?x0 door__statetype )
    (alarmtypes__statust___member (door__thedooralarm ?x0 ) )
  )
  :assumption
  (forall
      (?x0 Int )
    (implies
      (privtypes__privileget___member ?x0 )
      (privtypes__privileget___member
        (privtypes__privileget__pred ?x0 )
      )
    )
  )
  :assumption
  (forall
      (?x0 Int )
    (implies
      (privtypes__privileget___member ?x0 )
      (privtypes__privileget___member
        (privtypes__privileget__succ ?x0 )
      )
    )
  )
  :assumption
  (forall
      (?x0 Int )
    (privtypes__privileget___member
      (privtypes__privileget__val ?x0 )
    )
  )
  :assumption
  (forall
      (?x Int )
    (iff
      (admin__opandnullt___member ?x )
      (and (<= 0 ?x ) (<= ?x 4 ) )
    )
  )
  :assumption
  (forall
      (?x Int )
    (iff
      (alarmtypes__statust___member ?x )
      (and (<= 0 ?x ) (<= ?x 1 ) )
    )
  )
  :assumption
  (forall
      (?x Int )
    (iff
      (bit___type___member ?x )
      (and (<= 0 ?x ) (<= ?x 1 ) )
    )
  )
  :assumption
  (forall
      (?x Int )
    (iff (door__t___member ?x ) (and (<= 0 ?x ) (<= ?x 1 ) ) )
  )
  :assumption
  (forall
      (?x Int )
    (iff
      (privtypes__privileget___member ?x )
      (and (<= 0 ?x ) (<= ?x 3 ) )
    )
  )
  :assumption
  (forall
      (?x Int ) (?y Int )
    (iff
      (= (bit___and ?x ?y ) bit___true )
      (and (= ?x bit___true ) (= ?y bit___true ) )
    )
  )
  :assumption
  (forall
      (?x Int ) (?y Int )
    (iff
      (= (bit___or ?x ?y ) bit___true )
      (or (= ?x bit___true ) (= ?y bit___true ) )
    )
  )
  :assumption
  (forall
      (?x Int ) (?y Int )
    (iff
      (= (bit___iff ?x ?y ) bit___true )
      (iff (= ?x bit___true ) (= ?y bit___true ) )
    )
  )
  :assumption
  (forall
      (?x Int )
    (iff
      (= (bit___not ?x ) bit___true )
      (not (= ?x bit___true ) )
    )
  )
  :assumption
  (forall
      (?x Int ) (?y Int )
    (iff (= (integer___bit_eq ?x ?y ) bit___true ) (= ?x ?y ) )
  )
  :assumption
  (forall
      (?x real___type ) (?y real___type )
    (iff (= (real___bit_eq ?x ?y ) bit___true ) (= ?x ?y ) )
  )
  :assumption
  (forall
      (?x Int ) (?y Int )
    (iff
      (= (bit___type___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x Int ) (?y Int )
    (iff
      (= (admin__opandnullt___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x admin__t ) (?y admin__t )
    (iff (= (admin__t___bit_eq ?x ?y ) bit___true ) (= ?x ?y ) )
  )
  :assumption
  (forall
      (?x admintoken__statetype ) (?y admintoken__statetype )
    (iff
      (= (admintoken__statetype___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x alarm__outtype ) (?y alarm__outtype )
    (iff
      (= (alarm__outtype___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x Int ) (?y Int )
    (iff
      (= (alarmtypes__statust___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x clock__timet ) (?y clock__timet )
    (iff
      (= (clock__timet___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x door__statetype ) (?y door__statetype )
    (iff
      (= (door__statetype___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x Int ) (?y Int )
    (iff (= (door__t___bit_eq ?x ?y ) bit___true ) (= ?x ?y ) )
  )
  :assumption
  (forall
      (?x enclave__statetype ) (?y enclave__statetype )
    (iff
      (= (enclave__statetype___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x keystore__state__type ) (?y keystore__state__type )
    (iff
      (= (keystore__state__type___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x latch__outtype ) (?y latch__outtype )
    (iff
      (= (latch__outtype___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x latch__statetype ) (?y latch__statetype )
    (iff
      (= (latch__statetype___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x Int ) (?y Int )
    (iff
      (= (privtypes__privileget___bit_eq ?x ?y ) bit___true )
      (= ?x ?y )
    )
  )
  :assumption
  (forall
      (?x Int ) (?y Int )
    (iff (= (integer___bit_le ?x ?y ) bit___true ) (<= ?x ?y ) )
  )
  :assumption
  (= bit___false 0 )
  :assumption
  (= bit___true 1 )
  :formula
  (and
    (iff
      (not (enclave__enrolmentisinprogress enclave__state ) )
      (keystore__privatekeypresent keystore__state )
    )
    (iff
      (latch__islocked latch__state )
      (latch__prf_islocked latch__output )
    )
    (implies
      (= (admin__prf_rolepresent theadmin ) privtypes__guard )
      (and
        (admintoken__prf_isgood admintoken__state )
        (and
          (admintoken__prf_authcertvalid admintoken__state )
          (=
            (admintoken__theauthcertrole admintoken__state )
            privtypes__guard
          )
        )
      )
    )
    (implies
      (and
        (admin__isdoingop theadmin )
        (= (admin__thecurrentop theadmin ) admin__overridelock )
      )
      (= (admin__prf_rolepresent theadmin ) privtypes__guard )
    )
    (implies
      (= (admin__prf_rolepresent theadmin ) privtypes__guard )
      (or
        (and
          (admin__isdoingop theadmin )
          (= (admin__thecurrentop theadmin ) admin__overridelock )
        )
        (not (admin__isdoingop theadmin ) )
      )
    )
    (implies
      (not (admin__ispresent theadmin ) )
      (not (admin__isdoingop theadmin ) )
    )
    (implies
      (and
        (admin__isdoingop theadmin )
        (= (admin__thecurrentop theadmin ) admin__shutdownop )
      )
      (enclave__prf_statusiswaitingstartadminop enclave__state )
    )
    (implies
      (or
        (enclave__prf_statusisgotadmintoken enclave__state )
        (enclave__prf_statusiswaitingremoveadmintokenfail
          enclave__state
        )
      )
      (not (admin__ispresent theadmin ) )
    )
    (implies
      (or
        (enclave__prf_statusiswaitingstartadminop enclave__state )
        (enclave__prf_statusiswaitingfinishadminop enclave__state )
      )
      (and
        (admin__ispresent theadmin )
        (admin__isdoingop theadmin )
      )
    )
    (implies
      (enclave__prf_statusisenclavequiescent enclave__state )
      (not (admin__isdoingop theadmin ) )
    )
    (implies
      (enclave__prf_statusisshutdown enclave__state )
      (and
        (not (admin__isdoingop theadmin ) )
        (= (admin__prf_rolepresent theadmin ) privtypes__useronly )
      )
    )
    (implies
      (enclave__enrolmentisinprogress enclave__state )
      (and
        (not (admin__ispresent theadmin ) )
        (not (admin__isdoingop theadmin ) )
      )
    )
    (iff
      (and
        (latch__islocked latch__state__1 )
        (and
          (= (door__thecurrentdoor door__state__1 ) door__open )
          (clock__greaterthanorequal
            (clock__thecurrenttime clock__currenttime__1 )
            (door__prf_alarmtimeout door__state__1 )
          )
        )
      )
      (=
        (door__thedooralarm door__state__1 )
        alarmtypes__alarming
      )
    )
    (iff
      (admintoken__prf_isgood admintoken__state )
      (admintoken__prf_isgood admintoken__state__1 )
    )
    (iff
      (admintoken__prf_authcertvalid admintoken__state )
      (admintoken__prf_authcertvalid admintoken__state__1 )
    )
    (iff
      (=
        (admintoken__theauthcertrole admintoken__state )
        privtypes__guard
      )
      (=
        (admintoken__theauthcertrole admintoken__state__1 )
        privtypes__guard
      )
    )
    (iff
      (latch__islocked latch__state__1 )
      (clock__greaterthanorequal
        (clock__thecurrenttime clock__currenttime__1 )
        (latch__prf_latchtimeout latch__state__1 )
      )
    )
    (implies
      (latch__islocked latch__state )
      (and
        (= latch__state__1 latch__state )
        (latch__islocked latch__state__1 )
      )
    )
    (=
      (latch__prf_latchtimeout latch__state__1 )
      (latch__prf_latchtimeout latch__state )
    )
    (implies
      (=
        (door__thedooralarm door__state__1 )
        alarmtypes__alarming
      )
      (alarm__prf_isalarming alarm__output__2 )
    )
    (iff
      (latch__islocked latch__state__1 )
      (latch__prf_islocked latch__output__2 )
    )
    (implies
      (= (admin__prf_rolepresent theadmin ) privtypes__guard )
      (and
        (admintoken__prf_isgood admintoken__state__1 )
        (and
          (admintoken__prf_authcertvalid admintoken__state__1 )
          (=
            (admintoken__theauthcertrole admintoken__state__1 )
            privtypes__guard
          )
        )
      )
    )
    (iff
      (not (enclave__enrolmentisinprogress enclave__state__3 ) )
      (keystore__privatekeypresent keystore__state__3 )
    )
    (iff
      (and
        (latch__islocked latch__state__3 )
        (and
          (= (door__thecurrentdoor door__state__3 ) door__open )
          (clock__greaterthanorequal
            (clock__thecurrenttime clock__currenttime__1 )
            (door__prf_alarmtimeout door__state__3 )
          )
        )
      )
      (=
        (door__thedooralarm door__state__3 )
        alarmtypes__alarming
      )
    )
    (implies
      (and
        (not (latch__islocked latch__state__3 ) )
        (latch__islocked latch__state__1 )
      )
      (or
        userentry__prf_userentryunlockdoor
        (and
          (admintoken__prf_isgood admintoken__state__3 )
          (and
            (admintoken__prf_authcertvalid admintoken__state__3 )
            (=
              (admintoken__theauthcertrole admintoken__state__3 )
              privtypes__guard
            )
          )
        )
      )
    )
    (implies
      (= (admin__prf_rolepresent theadmin__3 ) privtypes__guard )
      (and
        (admintoken__prf_isgood admintoken__state__3 )
        (and
          (admintoken__prf_authcertvalid admintoken__state__3 )
          (=
            (admintoken__theauthcertrole admintoken__state__3 )
            privtypes__guard
          )
        )
      )
    )
    (implies
      (and
        (admin__isdoingop theadmin__3 )
        (= (admin__thecurrentop theadmin__3 ) admin__overridelock )
      )
      (= (admin__prf_rolepresent theadmin__3 ) privtypes__guard )
    )
    (implies
      (= (admin__prf_rolepresent theadmin__3 ) privtypes__guard )
      (or
        (and
          (admin__isdoingop theadmin__3 )
          (= (admin__thecurrentop theadmin__3 ) admin__overridelock )
        )
        (not (admin__isdoingop theadmin__3 ) )
      )
    )
    (implies
      (not (admin__ispresent theadmin__3 ) )
      (not (admin__isdoingop theadmin__3 ) )
    )
    (implies
      (and
        (admin__isdoingop theadmin__3 )
        (= (admin__thecurrentop theadmin__3 ) admin__shutdownop )
      )
      (enclave__prf_statusiswaitingstartadminop
        enclave__state__3
      )
    )
    (implies
      (or
        (enclave__prf_statusisgotadmintoken enclave__state__3 )
        (enclave__prf_statusiswaitingremoveadmintokenfail
          enclave__state__3
        )
      )
      (not (admin__ispresent theadmin__3 ) )
    )
    (implies
      (or
        (enclave__prf_statusiswaitingstartadminop
          enclave__state__3
        )
        (enclave__prf_statusiswaitingfinishadminop
          enclave__state__3
        )
      )
      (and
        (admin__isdoingop theadmin__3 )
        (and
          (admin__ispresent theadmin__3 )
          (=
            (admin__prf_rolepresent theadmin__3 )
            (admin__prf_rolepresent theadmin )
          )
        )
      )
    )
    (implies
      (enclave__prf_statusisenclavequiescent enclave__state__3 )
      (not (admin__isdoingop theadmin__3 ) )
    )
    (implies
      (enclave__prf_statusisshutdown enclave__state__3 )
      (and
        (not (admin__isdoingop theadmin__3 ) )
        (=
          (admin__prf_rolepresent theadmin__3 )
          privtypes__useronly
        )
      )
    )
    (implies
      (enclave__enrolmentisinprogress enclave__state__3 )
      (and
        (not (admin__ispresent theadmin__3 ) )
        (not (admin__isdoingop theadmin__3 ) )
      )
    )
    (implies
      (=
        (door__thedooralarm door__state__3 )
        alarmtypes__alarming
      )
      (alarm__prf_isalarming alarm__output__4 )
    )
    (or
      (iff
        (latch__islocked latch__state__3 )
        (latch__prf_islocked latch__output__4 )
      )
      systemfault__4
    )
    (<= 0 alarmtypes__statust__size )
    (<= 0 privtypes__privileget__size )
    (<= 0 door__t__size )
    (<= 0 admin__opandnullt__size )
    (not
      (or
        (implies
          (and
            (latch__prf_islocked latch__output )
            (and
              (and
                (not (latch__prf_islocked latch__output__4 ) )
                (not (latch__islocked latch__state__3 ) )
              )
              (iff
                (latch__islocked latch__state )
                (latch__prf_islocked latch__output )
              )
            )
          )
          (or
            userentry__prf_userentryunlockdoor
            (and
              (admintoken__prf_isgood admintoken__state__3 )
              (and
                (admintoken__prf_authcertvalid admintoken__state__3 )
                (=
                  (admintoken__theauthcertrole admintoken__state__3 )
                  privtypes__guard
                )
              )
            )
          )
        )
        systemfault__4
      )
    )
  )
  :status unknown
)
