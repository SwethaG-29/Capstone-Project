CREATE SCHEMA Supply_Chain_DB;
USE Supply_Chain_DB;

CREATE TABLE Equipment_Master AS
SELECT
`Primary Machine Name`, `Primary Machine Class Name`, 
`Secondary Machine Name`,`Secondary Machine Class Name`, `Cycle type`, `AT Available Time (iMine)`
 `Loading Count`,`iMine Load FCTR Truck`, `PREVIOUSSECONDARYMACHINE`,
 `PREVIOUSSINKDESTINATION`, `End Processor Name`, `iMine Engine Hours`,
 `iMine Operating Hours`, `OPERATINGTIME (CAT)`, `OPERHOURSSECONDS`,
 `Full Travel Duration`, `Empty Travel Duration`,`Idle Duration`, 
 `Loading Duration`, `WAITFORDUMPDURATION`, `Dumping Duration`,
 `Payload (kg)`, `Estimated Fuel Used`,	`Fuel Used`, `Loading Efficiency`,
 `OPERATINGBURNRATE`, `TMPH`,`Job Code Name`
FROM cycle_data;

SELECT * FROM Equipment_Master;

CREATE TABLE Equipment_Type_Master AS
SELECT`Cycle Type`, `Primary Machine Category Name`,`Secondary Machine Category Name`,
`TC`,`AT Available Time (iMine)`, `Available SMU Time`, `Cycle Duration`,
`Cycle SMU Duration`,`Delay Time`,`Down Time`,`Completed Cycle Count`, 
`iMine Availability`, `iMine Utilisation`, `Job Type`
FROM cycle_data;

CREATE TABLE Location_Master AS
SELECT 
`Source Location Name`, `Destination Location Name` , `Queuing at Sink Duration`
`Queuing at Source Duration`, `Queuing Duration`,`Cycle End Timestamp (GMT8)`,
`Cycle Start Timestamp (GMT8)` ,
`Source Loading Start Timestamp (GMT8)`,
`Source Loading End Timestamp (GMT8)`
FROM cycle_data;

CREATE TABLE Location_Type_Master AS
SELECT 
`Destination Location Description`,`Empty EFH Distance`, `Empty Slope Distance` , 
`Queuing at Sink Duration`,`Queuing at Source Duration` , `Queuing Duration`,
`Source Location is Active Flag`,
`Source Location is Source Flag`,
`Destination Location is Active Flag`,
`Destination Location is Source Flag`
FROM cycle_data;

select * from Location_Type_Master;

-- Prepare Stored Procedures for Cycle Data, Movement Data, Delay Data, OEE Calculations

-- Stored Procedures for Cycle Data
DELIMITER $$
CREATE PROCEDURE Cycle_Data_Stored_Procedure ()
BEGIN
select `AT Available Time (iMine)`,
    `Cycle Type`,
    `Delay Time`,
    `Down Time`,
    `Dumping Duration`,
    `Estimated Fuel Used`,
    `Fuel Used`,
    `Full Travel Duration`,
    `Idle Duration`,
    `iMine Load FCTR Truck`,
    `Loading Count`,
    `Loading Duration`,
    `OPERATINGBURNRATE`,
    `OPERATINGTIME (CAT)`,
    `Payload (kg)`,
    `TMPH`,
    `Primary Machine Name`,
    `Primary Machine Class Name`,
    `Secondary Machine Name`,
    `Secondary Machine Class Name`,
    `Available SMU Time`,
    `Completed Cycle Count`,
    `Cycle Duration`,
    `Cycle SMU Duration`,
    `iMine Availability`,
    `iMine Utilisation`,
    `Primary Machine Category Name`,
    `Secondary Machine Category Name`,
    `Cycle End Timestamp (GMT8)`,
    `Source Loading End Timestamp (GMT8)`,
    `Source Loading Start Timestamp (GMT8)`,
    `Queuing Duration`,
    `Cycle Start Timestamp (GMT8)`,
    `Source Location Name`,
    `Destination Location Name`,
    `Source Location is Active Flag`,
    `Source Location is Source Flag`,
    `Destination Location is Active Flag`,
    `Destination Location is Source Flag`
FROM cycle_data; 
END $$
DELIMITER ;

-- Stored Procedures for Movement Data
DELIMITER $$
CREATE PROCEDURE  Movement_Data_Procedure()
BEGIN 
select `Source Location Name`,`Destination Location Name`,`Source Loading Start Timestamp (GMT8)`,
`Source Loading End Timestamp (GMT8)`,`Source Location Description`,
`Destination Location Description`,`Empty EFH Distance`,`Empty Slope Distance`,
`Source Location is Active Flag`,`Source Location is Source Flag`, 
`Destination Location is Active Flag`,`Destination Location is Source Flag`,
`Full Travel Duration`, `Empty Travel Duration`,`Idle Duration`, 
`Loading Duration`, `WAITFORDUMPDURATION`, `Dumping Duration`
from cycle_data;
END $$
DELIMITER ;

-- Stored Procedures for Delay Data

DElIMITER $$
CREATE PROCEDURE Delay_data_stored_Procedure()
BEGIN
select  `Delay OID`,
    `Description`,
    `ECF Class ID`,
    `Acknowledge Flag`,
    `Acknowledged Flag`,
    `Confirmed Flag`,
    `Engine Stopped Flag`,
    `Field Notification Required Flag`,
    `Office Confirm Flag`,
    `Production Reporting Only Flag`,
    `Frequency Type`,
    `Shift Type`,
    `Target Location`,
    `Target Road`,
    `Workorder Ref`,
    `Delay Class Name`,
    `Delay Class Description`,
    `Delay Class is Active Flag`,
    `Delay Class Category Name`,
    `Target Machine Name`,
    `Target Machine is Active Flag`,
    `Target Machine Class Name`,
    `Target Machine Class Description`,
    `Target Machine Class is Active Flag`,
    `Target Machine Class Category Name`,
    `Delay Reported By Person Name`,
    `Delay Reported By User Name`,
    `Delay Status Description`,
    `Delay Start Timestamp (GMT8)`,
    `Delay Finish Timestamp (GMT8)`
from Delay_data;
END $$
DELIMITER ;

-- Stored Procedures for Location

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `location_data_procedure`()
BEGIN
SELECT `Location_Id`,
    `Name`,
    `Latitude`,
    `Longitude`
FROM location_data;

END$$
DELIMITER ;

-- Stored Procedures for OEE Calculations


Availability = (AT Available Time (iMine) - (Down Time)) / nullif(AT Available Time (iMine),0)*100
Performance = (OPERATINGTIME (CAT) - delay time)/nullif(OPERATINGTIME (CAT),0)*100
Quality = (`operatingtime (cat)` - `idle duration`)/ `operatingtime (cat)