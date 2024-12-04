module nanoc.std.stdlib.random;

import nanoc.meta: Omit;

// Given pseudorandom number generator was obtained by heuristic technique. That's it.

@Omit
__gshared uint i = 1;

@Omit
__gshared uint j = 0;

extern(C) int rand()
{
    j = j + i;
    i = i ^ j << 2;
    return i++;
}

extern(C) void srand(int seed)
{
    i = seed & 0xFFFF;
    j = (seed >> 16) & 0xFFFF;
}

unittest
{
    import nanoc.std.stdio;
    import nanoc.std.time;
    int seed = cast(int) time(null);
    printf("Seed: %d\n", seed);
    srand(seed);

    int[0x10000] count;
    for (int i = 0; i < 0x10000; i++)
    {
        uint x = rand()%0x10000u;
        count[x]++;
    }

    for (int i = 0; i < 0x10000; i++)
    {
        assert(count[i] == 1);
    }
}

unittest
{
    srand(0xffffffff);

    int[0x100] expected = [458759,2293776,9633869,40829402,248973531,1187194028,635673481,-548620602,-1464942929,-1305231976,1364739093,2039827954,1991707715,-1622573436,-127069615,-1330273202,-1155865833,1124085920,1192994461,1737594410,-650043573,-90957348,-189696039,341457590,638452479,-327006392,-1877531099,753327138,1550562995,-1101532204,1707861857,385897822,-640855321,-271646288,452025261,2079495034,725386683,-688084980,-1890687511,430047334,-455710897,1947755320,355988085,-1556567726,-506812125,735448100,1386404273,-1767709202,-2010566153,-1223054848,-1399920131,1633419786,840889899,698366716,-341867975,-1692253290,1180996511,-1329754840,158522885,-689433278,-304925421,525648308,1888369345,1117641918,2115405255,1257502032,709275789,597080218,-1145286117,1017143532,1161680457,-878126714,1989192815,-504656936,-20783915,-453634382,1257976707,-1828536124,-1257884015,1327228430,2039910103,1701915360,-673356451,-973307798,-269523317,104785820,83097625,309266422,1916147775,1527224456,-834110875,3782370,-815718669,-1011073772,-663608031,-1511749218,-1328784729,1754687344,304463085,-781225030,-664277509,-1295008820,-2027356503,-710689114,2092532751,-524693768,-27375563,-432083054,1466075747,1501824484,762487537,129208366,1312613303,-859840064,2034067645,-481999670,-993494165,-26782148,-903098247,-1764747178,787231199,1560330472,-1158728635,1766060418,301955667,-784003212,-729039487,-2089413250,-425464953,-423213424,2109243853,-271036582,-1105575077,-198092244,-289286135,993409606,-102305489,1401577752,-1424198251,236691314,-747767869,-129781756,-193021999,709447886,-1391166825,-1766101472,2597661,-1759708502,1689501387,-489848484,-210123687,753046070,-1077473921,763812040,1708908709,-1172874334,1916629555,-484278188,-24415263,-379801378,1410741863,1505056304,768470829,108894970,1138457403,382711180,-1499721367,-329253914,270279119,749224120,-1006820107,1018485970,-827738205,-496108124,1410448689,1389529198,14671735,1431505792,-7730819,1451958666,1436978859,207710076,-2027102023,791538198,1268078879,-660910424,769662085,-2128881470,812711827,1130355252,-1007594431,1401064254,-1912830137,-1685279024,523127309,510805786,1700228763,1976929644,-1844669239,-1576536058,439137519,988976216,911926869,-800133838,-150917885,-195733180,553418769,2020039054,1113482839,32292704,1250519517,1057101802,1318177291,-448082916,-1538458983,1987500662,-631025473,-809394936,-1687626523,1495558498,2147103347,1497175700,-762943071,122899486,-193914329,815244528,-1210911123,-784082374,2061717371,-305226676,-1549346775,2124774694,-1455627121,-709767304,115713717,-401694190,1730883299,1291413092,323912817,-1077971026,340829495,-379403712,1272951357,-1713140918,-1607864853,442233788,968498937,863008726,-335790241,1669429608,1963086533,-1618074622,-146070829,-1296387852,-1570315007,940641534];

    int[0x100] numbers;
    for (int i = 0; i < 0x100; i++)
    {
        numbers[i] = rand();
    }

    for (int i = 0; i < 0x100; i++)
    {
        assert(numbers[i] == expected[i]);
    }
}
