var Boot=99
var AnlagenKWP=40000
var time_start = new Array(7,6,5,5,4,4,4,5,5,6,7,7)
var time_end = new Array(16,17,19,21,22,22,21,20,19,17,16)
var sollMonth = new Array(2,6,9,11,11,13,13,12,10,6,4,3)
var SollYearKWP=850
var AnzahlWR = 4
var MaxWRP=new Array(AnzahlWR)
MaxWRP[0]=new Array(9000,60000,1450000,8500000)
MaxWRP[1]=new Array(9000,60000,1450000,8500000)
MaxWRP[2]=new Array(9000,60000,1450000,8500000)
MaxWRP[3]=new Array(9000,60000,1450000,8500000)
var WRInfo = new Array(AnzahlWR)
WRInfo[0]=new Array("StecaGrid 9000 3ph","         1",10000,1,"WR 1",1,null,null,0,null,2,0,1,1000,null)
WRInfo[1]=new Array("StecaGrid 9000 3ph","         2",10000,1,"WR 2",1,null,null,0,null,2,0,1,1000,null)
WRInfo[2]=new Array("StecaGrid 9000 3ph","         3",10000,1,"WR 3",1,null,null,0,null,2,0,1,1000,null)
WRInfo[3]=new Array("StecaGrid 9000 3ph","         4",10000,1,"WR 4",1,null,null,0,null,2,0,1,1000,null)
var HPTitel="Photovoltaik"
var HPBetreiber="Gisela und Christof Warlich"
var HPEmail="christof@warlich.name"
var HPStandort="Brenntwood-Stra�e 4"
var HPModul="RCA"
var HPWR="StecaGrid 9000 3ph"
var HPLeistung="40.00"
var HPInbetrieb="30.6.2010"
var HPAusricht="23� S�d-Ost"
var BannerZeile1="PV-Anlage"
var BannerZeile2="Roth Geb�ude 1"
var BannerZeile3="im Netz seit Juli 2010"
var BannerLink="warlich.bplaced.net/Roth1"
var StatusCodes = new Array(AnzahlWR)
var FehlerCodes = new Array(AnzahlWR)
StatusCodes[0] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[0] = ""
StatusCodes[1] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[1] = ""
StatusCodes[2] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[2] = ""
StatusCodes[3] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[3] = ""
StatusCodes[4] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[4] = ""
StatusCodes[5] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[5] = ""
StatusCodes[6] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[6] = ""
StatusCodes[7] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[7] = ""
StatusCodes[8] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[8] = ""
StatusCodes[9] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[9] = ""
var Verguetung=37.36
var Serialnr =     102505
var Firmware = "2.3.0 Build 32"
var FirmwareDate = "01.02.2011"
var WRTyp = "MULTIPROTOCOL"
var OEMTyp = 0
var SLTyp = " FritzBox"
var SLVer = 2
var SLHW = 2557
var SLBV = 22
var Intervall = 300
var SLDatum = "24.02.12"
var SLUhrzeit = "14:59:52"
var isTemp=true
var isOnline=true
var eventsHP=1
var exportDir=""
var Lang="DE"
var AnzahlGrp=0
var CFDatum = "24.02.12"
var CFUhrzeit = "14:24:27"
var SCB = false
var IPlatform = 3
var DateFormat ="dd.mm.yy"
var TimeFormat ="HH:MM:ss"
var TimeFormatNoSec ="HH:MM"
var Currency ="�"
var CurrencySub ="Cent"
var CurrencyFirst ="0"
var ISOCode ="DE"
var DSTMode ="1"
