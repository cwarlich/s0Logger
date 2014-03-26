var Boot=99
var AnlagenKWP=91020
var time_start = new Array(8,7,6,6,6,6,6,6,7,7,8,8)
var time_end = new Array(17,18,20,21,21,22,22,21,20,19,17,17)
var sollMonth = new Array(2,6,9,11,11,13,13,12,10,6,4,3)
var SollYearKWP=850
var AnzahlWR = 12
var MaxWRP=new Array(AnzahlWR)
MaxWRP[0]=new Array(8100,60000,1450000,8500000)
MaxWRP[1]=new Array(8100,60000,1450000,8500000)
MaxWRP[2]=new Array(8100,60000,1450000,8500000)
MaxWRP[3]=new Array(8100,60000,1450000,8500000)
MaxWRP[4]=new Array(8100,60000,1450000,8500000)
MaxWRP[5]=new Array(8100,60000,1450000,8500000)
MaxWRP[6]=new Array(8100,60000,1450000,8500000)
MaxWRP[7]=new Array(8100,60000,1450000,8500000)
MaxWRP[8]=new Array(8100,60000,1450000,8500000)
MaxWRP[9]=new Array(3400,25000,600000,3500000)
MaxWRP[10]=new Array(3400,25000,600000,3500000)
MaxWRP[11]=new Array(3400,25000,600000,3500000)
var WRInfo = new Array(AnzahlWR)
WRInfo[0]=new Array("Powad/PVI","         1",8880,1,"WR 1",1,null,null,0,null,2,0,1,1000,null)
WRInfo[1]=new Array("Powad/PVI","         2",8880,1,"WR 2",1,null,null,0,null,2,0,1,1000,null)
WRInfo[2]=new Array("Powad/PVI","         3",8880,1,"WR 3",1,null,null,0,null,2,0,1,1000,null)
WRInfo[3]=new Array("Powad/PVI","         4",8880,1,"WR 4",1,null,null,0,null,2,0,1,1000,null)
WRInfo[4]=new Array("Powad/PVI","         5",8880,1,"WR 5",1,null,null,0,null,2,0,1,1000,null)
WRInfo[5]=new Array("Powad/PVI","         6",8880,1,"WR 6",1,null,null,0,null,2,0,1,1000,null)
WRInfo[6]=new Array("Powad/PVI","         7",8880,1,"WR 7",1,null,null,0,null,2,0,1,1000,null)
WRInfo[7]=new Array("Powad/PVI","         8",8880,1,"WR 8",1,null,null,0,null,2,0,1,1000,null)
WRInfo[8]=new Array("Powad/PVI","         9",8880,1,"WR 9",1,null,null,0,null,2,0,1,1000,null)
WRInfo[9]=new Array("Powad/PVI","        10",3700,1,"WR 10",1,null,null,0,null,2,0,1,1000,null)
WRInfo[10]=new Array("Powad/PVI","        11",3700,1,"WR 11",1,null,null,0,null,2,0,1,1000,null)
WRInfo[11]=new Array("Powad/PVI","        12",3700,1,"WR 12",1,null,null,0,null,2,0,1,1000,null)
var HPTitel="Photovoltaik"
var HPBetreiber="Gisela und Christof Warlich"
var HPEmail="christof@warlich.name"
var HPStandort="Meckenheim"
var HPModul="Yingli YL 185P-23b-1"
var HPWR="KACO Powador: 9*8000xi, 3*3600xi"
var HPLeistung="91.02kWp"
var HPInbetrieb="7.5.2010"
var HPAusricht="19� S�d-Ost"
var BannerZeile1="PV-Anlage"
var BannerZeile2="91.02KWp in Meckenheim"
var BannerZeile3="im Netz seit Mai 2010"
var BannerLink="warlich.bplaced.net/Meckenheim"
var StatusCodes = new Array(12)
var FehlerCodes = new Array(12)
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
StatusCodes[10] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[10] = ""
StatusCodes[11] = "Erst.Einsch.,Warte Spannung,Warte Ausschlt,Konstantspann.,MPP Low,MPP,Warten,Warten,Relaistest,Fehlersuchbetr,�bertemp.Absc,Leistungsbegr,�berlastabsch,�berspannab,Netzausfall,Nachtabschalt,Betriebshemm., ,AFI Abschalt.,Iso zu gering, , , , ,Fehler DSP,Test L-Elektr.,Test Netzrelais, ,HW-Fehler,Erdschluss DC,Fehler Messt,Fehler AFI-M,Fehler ST,Fehler DC,Fehler Komm.,Schutzabsch. SW,Schutzabsch. HW, ,Fehler PV-�b, ,Schneeschmelzen,Netz U Unter L1,Netz U �ber L1,Netz U Unter L2,Netz U �ber L2,Netz U Unter L3,Netz U �ber L3,Netz U Au�en,Netz F Unter,Netz F �ber,Netz U Mittel,Netz MU UnterL1,Netz MU �ber L1,Netz MU UnterL2,Netz MU �ber L2,Fehler Zwischen, ,Warte Wiederein,Steuerk. T �ber,Fehler Selbstt.,UDC �ber,Power-Control,Inselbetrieb,Freq. Reduz.,IAC Max.,Fehler ROCOF,Fehler Plausib."
FehlerCodes[11] = ""
var Verguetung=3786
var Serialnr =     102505
var Firmware = "2.3.0 Build 32"
var FirmwareDate = "01.02.2011"
var WRTyp = "MULTIPROTOCOL"
var OEMTyp = 0
var SLTyp = "1000"
var SLVer = 2
var SLHW = 2557
var SLBV = 22
var Intervall = 300
var SLDatum = "26.02.13"
var SLUhrzeit = "07:18:11"
var isTemp=true
var isOnline=true
var eventsHP=1
var exportDir="Meckenheim"
var Lang="DE"
var AnzahlGrp=0
var CFDatum = "11.11.12"
var CFUhrzeit = "17:30:27"
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
var Dezimalseparator =","