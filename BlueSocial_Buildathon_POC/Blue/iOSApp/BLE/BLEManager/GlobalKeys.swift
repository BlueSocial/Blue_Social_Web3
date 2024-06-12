//
//  GlobalKeys.swift
//  Blue
//
//  Created by Blue.

import Foundation

//public let kadvertisementData  = "advetisementdata"
//public let krssi               = "rssi"
//public let kperipheral         = "peripheral"

public let servicesDictionary = [
    
    "1811" : "ALERT NOTIFICATION SERVICE",
    "1815" : "AUTOMATION IO",
    "180F" : "BATTERY SERVICE",
    "1810" : "BLOOD PRESSURE",
    "181B" : "BODY COMPOSITION",
    "181E" : "BOND MANAGEMENT",
    "181F" : "CONTINUOUS GLUCOSE MONITORING",
    "1805" : "CURRENT TIME SERVICE",
    "1818" : "CYCLING POWER",
    "1816" : "CYCLING SPEED AND CADENCE",
    "180A" : "DEVICE INFORMATION",
    "181A" : "ENVIRONMENTAL SENSING",
    "1800" : "GENERIC ACCESS",
    "1801" : "GENERIC ATTRIBUTE",
    "1808" : "GLUCOSE",
    "1809" : "HEALTH THERMOMETER",
    "180D" : "HEART RATE",
    "1823" : "HTTP PROXY",
    "1812" : "HUMAN INTERFACE DEVICE",
    "1802" : "IMMEDIATE ALERT",
    "1821" : "INDOOR POSITIONING",
    "1820" : "INTERNET PROTOCOL SUPPORT",
    "1803" : "LINK LOSS",
    "1819" : "LOCATION AND NAVIGATION",
    "1807" : "NEXT DST CHANGE SERVICE",
    "1825" : "OBJECT TRANSFER",
    "180E" : "PHONE ALERT STATUS SERVICE",
    "1822" : "PULSE OXIMETER",
    "1806" : "REFERENCE TIME UPDATE SERVICE",
    "1814" : "RUNNING SPEED AND CADENCE",
    "1813" : "SCAN PARAMETERS",
    "1824" : "TRANSPORT DISCOVERY",
    "1804" : "TX POWER",
    "181C" : "USER DATA",
    "181D" : "WEIGHT SCALE",
    "00001530-1212-EFDE-1523-785FEABCD123" : "LEGACY DFU SERVICE",
    "6E400001-B5A3-F393-E0A9-E50E24DCCA9E" : "NORDIC UART SERVICE"
]

