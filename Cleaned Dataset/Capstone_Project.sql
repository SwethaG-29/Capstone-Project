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
DELIMITER $$
CREATE PROCEDURE OEE_Procedure ()
BEGIN
WITH oee_metrics AS 
(SELECT `primary machine name`,
    ((`AT available time (imine)` - `idle duration`) - `down time`)/`AT available time (imine)` as availability,
    (`operatingtime (cat)` - `delay time`)/`operatingtime (cat)` as performance,
    (`operatingtime (cat)` - `idle duration`- `down time`)/`operatingtime (cat)` as quality
FROM
    cycle_data)

SELECT `primary machine name`,round(availability * performance * quality, 3) as OEE
from oee_metrics;
END $$
DELIMITER ;

-- ----- Q. How many unique Equipments operating in the field 
SELECT COUNT(DISTINCT `primary machine name`) AS unique_primary_machines
FROM cycle_data;
-- There are 136 Equipments operating in the field

-- ----- Q. How many machine need Maintenance 
SELECT COUNT(DISTINCT `primary machine name`) AS unique_primary_machines
FROM cycle_data
where `delay time` > 0;
-- Total of 130 Machines require Maintenance

-- ----- Q. How Long the machines where kept idle 
SELECT (`primary machine name`) AS unique_primary_machines, round((`idle duration`/3600),2) as `Idle Duration in Hrs`
FROM cycle_data
where `idle duration` > 0 
Order by `idle duration` DESC;

-- The minimum number of hrs the Equipment/Machine kept idle was 45min - 12 hrs 
-- So need to investigate why the Equipment was idle for so long ? Is it beacuse of Waiting time the machine
-- Mainaineneance, no operator, 

SELECT
    `Primary Machine Name` AS MachineID,
    AVG(TIMESTAMPDIFF(MINUTE, `Cycle Start Timestamp (GMT8)`, `Cycle End Timestamp (GMT8)`)) AS AverageIdleTime
FROM
    Cycle_Data
WHERE
    `Idle Duration` IS NOT NULL
GROUP BY
    `Primary Machine Name`;

select * from cycle_data;

-- ----- Q. How Long the Trucks were Delay
SELECT (`primary machine name`) AS unique_primary_machines, round((`Delay Time`/3600),2) as `Delay Duration in Hrs`
FROM cycle_data
where `Delay Time` > 0 
Order by `Delay Time` DESC;
-- The delay the Truck is in the range of 2 - 12Hrs, need to investigate why this delay is occcured
-- (Is it because of weather condition or road's issue or Truck Failure, Need consider all possible factor)

-- -----Q. How many machines are operational versus those that require maintenance?

SELECT
    CASE 
        WHEN `Down Time` > 0 OR `UNSCHEDULEDDOWNTIME` > 0 THEN 'Maintenance'
        ELSE 'Operational'
    END AS Status,
    COUNT(DISTINCT `primary machine name`) AS MachineCount
FROM
    Cycle_Data
GROUP BY
    Status;
    
-- 130 Machines require Maintenance and 108 were operation 

-- -----Q. What is the average payload transported by each type of machine?

select ROUND(Avg(`Payload (kg)`),2) as Average_Payload, `cycle type` 
from cycle_data
GROUP BY `cycle type`;
-- LoaderCycle - 234636.12, TruckCycle - 228343.11

-- 

