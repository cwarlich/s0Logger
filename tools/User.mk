hp=SolarLog-Homepage2.5.0-INT
${hp}Sources:=Makefile # Any existing file is fine, except ..
${hp}Sources.cpp= # Other default extensions may need to be cleared as new files are added.
${hp}Compiler:= wget -O$$@ www.solar-log.com/fileadmin/BENUTZERDATEN/Downloads/Homepage/${hp}.zip && touch $$@
${hp}Linker:=rm -rf $$@/* && unzip $$< && touch $$@
Targets=buffer ${hp}
