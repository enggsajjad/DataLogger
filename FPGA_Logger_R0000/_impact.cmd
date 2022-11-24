setPreference -pref UserLevel:NOVICE
setPreference -pref MessageLevel:DETAILED
setPreference -pref ConcurrentMode:FALSE
setPreference -pref UseHighz:FALSE
setPreference -pref ConfigOnFailure:STOP
setPreference -pref StartupCLock:AUTO_CORRECTION
setPreference -pref AutoSignature:FALSE
setPreference -pref KeepSVF:FALSE
setPreference -pref svfUseTime:FALSE
setPreference -pref UserLevel:NOVICE
setPreference -pref MessageLevel:DETAILED
setPreference -pref ConcurrentMode:FALSE
setPreference -pref UseHighz:FALSE
setPreference -pref ConfigOnFailure:STOP
setPreference -pref StartupCLock:AUTO_CORRECTION
setPreference -pref AutoSignature:FALSE
setPreference -pref KeepSVF:FALSE
setPreference -pref svfUseTime:FALSE
setMode -bs
setCable -port auto
Identify
setAttribute -position 1 -attr configFileName -value "D:\DNPR_DATA_LOGGER\131114\FPGA_Logger_R0000\top.mcs"
setAttribute -position 2 -attr configFileName -value "D:\DNPR_DATA_LOGGER\131114\FPGA_Logger_R0000\main.bit"
Program -p 1 -e -v -loadfpga 
viceChain -index 0
addDevice -position 1 -file "D:\DNPR_DATA_LOGGER\131114\FPGA_Logger_R0000\main.bit"
setMode -pff
setAttribute -configdevice -attr fillValue -value "FF"
setAttribute -configdevice -attr fileFormat -value "mcs"
setAttribute -collection -attr dir -value "UP"
setAttribute -configdevice -attr path -value "d:\dnpr_data_logger\131114\fpga_logger_r0000/"
setAttribute -collection -attr name -value "top"
generate -generic