public let characteristicDictionary = [
    
    "2A7E" : "AEROBIC HEART RATE LOWER LIMIT",
    "2A84" : "AEROBIC HEART RATE UPPER LIMIT",
    "2A7F" : "AEROBIC THRESHOLD",
    "2A80" : "AGE",
    "2A5A" : "AGGREGATE",
    "2A43" : "ALERT CATEGORY ID",
    "2A42" : "ALERT CATEGORY ID BIT MASK",
    "2A06" : "ALERT LEVEL",
    "2A44" : "ALERT NOTIFICATION CONTROL POINT",
    "2A3F" : "ALERT STATUS",
    "2AB3" : "ALTITUDE",
    "2A81" : "ANAEROBIC HEART RATE LOWER LIMIT",
    "2A82" : "ANAEROBIC HEART RATE UPPER LIMIT",
    "2A83" : "ANAEROBIC THRESHOLD",
    "2A58" : "ANALOG",
    "2A73" : "APPARENT WIND DIRECTION",
    "2A72" : "APPARENT WIND SPEED",
    "2A01" : "APPEARANCE",
    "2AA3" : "BAROMETRIC PRESSURE TREND",
    "2A19" : "BATTERY LEVEL",
    "2A49" : "BLOOD PRESSURE FEATURE",
    "2A35" : "BLOOD PRESSURE MEASUREMENT",
    "2A9B" : "BODY COMPOSITION FEATURE",
    "2A9C" : "BODY COMPOSITION MEASUREMENT",
    "2A38" : "BODY SENSOR LOCATION",
    "2AA4" : "BOND MANAGEMENT CONTROL POINT",
    "2AA5" : "BOND MANAGEMENT FEATURE",
    "2A22" : "BOOT KEYBOARD INPUT REPORT",
    "2A32" : "BOOT KEYBOARD OUTPUT REPORT",
    "2A33" : "BOOT MOUSE INPUT REPORT",
    "2AA6" : "CENTRAL ADDRESS RESOLUTION",
    "2AA8" : "CGM FEATURE",
    "2AA7" : "CGM MEASUREMENT",
    "2AAB" : "CGM SESSION RUN TIME",
    "2AAA" : "CGM SESSION START TIME",
    "2AAC" : "CGM SPECIFIC OPS CONTROL POINT",
    "2AA9" : "CGM STATUS",
    "2A5C" : "CSC FEATURE",
    "2A5B" : "CSC MEASUREMENT",
    "2A2B" : "CURRENT TIME",
    "2A66" : "CYCLING POWER CONTROL POINT",
    "2A63" : "CYCLING POWER MEASUREMENT",
    "2A64" : "CYCLING POWER VECTOR",
    "2A99" : "DATABASE CHANGE INCREMENT",
    "2A85" : "DATE OF BIRTH",
    "2A86" : "DATE OF THRESHOLD ASSESSMENT",
    "2A08" : "DATE TIME",
    "2A0A" : "DAY DATE TIME",
    "2A09" : "DAY OF WEEK",
    "2A7D" : "DESCRIPTOR VALUE CHANGED",
    "2A00" : "DEVICE NAME",
    "2A7B" : "DEW POINT",
    "2A56" : "DIGITAL",
    "2A0D" : "DST OFFSET",
    "2A6C" : "ELEVATION",
    "2A87" : "EMAIL ADDRESS",
    "2A0C" : "EXACT TIME 256",
    "2A88" : "FAT BURN HEART RATE LOWER LIMIT",
    "2A89" : "FAT BURN HEART RATE UPPER LIMIT",
    "2A26" : "FIRMWARE REVISION STRING",
    "2A8A" : "FIRST NAME",
    "2A8B" : "FIVE ZONE HEART RATE LIMITS",
    "2AB2" : "FLOOR NUMBER",
    "2A8C" : "GENDER",
    "2A51" : "GLUCOSE FEATURE",
    "2A18" : "GLUCOSE MEASUREMENT",
    "2A34" : "GLUCOSE MEASUREMENT CONTEXT",
    "2A74" : "GUST FACTOR",
    "2A27" : "HARDWARE REVISION STRING",
    "2A39" : "HEART RATE CONTROL POINT",
    "2A8D" : "HEART RATE MAX",
    "2A37" : "HEART RATE MEASUREMENT",
    "2A7A" : "HEAT INDEX",
    "2A8E" : "HEIGHT",
    "2A4C" : "HID CONTROL POINT",
    "2A4A" : "HID INFORMATION",
    "2A8F" : "HIP CIRCUMFERENCE",
    "2ABA" : "HTTP CONTROL POINT",
    "2AB9" : "HTTP ENTITY BODY",
    "2AB7" : "HTTP HEADERS",
    "2AB8" : "HTTP STATUS CODE",
    "2ABB" : "HTTPS SECURITY",
    "2A6F" : "HUMIDITY",
    "2A2A" : "IEEE 11073-20601 REGULATORY CERTIFICATION DATA LIST",
    "2AAD" : "INDOOR POSITIONING CONFIGURATION",
    "2A36" : "INTERMEDIATE CUFF PRESSURE",
    "2A1E" : "INTERMEDIATE TEMPERATURE",
    "2A77" : "IRRADIANCE",
    "2AA2" : "LANGUAGE",
    "2A90" : "LAST NAME",
    "2AAE" : "LATITUDE",
    "2A6B" : "LN CONTROL POINT",
    "2A6A" : "LN FEATURE",
    "2AB1" : "LOCAL EAST COORDINATE",
    "2AB0" : "LOCAL NORTH COORDINATE",
    "2A0F" : "LOCAL TIME INFORMATION",
    "2A67" : "LOCATION AND SPEED",
    "2AB5" : "LOCATION NAME",
    "2AAF" : "LONGITUDE",
    "2A2C" : "MAGNETIC DECLINATION",
    "2AA0" : "MAGNETIC FLUX DENSITY - 2D",
    "2AA1" : "MAGNETIC FLUX DENSITY - 3D",
    "2A29" : "MANUFACTURER NAME STRING",
    "2A91" : "MAXIMUM RECOMMENDED HEART RATE",
    "2A21" : "MEASUREMENT INTERVAL",
    "2A24" : "MODEL NUMBER STRING",
    "2A68" : "NAVIGATION",
    "2A46" : "NEW ALERT",
    "2AC5" : "OBJECT ACTION CONTROL POINT",
    "2AC8" : "OBJECT CHANGED",
    "2AC1" : "OBJECT FIRST-CREATED",
    "2AC3" : "OBJECT ID",
    "2AC2" : "OBJECT LAST-MODIFIED",
    "2AC6" : "OBJECT LIST CONTROL POINT",
    "2AC7" : "OBJECT LIST FILTER",
    "2ABE" : "OBJECT NAME",
    "2AC4" : "OBJECT PROPERTIES",
    "2AC0" : "OBJECT SIZE",
    "2ABF" : "OBJECT TYPE",
    "2ABD" : "OTS FEATURE",
    "2A04" : "PERIPHERAL PREFERRED CONNECTION PARAMETERS",
    "2A02" : "PERIPHERAL PRIVACY FLAG",
    "2A5F" : "PLX CONTINUOUS MEASUREMENT",
    "2A60" : "PLX FEATURES",
    "2A5E" : "PLX SPOT-CHECK MEASUREMENT",
    "2A50" : "PNP ID",
    "2A75" : "POLLEN CONCENTRATION",
    "2A69" : "POSITION QUALITY",
    "2A6D" : "PRESSURE",
    "2A4E" : "PROTOCOL MODE",
    "2A78" : "RAINFALL",
    "2A03" : "RECONNECTION ADDRESS",
    "2A52" : "RECORD ACCESS CONTROL POINT",
    "2A14" : "REFERENCE TIME INFORMATION",
    "2A4D" : "REPORT",
    "2A4B" : "REPORT MAP",
    "2A92" : "RESTING HEART RATE",
    "2A40" : "RINGER CONTROL POINT",
    "2A41" : "RINGER SETTING",
    "2A54" : "RSC FEATURE",
    "2A53" : "RSC MEASUREMENT",
    "2A55" : "SC CONTROL POINT",
    "2A4F" : "SCAN INTERVAL WINDOW",
    "2A31" : "SCAN REFRESH",
    "2A5D" : "SENSOR LOCATION",
    "2A25" : "SERIAL NUMBER STRING",
    "2A05" : "SERVICE CHANGED",
    "2A28" : "SOFTWARE REVISION STRING",
    "2A93" : "SPORT TYPE FOR AEROBIC AND ANAEROBIC THRESHOLDS",
    "2A47" : "SUPPORTED NEW ALERT CATEGORY",
    "2A48" : "SUPPORTED UNREAD ALERT CATEGORY",
    "2A23" : "SYSTEM ID",
    "2ABC" : "TDS CONTROL POINT",
    "2A6E" : "TEMPERATURE",
    "2A1C" : "TEMPERATURE MEASUREMENT",
    "2A1D" : "TEMPERATURE TYPE",
    "2A94" : "THREE ZONE HEART RATE LIMITS",
    "2A12" : "TIME ACCURACY",
    "2A13" : "TIME SOURCE",
    "2A16" : "TIME UPDATE CONTROL POINT",
    "2A17" : "TIME UPDATE STATE",
    "2A11" : "TIME WITH DST",
    "2A0E" : "TIME ZONE",
    "2A71" : "TRUE WIND DIRECTION",
    "2A70" : "TRUE WIND SPEED",
    "2A95" : "TWO ZONE HEART RATE LIMIT",
    "2A07" : "TX POWER LEVEL",
    "2AB4" : "UNCERTAINTY",
    "2A45" : "UNREAD ALERT STATUS",
    "2AB6" : "URI",
    "2A9F" : "USER CONTROL POINT",
    "2A9A" : "USER INDEX",
    "2A76" : "UV INDEX",
    "2A96" : "VO2 MAX",
    "2A97" : "WAIST CIRCUMFERENCE",
    "2A98" : "WEIGHT",
    "2A9D" : "WEIGHT MEASUREMENT",
    "2A9E" : "WEIGHT SCALE FEATURE",
    "2A79" : "WIND CHILL",
    "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" : "NORDIC UART TX",
    "6E400002-B5A3-F393-E0A9-E50E24DCCA9E" : "NORDIC UART RX",
    "00001532-1212-EFDE-1523-785FEABCD123" : "LEGACY DFU PACKET",
    "00001531-1212-EFDE-1523-785FEABCD123" : "LEGACY DFU CONTROL POINT",
    "00001534-1212-EFDE-1523-785FEABCD123" : "LEGACY DFU VERSION"
]